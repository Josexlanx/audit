-- Roba un Huevo - Client Exposure Auditor v8
-- Read-only audit for your own Roblox experience.
-- No FireServer / InvokeServer calls are made by this auditor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, name in ipairs({
    "RobaUnHuevoAudit","EggAudit","ClientAuditGUI",
    "AuditConsole","SimpleConsoleCapture","TEST_AUDIT"
}) do
    local old = playerGui:FindFirstChild(name)
    if old then pcall(function() old:Destroy() end) end
end

local C = {
    bg = Color3.fromRGB(13,15,19),
    panel = Color3.fromRGB(20,23,29),
    panel2 = Color3.fromRGB(27,31,39),
    card = Color3.fromRGB(31,36,45),
    text = Color3.fromRGB(239,243,250),
    muted = Color3.fromRGB(154,164,180),
    accent = Color3.fromRGB(89,139,255),
    accent2 = Color3.fromRGB(113,90,255),
    green = Color3.fromRGB(69,202,134),
    amber = Color3.fromRGB(240,176,72),
    red = Color3.fromRGB(235,90,90),
    line = Color3.fromRGB(48,54,66)
}

local function corner(obj, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 10)
    x.Parent = obj
end

local function stroke(obj, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.line
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = obj
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time or .2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local gui = Instance.new("ScreenGui")
gui.Name = "RobaUnHuevoAudit"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1,1)
shade.BackgroundColor3 = Color3.new(0,0,0)
shade.BackgroundTransparency = 1
shade.BorderSizePixel = 0
shade.Parent = gui

local shell = Instance.new("Frame")
shell.AnchorPoint = Vector2.new(.5,.5)
shell.Position = UDim2.fromScale(.5,.5)
shell.Size = UDim2.new(.92,0,.84,0)
shell.BackgroundColor3 = C.bg
shell.BorderSizePixel = 0
shell.ClipsDescendants = true
shell.Parent = gui
corner(shell,16)
stroke(shell,Color3.fromRGB(61,70,86),.15)

local scale = Instance.new("UIScale")
scale.Scale = .94
scale.Parent = shell

tween(shade,.22,{BackgroundTransparency=.48})
tween(scale,.28,{Scale=1},Enum.EasingStyle.Back)

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1,0,0,58)
topbar.BackgroundColor3 = C.panel
topbar.BorderSizePixel = 0
topbar.Parent = shell

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(0,330,1,0)
brand.Position = UDim2.new(0,18,0,0)
brand.BackgroundTransparency = 1
brand.Text = "EGG AUDIT  •  v8"
brand.TextColor3 = C.text
brand.Font = Enum.Font.GothamBold
brand.TextSize = 20
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = topbar

local livePill = Instance.new("TextLabel")
livePill.Size = UDim2.new(0,112,0,28)
livePill.Position = UDim2.new(0,182,0,15)
livePill.BackgroundColor3 = Color3.fromRGB(61,53,31)
livePill.TextColor3 = Color3.fromRGB(247,205,113)
livePill.Text = "● ESCANEANDO"
livePill.Font = Enum.Font.GothamBold
livePill.TextSize = 11
livePill.Parent = topbar
corner(livePill,14)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,38,0,34)
minimize.Position = UDim2.new(1,-88,0,12)
minimize.BackgroundColor3 = C.card
minimize.Text = "—"
minimize.TextColor3 = C.text
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.AutoButtonColor = false
minimize.Parent = topbar
corner(minimize,9)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,38,0,34)
closeButton.Position = UDim2.new(1,-44,0,12)
closeButton.BackgroundColor3 = Color3.fromRGB(74,34,39)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255,167,175)
closeButton.TextSize = 22
closeButton.Font = Enum.Font.GothamBold
closeButton.AutoButtonColor = false
closeButton.Parent = topbar
corner(closeButton,9)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-410,0,20)
status.Position = UDim2.new(0,310,0,19)
status.BackgroundTransparency = 1
status.TextColor3 = C.muted
status.Text = "Preparando auditor..."
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = topbar

local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1,0,0,2)
progressTrack.Position = UDim2.new(0,0,1,-2)
progressTrack.BackgroundColor3 = Color3.fromRGB(36,40,48)
progressTrack.BorderSizePixel = 0
progressTrack.Parent = topbar

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0,0,1,0)
progressFill.BackgroundColor3 = C.accent
progressFill.BorderSizePixel = 0
progressFill.Parent = progressTrack

local body = Instance.new("Frame")
body.Size = UDim2.new(1,0,1,-58)
body.Position = UDim2.new(0,0,0,58)
body.BackgroundTransparency = 1
body.Parent = shell

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,172,1,0)
sidebar.BackgroundColor3 = C.panel
sidebar.BorderSizePixel = 0
sidebar.Parent = body

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1,-24,0,26)
sideTitle.Position = UDim2.new(0,12,0,14)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "APARTADOS"
sideTitle.TextColor3 = C.muted
sideTitle.TextSize = 11
sideTitle.Font = Enum.Font.GothamBold
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

local tabsHolder = Instance.new("Frame")
tabsHolder.Size = UDim2.new(1,-16,0,260)
tabsHolder.Position = UDim2.new(0,8,0,44)
tabsHolder.BackgroundTransparency = 1
tabsHolder.Parent = sidebar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0,7)
tabLayout.Parent = tabsHolder

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-172,1,0)
content.Position = UDim2.new(0,172,0,0)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.Parent = body

local pages = {}
local tabButtons = {}
local currentTab = nil

local function makePage(name)
    local p = Instance.new("Frame")
    p.Name = name
    p.Size = UDim2.fromScale(1,1)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = content
    pages[name] = p
    return p
end

local function switchTab(name)
    if currentTab == name then return end
    currentTab = name

    for n,p in pairs(pages) do
        p.Visible = (n == name)
        if n == name then
            p.Position = UDim2.new(0,.015,0,0)
            tween(p,.18,{Position=UDim2.new(0,0,0,0)})
        end
    end

    for n,b in pairs(tabButtons) do
        local active = (n == name)
        tween(b,.14,{
            BackgroundColor3 = active and Color3.fromRGB(42,59,91) or C.panel2,
            TextColor3 = active and C.text or C.muted
        })
    end
end

local function makeTab(name,label)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = C.panel2
    b.TextColor3 = C.muted
    b.Text = "   " .. label
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.Parent = tabsHolder
    corner(b,9)
    b.MouseEnter:Connect(function()
        if currentTab ~= name then tween(b,.12,{BackgroundColor3=Color3.fromRGB(34,39,49)}) end
    end)
    b.MouseLeave:Connect(function()
        if currentTab ~= name then tween(b,.12,{BackgroundColor3=C.panel2}) end
    end)
    b.MouseButton1Click:Connect(function()
        tween(b,.08,{Size=UDim2.new(1,-4,0,38)})
        task.delay(.08,function()
            if b.Parent then tween(b,.1,{Size=UDim2.new(1,0,0,40)}) end
        end)
        switchTab(name)
    end)
    tabButtons[name] = b
end

local overviewPage = makePage("overview")
local remotesPage = makePage("remotes")
local findingsPage = makePage("findings")
local loggerPage = makePage("logger")
local exportPage = makePage("export")

makeTab("overview","⌂  Resumen")
makeTab("remotes","⇄  Remotes")
makeTab("findings","⌕  Hallazgos")
makeTab("logger","●  Logger pasivo")
makeTab("export","↥  Exportar")

local function header(page,titleText,subText)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1,-36,0,30)
    h.Position = UDim2.new(0,18,0,14)
    h.BackgroundTransparency = 1
    h.Text = titleText
    h.TextColor3 = C.text
    h.Font = Enum.Font.GothamBold
    h.TextSize = 20
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = page

    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(1,-36,0,24)
    s.Position = UDim2.new(0,18,0,43)
    s.BackgroundTransparency = 1
    s.Text = subText
    s.TextColor3 = C.muted
    s.Font = Enum.Font.Gotham
    s.TextSize = 12
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.Parent = page
end

header(overviewPage,"Resumen de exposición","Vista rápida del estado visible para un cliente normal.")
header(remotesPage,"Remotes replicados","RemoteEvent, RemoteFunction y UnreliableRemoteEvent visibles.")
header(findingsPage,"Hallazgos relevantes","Objetos, values y atributos relacionados con huevos, servidores y rarezas.")
header(loggerPage,"Logger pasivo","Solo observa eventos entrantes y cambios replicados; no dispara remotes.")
header(exportPage,"Exportar reporte","Opciones para copiar, guardar o intentar subir el reporte.")

local stats = {}
local function statCard(parent,x,titleText,valueText,accentColor)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(.235,-8,0,84)
    card.Position = UDim2.new(x,18,0,84)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.Parent = parent
    corner(card,12)
    stroke(card,C.line,.35)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,4,1,-20)
    bar.Position = UDim2.new(0,10,0,10)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.Parent = card
    corner(bar,3)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-30,0,22)
    title.Position = UDim2.new(0,24,0,10)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = C.muted
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(1,-30,0,36)
    value.Position = UDim2.new(0,24,0,34)
    value.BackgroundTransparency = 1
    value.Text = valueText
    value.TextColor3 = C.text
    value.Font = Enum.Font.GothamBold
    value.TextSize = 23
    value.TextXAlignment = Enum.TextXAlignment.Left
    value.Parent = card

    stats[titleText] = value
end

statCard(overviewPage,0,"OBJETOS","0",C.accent)
statCard(overviewPage,.245,"REMOTES","0",C.green)
statCard(overviewPage,.49,"HALLAZGOS","0",C.amber)
statCard(overviewPage,.735,"LOGGER","ESPERA",C.accent2)

local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1,-36,1,-196)
infoCard.Position = UDim2.new(0,18,0,184)
infoCard.BackgroundColor3 = C.panel
infoCard.BorderSizePixel = 0
infoCard.Parent = overviewPage
corner(infoCard,12)
stroke(infoCard,C.line,.4)

local overviewText = Instance.new("TextLabel")
overviewText.Size = UDim2.new(1,-28,1,-28)
overviewText.Position = UDim2.new(0,14,0,14)
overviewText.BackgroundTransparency = 1
overviewText.TextColor3 = C.text
overviewText.TextSize = 13
overviewText.Font = Enum.Font.Code
overviewText.TextXAlignment = Enum.TextXAlignment.Left
overviewText.TextYAlignment = Enum.TextYAlignment.Top
overviewText.TextWrapped = true
overviewText.Text = "Inicializando..."
overviewText.Parent = infoCard

local function makeLogBox(page)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-36,1,-88)
    box.Position = UDim2.new(0,18,0,74)
    box.BackgroundColor3 = C.panel
    box.BorderSizePixel = 0
    box.TextColor3 = Color3.fromRGB(220,227,238)
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.TextWrapped = false
    box.MultiLine = true
    box.ClearTextOnFocus = false
    box.TextEditable = true
    box.Text = ""
    box.Parent = page
    corner(box,12)
    stroke(box,C.line,.4)
    return box
end

local remotesBox = makeLogBox(remotesPage)
local findingsBox = makeLogBox(findingsPage)
local loggerBox = makeLogBox(loggerPage)

local exportCard = Instance.new("Frame")
exportCard.Size = UDim2.new(1,-36,0,230)
exportCard.Position = UDim2.new(0,18,0,84)
exportCard.BackgroundColor3 = C.panel
exportCard.BorderSizePixel = 0
exportCard.Parent = exportPage
corner(exportCard,12)
stroke(exportCard,C.line,.4)

local exportInfo = Instance.new("TextLabel")
exportInfo.Size = UDim2.new(1,-28,0,54)
exportInfo.Position = UDim2.new(0,14,0,14)
exportInfo.BackgroundTransparency = 1
exportInfo.Text = "El reporte puede ser grande. Copiar intentará usar el portapapeles del executor; Guardar TXT usa writefile si está disponible."
exportInfo.TextWrapped = true
exportInfo.TextColor3 = C.muted
exportInfo.Font = Enum.Font.Gotham
exportInfo.TextSize = 12
exportInfo.TextXAlignment = Enum.TextXAlignment.Left
exportInfo.TextYAlignment = Enum.TextYAlignment.Top
exportInfo.Parent = exportCard

local function actionButton(parent,text,x,color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(.31,-8,0,46)
    b.Position = UDim2.new(x,14,0,82)
    b.BackgroundColor3 = color
    b.TextColor3 = C.text
    b.Text = text
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b,10)
    b.MouseEnter:Connect(function() tween(b,.12,{BackgroundTransparency=.12}) end)
    b.MouseLeave:Connect(function() tween(b,.12,{BackgroundTransparency=0}) end)
    b.MouseButton1Down:Connect(function() tween(b,.07,{Size=UDim2.new(.31,-12,0,43)}) end)
    b.MouseButton1Up:Connect(function() tween(b,.09,{Size=UDim2.new(.31,-8,0,46)}) end)
    return b
end

local copyButton = actionButton(exportCard,"COPIAR TODO",0,C.accent)
local saveButton = actionButton(exportCard,"GUARDAR TXT",.335,Color3.fromRGB(51,128,91))
local uploadButton = actionButton(exportCard,"SUBIR (BETA)",.67,Color3.fromRGB(111,75,175))

local exportStatus = Instance.new("TextLabel")
exportStatus.Size = UDim2.new(1,-28,0,62)
exportStatus.Position = UDim2.new(0,14,0,146)
exportStatus.BackgroundColor3 = C.panel2
exportStatus.TextColor3 = C.muted
exportStatus.Text = "Sin acciones todavía."
exportStatus.TextWrapped = true
exportStatus.TextSize = 12
exportStatus.Font = Enum.Font.Gotham
exportStatus.TextXAlignment = Enum.TextXAlignment.Left
exportStatus.TextYAlignment = Enum.TextYAlignment.Center
exportStatus.Parent = exportCard
corner(exportStatus,9)

local report = {}
local remotesLines = {}
local findingsLines = {}
local loggerLines = {}
local counters = {objects=0, remotes=0, findings=0}
local rootLines = {}

local function fullReport()
    return table.concat(report,"\n")
end

local function refreshOverview()
    stats["OBJETOS"].Text = tostring(counters.objects)
    stats["REMOTES"].Text = tostring(counters.remotes)
    stats["HALLAZGOS"].Text = tostring(counters.findings)

    local txt = {
        "PlaceId: " .. tostring(game.PlaceId),
        "JobId actual: " .. tostring(game.JobId),
        "",
        "Estado: " .. status.Text,
        "",
        "Raíz de ReplicatedStorage:"
    }
    for i=1,math.min(#rootLines,21) do txt[#txt+1] = rootLines[i] end
    overviewText.Text = table.concat(txt,"\n")
end

local function refreshBoxes()
    remotesBox.Text = table.concat(remotesLines,"\n")
    findingsBox.Text = table.concat(findingsLines,"\n")
    loggerBox.Text = table.concat(loggerLines,"\n")
    refreshOverview()
end

local function add(line)
    report[#report+1] = tostring(line)
end

local function addRemote(line)
    line = tostring(line)
    remotesLines[#remotesLines+1] = line
    add(line)
end

local function addFinding(line)
    line = tostring(line)
    findingsLines[#findingsLines+1] = line
    add(line)
end

local function addLogger(line)
    line = tostring(line)
    loggerLines[#loggerLines+1] = line
    add(line)
    stats["LOGGER"].Text = "ACTIVO"
    stats["LOGGER"].TextColor3 = C.green
    loggerBox.Text = table.concat(loggerLines,"\n")
end

local keywords = {
    "egg","huevo","server","servers","job","jobid","spawn","rare","rarity",
    "secret","legendary","mythic","global","best","index","plot","base",
    "machine","remote","network","data","cache"
}

local function interesting(value)
    local s = string.lower(tostring(value))
    for _,word in ipairs(keywords) do
        if string.find(s,word,1,true) then return true end
    end
    return false
end

local function safeFullName(obj)
    local ok,result = pcall(function() return obj:GetFullName() end)
    return ok and result or tostring(obj)
end

local watchWords = {
    "eggworld","contentcreatorremotes","idlerescue","penroster",
    "homestead","profilemirror","liveevents","server","job","egg","rarity"
}

local watchedEvents = {}

local function shortValue(value,depth,seen)
    depth = depth or 0
    seen = seen or {}
    if depth > 3 then return "<max-depth>" end
    local kind = typeof(value)

    if kind == "Instance" then
        return "<"..value.ClassName..":"..safeFullName(value)..">"
    elseif kind == "string" then
        local s = value
        if #s > 250 then s = string.sub(s,1,250).."...<truncated>" end
        return string.format("%q",s)
    elseif kind == "table" then
        if seen[value] then return "<cycle>" end
        seen[value] = true
        local parts,n = {},0
        for k,v in pairs(value) do
            n += 1
            if n > 20 then parts[#parts+1] = "...<more>" break end
            parts[#parts+1] = "["..shortValue(k,depth+1,seen).."]="..shortValue(v,depth+1,seen)
        end
        seen[value] = nil
        return "{"..table.concat(parts,", ").."}"
    end
    return tostring(value)
end

local function argsToText(...)
    local packed = table.pack(...)
    local parts = {}
    for i=1,packed.n do parts[#parts+1] = shortValue(packed[i],0,{}) end
    return "["..table.concat(parts,", ").."]"
end

local function shouldWatch(obj)
    local path = string.lower(safeFullName(obj))
    for _,word in ipairs(watchWords) do
        if string.find(path,word,1,true) then return true end
    end
    return false
end

local function watchIncoming(remote)
    if watchedEvents[remote] then return end
    if not (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then return end
    if not shouldWatch(remote) then return end
    watchedEvents[remote] = true

    local ok = pcall(function()
        remote.OnClientEvent:Connect(function(...)
            addLogger("")
            addLogger("[PASSIVE IN] "..safeFullName(remote))
            addLogger("ARGS = "..argsToText(...))
        end)
    end)
    if not ok then watchedEvents[remote] = nil end
end

local workspaceWatchInstalled = false
local function installWorkspaceWatch()
    if workspaceWatchInstalled then return end
    workspaceWatchInstalled = true

    workspace.DescendantAdded:Connect(function(obj)
        if shouldWatch(obj) then
            addLogger("")
            addLogger("[REPLICATED ADD] "..obj.ClassName.." | "..safeFullName(obj))
            local ok,attrs = pcall(function() return obj:GetAttributes() end)
            if ok and next(attrs) ~= nil then addLogger("ATTRS = "..shortValue(attrs,0,{})) end
        end
    end)

    workspace.DescendantRemoving:Connect(function(obj)
        if shouldWatch(obj) then
            addLogger("")
            addLogger("[REPLICATED REMOVE] "..obj.ClassName.." | "..safeFullName(obj))
        end
    end)
end

local function clipboard(text)
    local env = _G
    if type(getgenv) == "function" then
        local ok,value = pcall(getgenv)
        if ok and type(value) == "table" then env = value end
    end

    local synTable = rawget(env,"syn")
    local candidates = {
        env.setclipboard,env.toclipboard,env.setrbxclipboard,env.writeclipboard,
        _G.setclipboard,_G.toclipboard,
        type(synTable)=="table" and synTable.set_clipboard or nil,
        type(synTable)=="table" and synTable.setclipboard or nil
    }
    for _,fn in ipairs(candidates) do
        if type(fn)=="function" then
            local ok = pcall(fn,text)
            if ok then return true end
        end
    end
    return false
end

local function saveReport()
    local text = fullReport()
    if type(writefile) ~= "function" then
        exportStatus.Text = "Este executor no expone writefile."
        return
    end
    local ok,err = pcall(function() writefile("RobaUnHuevo_Audit.txt",text) end)
    exportStatus.Text = ok and "Guardado como RobaUnHuevo_Audit.txt en el workspace del executor." or ("Error: "..tostring(err))
end

local function getHttpRequest()
    local env = _G
    if type(getgenv)=="function" then
        local ok,value = pcall(getgenv)
        if ok and type(value)=="table" then env=value end
    end
    local list = {env.request,env.http_request,env.httprequest,_G.request,_G.http_request,_G.httprequest}
    local synTable = rawget(env,"syn")
    if type(synTable)=="table" then list[#list+1] = synTable.request end
    for _,fn in ipairs(list) do if type(fn)=="function" then return fn end end
end

copyButton.MouseButton1Click:Connect(function()
    local text = fullReport()
    exportStatus.Text = clipboard(text) and "Reporte completo copiado al portapapeles." or "Delta no expone una API de clipboard usable por el script."
end)

saveButton.MouseButton1Click:Connect(saveReport)

uploadButton.MouseButton1Click:Connect(function()
    local requestFn = getHttpRequest()
    if not requestFn then
        exportStatus.Text = "Delta no expone request/http_request."
        return
    end

    exportStatus.Text = "Intentando subida temporal..."
    local body = string.gsub(fullReport(),"UserId:%s*%d+\n?","")

    task.spawn(function()
        local ok,res = pcall(function()
            return requestFn({
                Url="https://dpaste.org/api/",
                Method="POST",
                Headers={
                    ["Content-Type"]="application/x-www-form-urlencoded",
                    ["Accept"]="text/plain"
                },
                Body="format=url&expires=3600&lexer=text&content="..string.gsub(body,"([^%w%-_%.~])",function(ch)
                    return string.format("%%%02X",string.byte(ch))
                end)
            })
        end)

        if not ok then
            exportStatus.Text = "La subida falló: "..tostring(res)
            return
        end

        local code = res.StatusCode or res.Status or res.status_code or res.status
        local responseBody = tostring(res.Body or res.body or "")
        responseBody = string.gsub(responseBody,"^%s+","")
        responseBody = string.gsub(responseBody,"%s+$","")

        if tonumber(code) and tonumber(code)>=200 and tonumber(code)<300 and string.match(responseBody,"^https?://") then
            exportStatus.Text = "Subido: "..responseBody
            clipboard(responseBody)
        else
            exportStatus.Text = "Subida no disponible (HTTP "..tostring(code).."). Usa Guardar TXT."
        end
    end)
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(shell,.2,{Size=UDim2.new(.92,0,0,58)})
        minimize.Text = "+"
    else
        tween(shell,.22,{Size=UDim2.new(.92,0,.84,0)},Enum.EasingStyle.Quad)
        minimize.Text = "—"
    end
end)

closeButton.MouseButton1Click:Connect(function()
    tween(scale,.16,{Scale=.94})
    tween(shade,.16,{BackgroundTransparency=1})
    task.delay(.17,function() if gui then gui:Destroy() end end)
end)

local dragging,dragStart,startPos
topbar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=shell.Position
    end
end)
topbar.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        shell.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

switchTab("overview")

task.spawn(function()
    local ok,err = xpcall(function()
        add("ROBA UN HUEVO - CLIENT EXPOSURE AUDIT v8")
        add("PlaceId: "..tostring(game.PlaceId))
        add("JobId actual: "..tostring(game.JobId))
        add("")

        local direct = ReplicatedStorage:GetChildren()
        rootLines[#rootLines+1] = "Hijos directos: "..#direct
        for i,obj in ipairs(direct) do
            rootLines[#rootLines+1] = string.format("%d | %s | %s",i,obj.ClassName,obj.Name)
        end
        refreshOverview()

        local queue = {}
        for _,obj in ipairs(direct) do queue[#queue+1]=obj end

        local index = 1
        local remotes = {}
        local suspicious = {}
        local values = {}
        local attributes = {}

        while index <= #queue do
            local obj = queue[index]
            index += 1
            counters.objects += 1

            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
                counters.remotes += 1
                if #remotes < 500 then
                    remotes[#remotes+1] = obj.ClassName.." | "..safeFullName(obj)
                end
                watchIncoming(obj)
            end

            if interesting(obj.Name) then
                counters.findings += 1
                if #suspicious < 400 then suspicious[#suspicious+1] = obj.ClassName.." | "..safeFullName(obj) end
            end

            if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
                local okValue,value = pcall(function() return obj.Value end)
                if okValue and (interesting(obj.Name) or interesting(value)) then
                    counters.findings += 1
                    if #values < 300 then values[#values+1] = safeFullName(obj).." = "..tostring(value) end
                end
            end

            local okAttrs,attrs = pcall(function() return obj:GetAttributes() end)
            if okAttrs then
                for name,value in pairs(attrs) do
                    if interesting(name) or interesting(value) then
                        counters.findings += 1
                        if #attributes < 300 then
                            attributes[#attributes+1] = safeFullName(obj).." | "..tostring(name).." = "..tostring(value)
                        end
                    end
                end
            end

            local okChildren,children = pcall(function() return obj:GetChildren() end)
            if okChildren then
                for _,child in ipairs(children) do queue[#queue+1]=child end
            end

            if counters.objects % 200 == 0 then
                local pending = math.max(0,#queue-index+1)
                status.Text = string.format("Escaneando %d objetos  •  %d pendientes  •  %d remotes",counters.objects,pending,counters.remotes)
                local denom = math.max(counters.objects+pending,1)
                tween(progressFill,.12,{Size=UDim2.new(counters.objects/denom,0,1,0)})
                refreshOverview()
                task.wait()
            end
        end

        add("===== REMOTES =====")
        for _,line in ipairs(remotes) do addRemote(line) end

        add("===== HALLAZGOS =====")
        findingsLines[#findingsLines+1] = "== OBJETOS =="
        for _,line in ipairs(suspicious) do addFinding(line) end
        findingsLines[#findingsLines+1] = ""
        findingsLines[#findingsLines+1] = "== VALUES =="
        for _,line in ipairs(values) do addFinding(line) end
        findingsLines[#findingsLines+1] = ""
        findingsLines[#findingsLines+1] = "== ATTRIBUTES =="
        for _,line in ipairs(attributes) do addFinding(line) end

        installWorkspaceWatch()
        addLogger("===== LOGGER PASIVO ACTIVO =====")
        addLogger("Observando eventos entrantes y cambios replicados relacionados con huevos/servidores.")
        addLogger("No se ejecutan remotes desde este auditor.")

        refreshBoxes()
        status.Text = string.format("Terminado  •  %d objetos  •  %d remotes  •  logger activo",counters.objects,counters.remotes)
        livePill.Text = "● ACTIVO"
        livePill.BackgroundColor3 = Color3.fromRGB(31,74,58)
        livePill.TextColor3 = Color3.fromRGB(112,236,170)
        tween(progressFill,.25,{Size=UDim2.new(1,0,1,0)})
        stats["LOGGER"].Text = "ACTIVO"
        stats["LOGGER"].TextColor3 = C.green

        if type(writefile)=="function" then
            pcall(function() writefile("RobaUnHuevo_Audit.txt",fullReport()) end)
        end
    end,function(message)
        return debug.traceback(tostring(message),2)
    end)

    if not ok then
        status.Text = "Error del auditor"
        livePill.Text = "● ERROR"
        livePill.BackgroundColor3 = Color3.fromRGB(79,37,42)
        livePill.TextColor3 = Color3.fromRGB(255,158,167)
        addFinding("===== ERROR =====")
        addFinding(tostring(err))
        refreshBoxes()
        switchTab("findings")
    end
end)
