-- Roba un Huevo - Client Exposure Auditor
-- Read-only audit for your own Roblox experience.
-- Does NOT FireServer/InvokeServer, teleport, or modify game data.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local OLD_NAMES = {
    "RobaUnHuevoAudit",
    "EggAudit",
    "ClientAuditGUI",
    "AuditConsole",
    "SimpleConsoleCapture",
    "TEST_AUDIT"
}

for _, name in ipairs(OLD_NAMES) do
    local old = playerGui:FindFirstChild(name)
    if old then
        pcall(function() old:Destroy() end)
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "RobaUnHuevoAudit"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.94, 0, 0.84, 0)
frame.Position = UDim2.new(0.03, 0, 0.08, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -485, 0, 38)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "ROBA UN HUEVO - CLIENT AUDIT v6"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 28)
status.Position = UDim2.new(0, 12, 0, 44)
status.BackgroundTransparency = 1
status.Text = "Preparando..."
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 105, 0, 32)
copyButton.Position = UDim2.new(1, -460, 0, 8)
copyButton.Text = "COPIAR"
copyButton.TextSize = 14
copyButton.Parent = frame

local uploadButton = Instance.new("TextButton")
uploadButton.Size = UDim2.new(0, 105, 0, 32)
uploadButton.Position = UDim2.new(1, -346, 0, 8)
uploadButton.Text = "SUBIR"
uploadButton.TextSize = 13
uploadButton.Parent = frame

local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(0, 105, 0, 32)
saveButton.Position = UDim2.new(1, -232, 0, 8)
saveButton.Text = "GUARDAR TXT"
saveButton.TextSize = 13
saveButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 105, 0, 32)
closeButton.Position = UDim2.new(1, -118, 0, 8)
closeButton.Text = "CERRAR"
closeButton.TextSize = 14
closeButton.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -24, 1, -88)
box.Position = UDim2.new(0, 12, 0, 78)
box.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
box.BorderSizePixel = 0
box.TextColor3 = Color3.fromRGB(235, 235, 235)
box.TextSize = 13
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextWrapped = false
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = true
box.Text = "Inicializando auditor..."
box.Parent = frame

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local report = {}
local function add(line)
    report[#report + 1] = tostring(line)
end

local function refresh()
    if box and box.Parent then
        box.Text = table.concat(report, "\n")
    end
end

local keywords = {
    "egg", "huevo", "server", "servers", "job", "jobid",
    "spawn", "rare", "rarity", "secret", "legendary", "mythic",
    "global", "best", "index", "plot", "base", "machine",
    "remote", "network", "data", "cache"
}

local function interesting(value)
    local s = string.lower(tostring(value))
    for _, word in ipairs(keywords) do
        if string.find(s, word, 1, true) then
            return true
        end
    end
    return false
end

local function safeFullName(obj)
    local ok, result = pcall(function()
        return obj:GetFullName()
    end)
    return ok and result or tostring(obj)
end


-- PASSIVE INBOUND LOGGER
-- Observa solamente datos que el servidor ya envia al cliente.
-- No llama FireServer ni InvokeServer.

local watchWords = {
    "eggworld",
    "contentcreatorremotes",
    "idlerescue",
    "penroster",
    "homestead",
    "profilemirror",
    "liveevents",
    "server",
    "job",
    "egg",
    "rarity"
}

local watchedEvents = {}
local refreshPending = false

local function scheduleRefresh()
    if refreshPending then return end
    refreshPending = true

    task.delay(0.25, function()
        refreshPending = false
        refresh()
    end)
end

local function shortValue(value, depth, seen)
    depth = depth or 0
    seen = seen or {}

    if depth > 3 then
        return "<max-depth>"
    end

    local kind = typeof(value)

    if kind == "Instance" then
        return "<" .. value.ClassName .. ":" .. safeFullName(value) .. ">"
    elseif kind == "string" then
        local s = value
        if #s > 250 then
            s = string.sub(s, 1, 250) .. "...<truncated>"
        end
        return string.format("%q", s)
    elseif kind == "table" then
        if seen[value] then
            return "<cycle>"
        end

        seen[value] = true
        local parts = {}
        local n = 0

        for k, v in pairs(value) do
            n += 1
            if n > 20 then
                parts[#parts + 1] = "...<more>"
                break
            end

            parts[#parts + 1] =
                "[" .. shortValue(k, depth + 1, seen) .. "]=" ..
                shortValue(v, depth + 1, seen)
        end

        seen[value] = nil
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return tostring(value)
    end
end

local function argsToText(...)
    local packed = table.pack(...)
    local parts = {}

    for i = 1, packed.n do
        parts[#parts + 1] = shortValue(packed[i], 0, {})
    end

    return "[" .. table.concat(parts, ", ") .. "]"
end

local function shouldWatch(obj)
    local path = string.lower(safeFullName(obj))

    for _, word in ipairs(watchWords) do
        if string.find(path, word, 1, true) then
            return true
        end
    end

    return false
end

local function watchIncoming(remote)
    if watchedEvents[remote] then
        return
    end

    if not (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
        return
    end

    if not shouldWatch(remote) then
        return
    end

    watchedEvents[remote] = true

    local ok = pcall(function()
        remote.OnClientEvent:Connect(function(...)
            add("")
            add("[PASSIVE IN] " .. safeFullName(remote))
            add("ARGS = " .. argsToText(...))
            scheduleRefresh()
        end)
    end)

    if not ok then
        watchedEvents[remote] = nil
    end
end

local function logInterestingInstance(obj, reason)
    if not shouldWatch(obj) then
        return
    end

    add("")
    add("[REPLICATED " .. reason .. "] " .. obj.ClassName .. " | " .. safeFullName(obj))

    local okAttrs, attrs = pcall(function()
        return obj:GetAttributes()
    end)

    if okAttrs and next(attrs) ~= nil then
        add("ATTRS = " .. shortValue(attrs, 0, {}))
    end

    scheduleRefresh()
end

local workspaceWatchInstalled = false
local function installWorkspaceWatch()
    if workspaceWatchInstalled then return end
    workspaceWatchInstalled = true

    workspace.DescendantAdded:Connect(function(obj)
        logInterestingInstance(obj, "ADD")
    end)

    workspace.DescendantRemoving:Connect(function(obj)
        if shouldWatch(obj) then
            add("")
            add("[REPLICATED REMOVE] " .. obj.ClassName .. " | " .. safeFullName(obj))
            scheduleRefresh()
        end
    end)
end

local function clipboard(text)
    local tried = {}

    local function tryFn(name, fn)
        if type(fn) ~= "function" then
            return false
        end

        tried[#tried + 1] = name
        local ok = pcall(fn, text)
        if ok then
            return true, name
        end
        return false
    end

    local env = _G
    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then
            env = value
        end
    end

    local synTable = rawget(env, "syn")
    local candidates = {
        {"setclipboard", env.setclipboard},
        {"toclipboard", env.toclipboard},
        {"setrbxclipboard", env.setrbxclipboard},
        {"writeclipboard", env.writeclipboard},
        {"_G.setclipboard", _G.setclipboard},
        {"_G.toclipboard", _G.toclipboard},
        {"syn.set_clipboard", type(synTable) == "table" and synTable.set_clipboard or nil},
        {"syn.setclipboard", type(synTable) == "table" and synTable.setclipboard or nil}
    }

    for _, item in ipairs(candidates) do
        local ok, method = tryFn(item[1], item[2])
        if ok then return true, method end
    end

    local lowerClipboard = rawget(env, "clipboard")
    if type(lowerClipboard) == "table" then
        local ok, method = tryFn("clipboard.set", lowerClipboard.set)
        if ok then return true, method end
    end

    local upperClipboard = rawget(env, "Clipboard")
    if type(upperClipboard) == "table" then
        local ok, method = tryFn("Clipboard.set", upperClipboard.set)
        if ok then return true, method end
    end

    return false, (#tried > 0 and table.concat(tried, ", ") or "ninguna API conocida detectada")
end

local COPY_FALLBACK_CHUNK_SIZE = 8000
local fallbackChunk = 1

local function selectAllText()
    pcall(function()
        box:CaptureFocus()
        box.CursorPosition = #box.Text + 1
        box.SelectionStart = 1
    end)
end

local function saveReport()
    local text = table.concat(report, "\n")

    if type(writefile) == "function" then
        local ok, err = pcall(function()
            writefile("RobaUnHuevo_Audit.txt", text)
        end)

        if ok then
            status.Text = "Guardado: RobaUnHuevo_Audit.txt"
            saveButton.Text = "GUARDADO"
            task.delay(1.5, function()
                if saveButton and saveButton.Parent then
                    saveButton.Text = "GUARDAR TXT"
                end
            end)
            return true
        else
            status.Text = "writefile fallo: " .. tostring(err)
        end
    else
        status.Text = "Este executor no expone writefile"
    end

    return false
end

saveButton.MouseButton1Click:Connect(saveReport)

local function getHttpRequest()
    local env = _G

    if type(getgenv) == "function" then
        local ok, value = pcall(getgenv)
        if ok and type(value) == "table" then
            env = value
        end
    end

    local candidates = {
        env.request,
        env.http_request,
        env.httprequest,
        _G.request,
        _G.http_request,
        _G.httprequest
    }

    local synTable = rawget(env, "syn")
    if type(synTable) == "table" then
        candidates[#candidates + 1] = synTable.request
    end

    local httpTable = rawget(env, "http")
    if type(httpTable) == "table" then
        candidates[#candidates + 1] = httpTable.request
    end

    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return fn
        end
    end

    return nil
end

local function makeUploadReport()
    local text = table.concat(report, "\n")

    -- Evita incluir identificadores personales si alguna version anterior
    -- del reporte los agrego.
    text = string.gsub(text, "UserId:%s*%d+\n?", "")

    return text
end

local function uploadReport()
    local requestFn = getHttpRequest()

    if type(requestFn) ~= "function" then
        status.Text = "SUBIR: Delta no expone request/http_request a Lua"
        uploadButton.Text = "SIN HTTP"
        return
    end

    local body = makeUploadReport()

    if #body == 0 then
        status.Text = "SUBIR: aun no hay reporte"
        return
    end

    uploadButton.Text = "SUBIENDO..."
    status.Text = "Subiendo reporte temporal a paste.rs..."

    task.spawn(function()
        local ok, response = pcall(function()
            return requestFn({
                Url = "https://paste.rs/",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "text/plain; charset=utf-8"
                },
                Body = body
            })
        end)

        if not ok then
            status.Text = "SUBIR fallo: " .. tostring(response)
            uploadButton.Text = "REINTENTAR"
            return
        end

        local code = response.StatusCode or response.Status or response.status_code or response.status
        local responseBody = response.Body or response.body or ""

        responseBody = tostring(responseBody)
        responseBody = string.gsub(responseBody, "^%s+", "")
        responseBody = string.gsub(responseBody, "%s+$", "")

        local function finishUploaded(url, serviceName)
            add("")
            add("===== REPORTE TEMPORAL SUBIDO =====")
            add(url)
            add("Servicio: " .. tostring(serviceName))
            add("Nota: cualquiera con este enlace puede leer el reporte.")
            refresh()

            local copied = clipboard(url)
            if copied then
                status.Text = "SUBIDO. URL copiada: " .. url
            else
                status.Text = "SUBIDO: " .. url
            end

            uploadButton.Text = "SUBIDO"
        end

        if tonumber(code) == 201 and string.match(responseBody, "^https?://") then
            finishUploaded(responseBody, "paste.rs")
            return
        end

        -- paste.rs puede devolver 500 por rate limit/servicio.
        -- Si falla, usamos paste.centos.org como respaldo.
        status.Text = "paste.rs fallo (HTTP " .. tostring(code) .. "). Probando respaldo..."

        local function urlEncode(s)
            return (string.gsub(s, "([^%w%-_%.~])", function(ch)
                return string.format("%%%02X", string.byte(ch))
            end))
        end

        local fallbackBody =
            "private=1" ..
            "&lang=text" ..
            "&expire=1440" ..
            "&title=" .. urlEncode("Roba un Huevo Audit") ..
            "&text=" .. urlEncode(body)

        local ok2, response2 = pcall(function()
            return requestFn({
                Url = "https://paste.centos.org/api/create",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/x-www-form-urlencoded"
                },
                Body = fallbackBody
            })
        end)

        if not ok2 then
            status.Text = "SUBIR fallo en ambos servicios: " .. tostring(response2)
            uploadButton.Text = "REINTENTAR"
            return
        end

        local code2 = response2.StatusCode or response2.Status or response2.status_code or response2.status
        local body2 = tostring(response2.Body or response2.body or "")
        body2 = string.gsub(body2, "^%s+", "")
        body2 = string.gsub(body2, "%s+$", "")

        if tonumber(code2) and tonumber(code2) >= 200 and tonumber(code2) < 300 and string.match(body2, "^https?://") then
            finishUploaded(body2, "paste.centos.org")
        else
            status.Text =
                "SUBIR fallo. paste.rs HTTP " .. tostring(code) ..
                " | respaldo HTTP " .. tostring(code2) ..
                ": " .. string.sub(body2, 1, 160)
            uploadButton.Text = "REINTENTAR"
        end
    end)
end

uploadButton.MouseButton1Click:Connect(uploadReport)

copyButton.MouseButton1Click:Connect(function()
    local text = table.concat(report, "\n")

    if #text == 0 then
        status.Text = "Todavia no hay resultados para copiar"
        return
    end

    -- Primero intenta copiar TODO el reporte de una sola vez.
    local ok, method = clipboard(text)
    if ok then
        copyButton.Text = "COPIADO TODO"
        status.Text = "Reporte completo copiado con " .. tostring(method) .. " (" .. tostring(#text) .. " caracteres)"
        fallbackChunk = 1

        task.delay(1.8, function()
            if copyButton and copyButton.Parent then
                copyButton.Text = "COPIAR TODO"
            end
        end)
        return
    end

    -- Si el executor/portapapeles rechaza el texto completo, usa bloques como respaldo.
    local totalChunks = math.max(1, math.ceil(#text / COPY_FALLBACK_CHUNK_SIZE))
    if fallbackChunk > totalChunks then
        fallbackChunk = 1
    end

    local first = ((fallbackChunk - 1) * COPY_FALLBACK_CHUNK_SIZE) + 1
    local last = math.min(fallbackChunk * COPY_FALLBACK_CHUNK_SIZE, #text)
    local chunk = string.sub(text, first, last)

    local okChunk, methodChunk = clipboard(chunk)
    if okChunk then
        local copiedNow = fallbackChunk
        status.Text = string.format(
            "No se pudo copiar todo. Copiado bloque %d/%d con %s.",
            copiedNow,
            totalChunks,
            tostring(methodChunk)
        )

        fallbackChunk += 1
        if fallbackChunk > totalChunks then
            fallbackChunk = 1
        end

        copyButton.Text = string.format("BLOQUE %d/%d", fallbackChunk, totalChunks)
    else
        copyButton.Text = "SELECCIONADO"
        status.Text = "Clipboard Lua no disponible. Texto seleccionado para copiar manualmente."
        selectAllText()
    end
end)

task.spawn(function()
    local ok, err = xpcall(function()
        add("ROBA UN HUEVO - CLIENT EXPOSURE AUDIT")
        add("PlaceId: " .. tostring(game.PlaceId))
        add("JobId actual: " .. tostring(game.JobId))
        add("")
        refresh()

        local direct = ReplicatedStorage:GetChildren()
        add("===== NIVEL RAIZ DE REPLICATEDSTORAGE =====")
        add("Hijos directos: " .. tostring(#direct))
        for i, obj in ipairs(direct) do
            add(string.format("%d | %s | %s", i, obj.ClassName, obj.Name))
        end
        add("")
        refresh()

        local queue = {}
        for _, obj in ipairs(direct) do
            queue[#queue + 1] = obj
        end

        local index = 1
        local scanned = 0
        local remoteCount = 0
        local suspiciousCount = 0
        local valueCount = 0
        local attributeCount = 0

        local remotes = {}
        local suspicious = {}
        local values = {}
        local attributes = {}

        local MAX_REMOTES = 500
        local MAX_SUSPICIOUS = 400
        local MAX_VALUES = 300
        local MAX_ATTRIBUTES = 300

        while index <= #queue do
            local obj = queue[index]
            index += 1
            scanned += 1

            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
                remoteCount += 1
                if #remotes < MAX_REMOTES then
                    remotes[#remotes + 1] = obj.ClassName .. " | " .. safeFullName(obj)
                end

                watchIncoming(obj)
            end

            if interesting(obj.Name) then
                suspiciousCount += 1
                if #suspicious < MAX_SUSPICIOUS then
                    suspicious[#suspicious + 1] = obj.ClassName .. " | " .. safeFullName(obj)
                end
            end

            if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
                local okValue, value = pcall(function() return obj.Value end)
                if okValue and (interesting(obj.Name) or interesting(value)) then
                    valueCount += 1
                    if #values < MAX_VALUES then
                        values[#values + 1] = safeFullName(obj) .. " = " .. tostring(value)
                    end
                end
            end

            local okAttrs, attrs = pcall(function()
                return obj:GetAttributes()
            end)
            if okAttrs then
                for name, value in pairs(attrs) do
                    if interesting(name) or interesting(value) then
                        attributeCount += 1
                        if #attributes < MAX_ATTRIBUTES then
                            attributes[#attributes + 1] =
                                safeFullName(obj) .. " | " .. tostring(name) .. " = " .. tostring(value)
                        end
                    end
                end
            end

            local okChildren, children = pcall(function()
                return obj:GetChildren()
            end)
            if okChildren then
                for _, child in ipairs(children) do
                    queue[#queue + 1] = child
                end
            end

            if scanned % 200 == 0 then
                status.Text = string.format(
                    "Escaneados: %d | pendientes: %d | remotes: %d",
                    scanned,
                    math.max(0, #queue - index + 1),
                    remoteCount
                )
                task.wait()
            end
        end

        add("===== RESUMEN =====")
        add("Objetos escaneados: " .. scanned)
        add("Remotes encontrados: " .. remoteCount)
        add("Nombres interesantes: " .. suspiciousCount)
        add("Values interesantes: " .. valueCount)
        add("Attributes interesantes: " .. attributeCount)
        add("")

        add("===== REMOTES =====")
        for _, line in ipairs(remotes) do add(line) end
        if remoteCount > #remotes then
            add("... truncado. Total real: " .. remoteCount)
        end
        add("")

        add("===== OBJETOS / NOMBRES INTERESANTES =====")
        for _, line in ipairs(suspicious) do add(line) end
        if suspiciousCount > #suspicious then
            add("... truncado. Total real: " .. suspiciousCount)
        end
        add("")

        add("===== VALUES INTERESANTES =====")
        for _, line in ipairs(values) do add(line) end
        if valueCount > #values then
            add("... truncado. Total real: " .. valueCount)
        end
        add("")

        add("===== ATTRIBUTES INTERESANTES =====")
        for _, line in ipairs(attributes) do add(line) end
        if attributeCount > #attributes then
            add("... truncado. Total real: " .. attributeCount)
        end

        add("")
        add("===== PASSIVE LOGGER ACTIVO =====")
        add("Observa RemoteEvents entrantes relacionados con huevos/servidores y objetos relevantes que aparezcan o desaparezcan en Workspace.")
        add("No ejecuta ningun RemoteFunction ni RemoteEvent.")
        add("Juega normalmente, abre interfaces y despues pulsa COPIAR TODO.")

        installWorkspaceWatch()

        refresh()
        status.Text = string.format(
            "TERMINADO | %d objetos | %d remotes | LOGGER PASIVO ACTIVO",
            scanned,
            remoteCount
        )

        local finalText = table.concat(report, "\n")
        if type(writefile) == "function" then
            pcall(function()
                writefile("RobaUnHuevo_Audit.txt", finalText)
            end)
        end
    end, function(message)
        return debug.traceback(tostring(message), 2)
    end)

    if not ok then
        add("")
        add("===== ERROR DEL AUDITOR =====")
        add(tostring(err))
        refresh()
        status.Text = "ERROR - copia el reporte y envíamelo"
    end
end)
