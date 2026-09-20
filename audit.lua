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
title.Size = UDim2.new(1, -370, 0, 38)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "ROBA UN HUEVO - CLIENT AUDIT v2"
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
copyButton.Position = UDim2.new(1, -346, 0, 8)
copyButton.Text = "COPIAR"
copyButton.TextSize = 14
copyButton.Parent = frame

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

    local candidates = {
        {"setclipboard", env.setclipboard},
        {"toclipboard", env.toclipboard},
        {"setrbxclipboard", env.setrbxclipboard},
        {"writeclipboard", env.writeclipboard},
        {"_G.setclipboard", _G.setclipboard},
        {"_G.toclipboard", _G.toclipboard}
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

    return false, table.concat(tried, ", ")
end

local copyChunk = 1
local COPY_CHUNK_SIZE = 8000

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

copyButton.MouseButton1Click:Connect(function()
    local text = table.concat(report, "\n")

    if #text == 0 then
        status.Text = "Todavia no hay resultados para copiar"
        return
    end

    local totalChunks = math.max(1, math.ceil(#text / COPY_CHUNK_SIZE))
    if copyChunk > totalChunks then
        copyChunk = 1
    end

    local first = ((copyChunk - 1) * COPY_CHUNK_SIZE) + 1
    local last = math.min(copyChunk * COPY_CHUNK_SIZE, #text)
    local chunk = string.sub(text, first, last)

    local ok, method = clipboard(chunk)

    if ok then
        local copiedNow = copyChunk

        if totalChunks == 1 then
            copyButton.Text = "COPIADO"
            status.Text = "Copiado con " .. tostring(method)
        else
            status.Text = string.format(
                "Copiado bloque %d/%d con %s. Pegalo y pulsa COPIAR otra vez.",
                copiedNow,
                totalChunks,
                tostring(method)
            )

            copyChunk += 1
            if copyChunk > totalChunks then
                copyChunk = 1
            end

            copyButton.Text = string.format("COPIAR %d/%d", copyChunk, totalChunks)
        end
    else
        copyButton.Text = "SELECCIONADO"
        status.Text = "Clipboard no disponible. Texto seleccionado; usa Copiar de Android."
        selectAllText()
    end

    task.delay(1.8, function()
        if copyButton and copyButton.Parent and totalChunks == 1 then
            copyButton.Text = "COPIAR"
        end
    end)
end)

task.spawn(function()
    local ok, err = xpcall(function()
        add("ROBA UN HUEVO - CLIENT EXPOSURE AUDIT")
        add("PlaceId: " .. tostring(game.PlaceId))
        add("JobId actual: " .. tostring(game.JobId))
        add("UserId: " .. tostring(player.UserId))
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

        refresh()
        status.Text = string.format(
            "TERMINADO | %d objetos | %d remotes | %d coincidencias",
            scanned,
            remoteCount,
            suspiciousCount + valueCount + attributeCount
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
