-- ═══════════════════════════════════════════════════════════════════════
--   TORNADO GIGANTE v23.0  |  Delta Android
--   Visual 3x maior + sucção de tudo que o jogo liberar
-- ═══════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ═══════════════════════ CONFIGURAÇÕES ═══════════════════════
local CONFIG = {
    Ativado = false,
    Raio = 250,
    Velocidade = 120,
    -- ⚡ TORNADO GIGANTE v23:
    AlturaTornado = 200,       -- Era 55 → agora 200 (3.6x maior)
    RaioVisual = 60,           -- Era 18 → agora 60 (3.3x maior)
    TamEsferaBase = 12,        -- Era 4 → agora 12 (3x maior)
    TamEsferaTopo = 22,        -- Era 7 → agora 22 (3x maior)
    NumEsferas = 60,           -- Era 32 → agora 60 (quase 2x mais)
    Rotacao = 10,
    AntiQueda = true,
    EfeitoVisual = true,
    Som = true,
    PegarJogadores = false,
    DanoJogadores = 8,
    TamMaxBloco = 800,
    AutoDetectarDesastre = true,
}

local blocosControlados = {}
local jogadoresControlados = {}
local partesTornado = {}
local somTornado = nil
local efeitoParticulas = nil
local conexaoAntiQueda = nil
local ultimaPosicaoSegura = nil
local ultimoScan = 0

-- ═══════════════════════ NETWORK OWNERSHIP ═══════════════════════
local function pegarOwnership(parte)
    pcall(function()
        if parte:CanSetNetworkOwnership() then
            parte:SetNetworkOwner(player)
        end
    end)
end

-- ═══════════════════════ GUI ═══════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TornadoGigante"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999

local Janela = Instance.new("Frame")
Janela.Name = "Janela"
Janela.Parent = ScreenGui
Janela.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Janela.BorderSizePixel = 0
Janela.Position = UDim2.new(0.05, 0, 0.1, 0)
Janela.Size = UDim2.new(0, 300, 0, 580)
Janela.Active = true
Janela.ClipsDescendants = true

local Canto = Instance.new("UICorner")
Canto.CornerRadius = UDim.new(0, 10)
Canto.Parent = Janela

local Gradiente = Instance.new("UIGradient")
Gradiente.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 40, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
Gradiente.Rotation = 90
Gradiente.Parent = Janela

-- Barra de título
local BarraTitulo = Instance.new("Frame")
BarraTitulo.Name = "BarraTitulo"
BarraTitulo.Parent = Janela
BarraTitulo.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
BarraTitulo.BorderSizePixel = 0
BarraTitulo.Size = UDim2.new(1, 0, 0, 40)

local CantoTitulo = Instance.new("UICorner")
CantoTitulo.CornerRadius = UDim.new(0, 10)
CantoTitulo.Parent = BarraTitulo

local Titulo = Instance.new("TextLabel")
Titulo.Parent = BarraTitulo
Titulo.BackgroundTransparency = 1
Titulo.Position = UDim2.new(0, 12, 0, 0)
Titulo.Size = UDim2.new(1, -85, 1, 0)
Titulo.Font = Enum.Font.GothamBold
Titulo.Text = "🌪️ TORNADO GIGANTE v23"
Titulo.TextColor3 = Color3.fromRGB(150, 230, 255)
Titulo.TextSize = 14
Titulo.TextXAlignment = Enum.TextXAlignment.Left

local BotaoMin = Instance.new("TextButton")
BotaoMin.Parent = BarraTitulo
BotaoMin.BackgroundColor3 = Color3.fromRGB(60, 120, 170)
BotaoMin.BorderSizePixel = 0
BotaoMin.Position = UDim2.new(1, -70, 0, 7)
BotaoMin.Size = UDim2.new(0, 28, 0, 26)
BotaoMin.Font = Enum.Font.GothamBold
BotaoMin.Text = "—"
BotaoMin.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoMin.TextSize = 16

local CantoMin = Instance.new("UICorner")
CantoMin.CornerRadius = UDim.new(0, 5)
CantoMin.Parent = BotaoMin

local BotaoFechar = Instance.new("TextButton")
BotaoFechar.Parent = BarraTitulo
BotaoFechar.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
BotaoFechar.BorderSizePixel = 0
BotaoFechar.Position = UDim2.new(1, -36, 0, 7)
BotaoFechar.Size = UDim2.new(0, 28, 0, 26)
BotaoFechar.Font = Enum.Font.GothamBold
BotaoFechar.Text = "×"
BotaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoFechar.TextSize = 18

local CantoFechar = Instance.new("UICorner")
CantoFechar.CornerRadius = UDim.new(0, 5)
CantoFechar.Parent = BotaoFechar

-- Área de conteúdo
local Area = Instance.new("ScrollingFrame")
Area.Parent = Janela
Area.BackgroundTransparency = 1
Area.Position = UDim2.new(0, 10, 0, 50)
Area.Size = UDim2.new(1, -20, 1, -60)
Area.CanvasSize = UDim2.new(0, 0, 0, 640)
Area.ScrollBarThickness = 5
Area.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
Area.BorderSizePixel = 0

-- Botão principal
local BotaoPrincipal = Instance.new("TextButton")
BotaoPrincipal.Parent = Area
BotaoPrincipal.BackgroundColor3 = Color3.fromRGB(30, 120, 180)
BotaoPrincipal.BorderSizePixel = 0
BotaoPrincipal.Position = UDim2.new(0, 0, 0, 0)
BotaoPrincipal.Size = UDim2.new(1, 0, 0, 60)
BotaoPrincipal.Font = Enum.Font.GothamBold
BotaoPrincipal.Text = "🌪️ ATIVAR TORNADO GIGANTE"
BotaoPrincipal.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoPrincipal.TextSize = 15

local CantoPrincipal = Instance.new("UICorner")
CantoPrincipal.CornerRadius = UDim.new(0, 8)
CantoPrincipal.Parent = BotaoPrincipal

local GradienteBotao = Instance.new("UIGradient")
GradienteBotao.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 100, 180))
}
GradienteBotao.Parent = BotaoPrincipal

-- Info
local LabelDesastre = Instance.new("TextLabel")
LabelDesastre.Parent = Area
LabelDesastre.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
LabelDesastre.BorderSizePixel = 0
LabelDesastre.Position = UDim2.new(0, 0, 0, 70)
LabelDesastre.Size = UDim2.new(1, 0, 0, 40)
LabelDesastre.Font = Enum.Font.GothamSemibold
LabelDesastre.Text = "🔍 Aguardando blocos soltos..."
LabelDesastre.TextColor3 = Color3.fromRGB(180, 220, 255)
LabelDesastre.TextSize = 12
LabelDesastre.TextWrapped = true

local CantoDesastre = Instance.new("UICorner")
CantoDesastre.CornerRadius = UDim.new(0, 6)
CantoDesastre.Parent = LabelDesastre

-- Slider Raio
local LabelRaio = Instance.new("TextLabel")
LabelRaio.Parent = Area
LabelRaio.BackgroundTransparency = 1
LabelRaio.Position = UDim2.new(0, 0, 0, 120)
LabelRaio.Size = UDim2.new(1, 0, 0, 20)
LabelRaio.Font = Enum.Font.GothamSemibold
LabelRaio.Text = "🎯 Raio de Sucção: 250"
LabelRaio.TextColor3 = Color3.fromRGB(180, 220, 255)
LabelRaio.TextSize = 13
LabelRaio.TextXAlignment = Enum.TextXAlignment.Left

local SliderRaio = Instance.new("Frame")
SliderRaio.Parent = Area
SliderRaio.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
SliderRaio.BorderSizePixel = 0
SliderRaio.Position = UDim2.new(0, 0, 0, 143)
SliderRaio.Size = UDim2.new(1, 0, 0, 10)

local CantoSliderR = Instance.new("UICorner")
CantoSliderR.CornerRadius = UDim.new(1, 0)
CantoSliderR.Parent = SliderRaio

local FillRaio = Instance.new("Frame")
FillRaio.Parent = SliderRaio
FillRaio.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
FillRaio.BorderSizePixel = 0
FillRaio.Size = UDim2.new(0.5, 0, 1, 0)

local CantoFillR = Instance.new("UICorner")
CantoFillR.CornerRadius = UDim.new(1, 0)
CantoFillR.Parent = FillRaio

local KnobRaio = Instance.new("Frame")
KnobRaio.Parent = SliderRaio
KnobRaio.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
KnobRaio.BorderSizePixel = 0
KnobRaio.Size = UDim2.new(0, 18, 0, 18)
KnobRaio.Position = UDim2.new(0.5, -9, 0, -4)

local CantoKnobR = Instance.new("UICorner")
CantoKnobR.CornerRadius = UDim.new(1, 0)
CantoKnobR.Parent = KnobRaio

-- Slider Velocidade
local LabelVel = Instance.new("TextLabel")
LabelVel.Parent = Area
LabelVel.BackgroundTransparency = 1
LabelVel.Position = UDim2.new(0, 0, 0, 165)
LabelVel.Size = UDim2.new(1, 0, 0, 20)
LabelVel.Font = Enum.Font.GothamSemibold
LabelVel.Text = "💨 Velocidade: 120"
LabelVel.TextColor3 = Color3.fromRGB(180, 255, 220)
LabelVel.TextSize = 13
LabelVel.TextXAlignment = Enum.TextXAlignment.Left

local SliderVel = Instance.new("Frame")
SliderVel.Parent = Area
SliderVel.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
SliderVel.BorderSizePixel = 0
SliderVel.Position = UDim2.new(0, 0, 0, 188)
SliderVel.Size = UDim2.new(1, 0, 0, 10)

local CantoSliderV = Instance.new("UICorner")
CantoSliderV.CornerRadius = UDim.new(1, 0)
CantoSliderV.Parent = SliderVel

local FillVel = Instance.new("Frame")
FillVel.Parent = SliderVel
FillVel.BackgroundColor3 = Color3.fromRGB(100, 220, 160)
FillVel.BorderSizePixel = 0
FillVel.Size = UDim2.new(0.3, 0, 1, 0)

local CantoFillV = Instance.new("UICorner")
CantoFillV.CornerRadius = UDim.new(1, 0)
CantoFillV.Parent = FillVel

local KnobVel = Instance.new("Frame")
KnobVel.Parent = SliderVel
KnobVel.BackgroundColor3 = Color3.fromRGB(200, 255, 230)
KnobVel.BorderSizePixel = 0
KnobVel.Size = UDim2.new(0, 18, 0, 18)
KnobVel.Position = UDim2.new(0.3, -9, 0, -4)

local CantoKnobV = Instance.new("UICorner")
CantoKnobV.CornerRadius = UDim.new(1, 0)
CantoKnobV.Parent = KnobVel

-- Slider Tamanho do Tornado (NOVO!)
local LabelTam = Instance.new("TextLabel")
LabelTam.Parent = Area
LabelTam.BackgroundTransparency = 1
LabelTam.Position = UDim2.new(0, 0, 0, 210)
LabelTam.Size = UDim2.new(1, 0, 0, 20)
LabelTam.Font = Enum.Font.GothamSemibold
LabelTam.Text = "📏 Escala Visual: 1.0x"
LabelTam.TextColor3 = Color3.fromRGB(255, 220, 180)
LabelTam.TextSize = 13
LabelTam.TextXAlignment = Enum.TextXAlignment.Left

local SliderTam = Instance.new("Frame")
SliderTam.Parent = Area
SliderTam.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
SliderTam.BorderSizePixel = 0
SliderTam.Position = UDim2.new(0, 0, 0, 233)
SliderTam.Size = UDim2.new(1, 0, 0, 10)

local CantoSliderT = Instance.new("UICorner")
CantoSliderT.CornerRadius = UDim.new(1, 0)
CantoSliderT.Parent = SliderTam

local FillTam = Instance.new("Frame")
FillTam.Parent = SliderTam
FillTam.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
FillTam.BorderSizePixel = 0
FillTam.Size = UDim2.new(0.33, 0, 1, 0)

local CantoFillT = Instance.new("UICorner")
CantoFillT.CornerRadius = UDim.new(1, 0)
CantoFillT.Parent = FillTam

local KnobTam = Instance.new("Frame")
KnobTam.Parent = SliderTam
KnobTam.BackgroundColor3 = Color3.fromRGB(255, 230, 200)
KnobTam.BorderSizePixel = 0
KnobTam.Size = UDim2.new(0, 18, 0, 18)
KnobTam.Position = UDim2.new(0.33, -9, 0, -4)

local CantoKnobT = Instance.new("UICorner")
CantoKnobT.CornerRadius = UDim.new(1, 0)
CantoKnobT.Parent = KnobTam

-- Slider Dano
local LabelDano = Instance.new("TextLabel")
LabelDano.Parent = Area
LabelDano.BackgroundTransparency = 1
LabelDano.Position = UDim2.new(0, 0, 0, 255)
LabelDano.Size = UDim2.new(1, 0, 0, 20)
LabelDano.Font = Enum.Font.GothamSemibold
LabelDano.Text = "⚔️ Dano Jogadores/seg: 8"
LabelDano.TextColor3 = Color3.fromRGB(255, 180, 180)
LabelDano.TextSize = 13
LabelDano.TextXAlignment = Enum.TextXAlignment.Left

local SliderDano = Instance.new("Frame")
SliderDano.Parent = Area
SliderDano.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
SliderDano.BorderSizePixel = 0
SliderDano.Position = UDim2.new(0, 0, 0, 278)
SliderDano.Size = UDim2.new(1, 0, 0, 10)

local CantoSliderD = Instance.new("UICorner")
CantoSliderD.CornerRadius = UDim.new(1, 0)
CantoSliderD.Parent = SliderDano

local FillDano = Instance.new("Frame")
FillDano.Parent = SliderDano
FillDano.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
FillDano.BorderSizePixel = 0
FillDano.Size = UDim2.new(0.16, 0, 1, 0)

local CantoFillD = Instance.new("UICorner")
CantoFillD.CornerRadius = UDim.new(1, 0)
CantoFillD.Parent = FillDano

local KnobDano = Instance.new("Frame")
KnobDano.Parent = SliderDano
KnobDano.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
KnobDano.BorderSizePixel = 0
KnobDano.Size = UDim2.new(0, 18, 0, 18)
KnobDano.Position = UDim2.new(0.16, -9, 0, -4)

local CantoKnobD = Instance.new("UICorner")
CantoKnobD.CornerRadius = UDim.new(1, 0)
CantoKnobD.Parent = KnobDano

-- Toggles
local function criarToggle(texto, yPos, valorInicial, callback)
    local botao = Instance.new("TextButton")
    botao.Parent = Area
    botao.BackgroundColor3 = valorInicial and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 70)
    botao.BorderSizePixel = 0
    botao.Position = UDim2.new(0, 0, 0, yPos)
    botao.Size = UDim2.new(1, 0, 0, 36)
    botao.Font = Enum.Font.GothamSemibold
    botao.Text = texto .. (valorInicial and " ✓" or "")
    botao.TextColor3 = Color3.fromRGB(255, 255, 255)
    botao.TextSize = 12

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = botao

    local estado = valorInicial
    botao.MouseButton1Click:Connect(function()
        estado = not estado
        botao.BackgroundColor3 = estado and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 70)
        botao.Text = texto .. (estado and " ✓" or "")
        callback(estado)
    end)
    return botao
end

criarToggle("🔍 Auto-detectar blocos soltos", 303, CONFIG.AutoDetectarDesastre, function(v) CONFIG.AutoDetectarDesastre = v end)
criarToggle("👤 Pegar JOGADORES (dano)", 341, CONFIG.PegarJogadores, function(v) CONFIG.PegarJogadores = v end)
criarToggle("🎨 Efeito Visual", 379, CONFIG.EfeitoVisual, function(v) CONFIG.EfeitoVisual = v end)
criarToggle("🔊 Som do Tornado", 417, CONFIG.Som, function(v) CONFIG.Som = v end)
criarToggle("🛡️ Anti-Queda", 455, CONFIG.AntiQueda, function(v) CONFIG.AntiQueda = v end)

-- Status
local LabelStatus = Instance.new("TextLabel")
LabelStatus.Parent = Area
LabelStatus.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
LabelStatus.BorderSizePixel = 0
LabelStatus.Position = UDim2.new(0, 0, 0, 497)
LabelStatus.Size = UDim2.new(1, 0, 0, 50)
LabelStatus.Font = Enum.Font.GothamSemibold
LabelStatus.Text = "Status: Parado"
LabelStatus.TextColor3 = Color3.fromRGB(140, 180, 220)
LabelStatus.TextSize = 12
LabelStatus.TextWrapped = true

local CantoStatus = Instance.new("UICorner")
CantoStatus.CornerRadius = UDim.new(0, 6)
CantoStatus.Parent = LabelStatus

-- Contador
local LabelBlocos = Instance.new("TextLabel")
LabelBlocos.Parent = Area
LabelBlocos.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
LabelBlocos.BorderSizePixel = 0
LabelBlocos.Position = UDim2.new(0, 0, 0, 555)
LabelBlocos.Size = UDim2.new(1, 0, 0, 50)
LabelBlocos.Font = Enum.Font.GothamBold
LabelBlocos.Text = "🧲 Blocos: 0 | 👤 Jogadores: 0"
LabelBlocos.TextColor3 = Color3.fromRGB(120, 220, 255)
LabelBlocos.TextSize = 13
LabelBlocos.TextWrapped = true

local CantoBlocos = Instance.new("UICorner")
CantoBlocos.CornerRadius = UDim.new(0, 6)
CantoBlocos.Parent = LabelBlocos

-- Arrastar janela
local arrastando = false
local inicioArraste, posInicial

BarraTitulo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = true
        inicioArraste = input.Position
        posInicial = Janela.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if arrastando and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - inicioArraste
        Janela.Position = UDim2.new(posInicial.X.Scale, posInicial.X.Offset + delta.X, posInicial.Y.Scale, posInicial.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = false
    end
end)

-- Minimizar
local minimizado = false
local tamOriginal = UDim2.new(0, 300, 0, 580)
local tamMin = UDim2.new(0, 300, 0, 44)

BotaoMin.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    local alvo = minimizado and tamMin or tamOriginal
    TweenService:Create(Janela, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = alvo}):Play()
    Area.Visible = not minimizado
    BotaoMin.Text = minimizado and "+" or "—"
end)

BotaoFechar.MouseButton1Click:Connect(function()
    CONFIG.Ativado = false
    pararTornado()
    ScreenGui:Destroy()
end)

-- Sliders
local function configurarSlider(slider, fill, knob, minV, maxV, passo, callback)
    local arrastandoS = false
    local function atualizar(inputX)
        local relX = inputX - slider.AbsolutePosition.X
        local pct = math.clamp(relX / slider.AbsoluteSize.X, 0, 1)
        local valor = minV + (maxV - minV) * pct
        valor = math.floor(valor / passo) * passo
        valor = math.clamp(valor, minV, maxV)
        local novoPct = (valor - minV) / (maxV - minV)
        fill.Size = UDim2.new(novoPct, 0, 1, 0)
        knob.Position = UDim2.new(novoPct, -9, 0, -4)
        callback(valor)
    end
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoS = true
            atualizar(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if arrastandoS and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            atualizar(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoS = false
        end
    end)
end

configurarSlider(SliderRaio, FillRaio, KnobRaio, 50, 500, 10, function(v)
    CONFIG.Raio = v
    LabelRaio.Text = "🎯 Raio de Sucção: " .. v
end)

configurarSlider(SliderVel, FillVel, KnobVel, 30, 400, 10, function(v)
    CONFIG.Velocidade = v
    LabelVel.Text = "💨 Velocidade: " .. v
end)

configurarSlider(SliderTam, FillTam, KnobTam, 1, 5, 1, function(v)
    CONFIG.EscalaVisual = v
    LabelTam.Text = "📏 Escala Visual: " .. v .. ".0x"
    -- Recalcula tamanhos
    CONFIG.AlturaTornado = 200 * v
    CONFIG.RaioVisual = 60 * v
    CONFIG.TamEsferaBase = 12 * v
    CONFIG.TamEsferaTopo = 22 * v
    if CONFIG.Ativado then
        criarTornadoVisual()
    end
end)

configurarSlider(SliderDano, FillDano, KnobDano, 1, 50, 1, function(v)
    CONFIG.DanoJogadores = v
    LabelDano.Text = "⚔️ Dano Jogadores/seg: " .. v
end)

-- Funções base
local function obterPersonagem()
    local c = player.Character
    if c then return c:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function ehPersonagem(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then
            return true
        end
    end
    return false
end

local function ehBlocoSoltavel(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("BasePart") then return false end
    if obj:IsA("Terrain") then return false end
    if obj.Anchored then return false end
    if ehPersonagem(obj) then return false end
    if obj:FindFirstAncestorOfClass("Tool") then return false end
    if obj:FindFirstAncestorOfClass("Accessory") then return false end
    if obj.Locked then return false end

    local tam = obj.Size
    if tam.X > CONFIG.TamMaxBloco or tam.Y > CONFIG.TamMaxBloco or tam.Z > CONFIG.TamMaxBloco then
        return false
    end

    if obj.Name == "Baseplate" or obj.Name == "Skybox" then
        return false
    end

    return true
end

-- ═══════════════════════ TORNADO VISUAL GIGANTE v23 ═══════════════════════
local function criarTornadoVisual()
    if not CONFIG.EfeitoVisual then return end
    
    for _, p in ipairs(partesTornado) do
        if p and p.Parent then p:Destroy() end
    end
    partesTornado = {}
    
    local escala = CONFIG.EscalaVisual or 1
    local numEsferas = math.floor(CONFIG.NumEsferas * math.min(escala, 2))  -- Máx 2x esferas
    
    for i = 1, numEsferas do
        local parte = Instance.new("Part")
        parte.Name = "TornadoVisual_" .. i
        parte.Shape = Enum.PartType.Ball
        parte.Size = Vector3.new(CONFIG.TamEsferaBase, CONFIG.TamEsferaBase, CONFIG.TamEsferaBase)
        parte.Material = Enum.Material.Neon
        parte.Color = Color3.fromRGB(100, 200, 255)
        parte.Transparency = 0.3
        parte.Anchored = true
        parte.CanCollide = false
        parte.CanQuery = false
        parte.CanTouch = false
        parte.CastShadow = false
        parte.Parent = Workspace
        table.insert(partesTornado, parte)
    end
    
    local raiz = obterPersonagem()
    if raiz then
        local attachment = Instance.new("Attachment")
        attachment.Parent = raiz
        
        efeitoParticulas = Instance.new("ParticleEmitter")
        efeitoParticulas.Texture = "rbxassetid://243098098"
        -- ⚡ Partículas GIGANTES: rate 400, speed 60-100, size 12
        efeitoParticulas.Rate = math.floor(400 * math.min(escala, 2))
        efeitoParticulas.Lifetime = NumberRange.new(1.5, 3)
        efeitoParticulas.Speed = NumberRange.new(60 * escala, 100 * escala)
        efeitoParticulas.SpreadAngle = Vector2.new(360, 360)
        efeitoParticulas.Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 12 * escala),
            NumberSequenceKeypoint.new(1, 0)
        }
        efeitoParticulas.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1)
        }
        efeitoParticulas.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
        efeitoParticulas.Parent = attachment
    end
end

local function destruirTornadoVisual()
    for _, p in ipairs(partesTornado) do
        if p and p.Parent then p:Destroy() end
    end
    partesTornado = {}
    if efeitoParticulas and efeitoParticulas.Parent then
        efeitoParticulas:Destroy()
    end
    efeitoParticulas = nil
end

local function animarTornadoVisual(dt)
    if not CONFIG.EfeitoVisual then return end
    local raiz = obterPersonagem()
    if not raiz then return end
    
    local centro = raiz.Position
    local t = tick()
    local numEsferas = #partesTornado
    
    for i, parte in ipairs(partesTornado) do
        if parte and parte.Parent then
            local idx = i - 1
            local pct = (idx % numEsferas) / numEsferas
            local altura = pct * CONFIG.AlturaTornado
            local raioAqui = (1 - pct * 0.6) * CONFIG.RaioVisual + 8
            local angulo = t * CONFIG.Rotacao + (idx * math.pi * 2 / numEsferas)
            
            local posX = centro.X + math.cos(angulo) * raioAqui
            local posZ = centro.Z + math.sin(angulo) * raioAqui
            local posY = centro.Y + altura
            
            parte.CFrame = CFrame.new(posX, posY, posZ)
            local tamAtual = CONFIG.TamEsferaBase + pct * (CONFIG.TamEsferaTopo - CONFIG.TamEsferaBase)
            parte.Size = Vector3.new(tamAtual, tamAtual, tamAtual)
            parte.Transparency = 0.25 + pct * 0.5
        end
    end
end

-- Som
local function iniciarSom()
    if not CONFIG.Som then return end
    pcall(function()
        somTornado = Instance.new("Sound")
        somTornado.SoundId = "rbxassetid://9066773685"
        somTornado.Volume = 4
        somTornado.Looped = true
        somTornado.Parent = Workspace
        somTornado:Play()
    end)
end

local function pararSom()
    if somTornado then
        pcall(function()
            somTornado:Stop()
            somTornado:Destroy()
        end)
        somTornado = nil
    end
end

-- Anti-queda
local function iniciarAntiQueda()
    if conexaoAntiQueda then conexaoAntiQueda:Disconnect() end
    
    conexaoAntiQueda = RunService.Heartbeat:Connect(function()
        if not CONFIG.AntiQueda then return end
        local raiz = obterPersonagem()
        if not raiz then return end
        
        if raiz.Position.Y < -50 then
            if ultimaPosicaoSegura then
                raiz.CFrame = CFrame.new(ultimaPosicaoSegura + Vector3.new(0, 5, 0))
                raiz.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            else
                raiz.CFrame = CFrame.new(0, 50, 0)
            end
        end
        
        if raiz.Position.Y > 0 then
            ultimaPosicaoSegura = raiz.Position
        end
    end)
end

-- Controle de blocos
local function controlarBloco(parte)
    if not parte or not parte.Parent or blocosControlados[parte] then return end
    if not ehBlocoSoltavel(parte) then return end
    
    local raiz = obterPersonagem()
    if not raiz then return end
    
    pegarOwnership(parte)
    
    local corOrig = parte.Color
    local matOrig = parte.Material
    
    parte.CanCollide = false
    
    pcall(function()
        parte.Material = Enum.Material.Neon
        parte.Color = Color3.fromRGB(100, 200, 255)
    end)
    
    local giro = Instance.new("BodyGyro")
    giro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    giro.P = 40000
    giro.D = 500
    giro.CFrame = parte.CFrame
    giro.Parent = parte
    
    local velocidade = Instance.new("BodyVelocity")
    velocidade.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocidade.Velocity = Vector3.new(0, 0, 0)
    velocidade.Parent = parte
    
    blocosControlados[parte] = {
        giro = giro,
        velocidade = velocidade,
        corOriginal = corOrig,
        materialOriginal = matOrig,
    }
end

-- Controle de jogadores
local function controlarJogador(outroPlayer)
    if not CONFIG.PegarJogadores then return end
    if outroPlayer == player then return end
    
    local char = outroPlayer.Character
    if not char then return end
    
    local raiz = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not raiz or not hum or hum.Health <= 0 then return end
    
    if not jogadoresControlados[outroPlayer] then
        jogadoresControlados[outroPlayer] = { tempoUltimoDano = 0 }
    end
    
    local meuRaiz = obterPersonagem()
    if not meuRaiz then return end
    
    local distancia = (raiz.Position - meuRaiz.Position).Magnitude
    if distancia <= 35 then
        local agora = tick()
        local dados = jogadoresControlados[outroPlayer]
        if agora - dados.tempoUltimoDano >= 1 then
            dados.tempoUltimoDano = agora
            pcall(function()
                hum:TakeDamage(CONFIG.DanoJogadores)
            end)
        end
    end
end

-- Atualização dos blocos
local function atualizarBlocos()
    local raiz = obterPersonagem()
    if not raiz then return end
    
    local centro = raiz.Position
    local paraRemover = {}
    
    for parte, dados in pairs(blocosControlados) do
        if not parte or not parte.Parent then
            paraRemover[parte] = true
        else
            local distancia = (parte.Position - centro).Magnitude
            
            if distancia > CONFIG.Raio * 2 then
                paraRemover[parte] = true
            else
                local direcaoRadial = (centro - parte.Position)
                local distRad = direcaoRadial.Magnitude
                
                if distRad > 3 then
                    direcaoRadial = direcaoRadial.Unit
                else
                    direcaoRadial = Vector3.new(0, 0, 0)
                end
                
                local up = Vector3.new(0, 1, 0)
                local tangencial = direcaoRadial:Cross(up)
                if tangencial.Magnitude > 0 then
                    tangencial = tangencial.Unit
                end
                
                local subir = Vector3.new(0, 1, 0) * 10
                local velFinal = (direcaoRadial * CONFIG.Velocidade) + (tangencial * CONFIG.Velocidade * 1.2) + subir
                dados.velocidade.Velocity = velFinal
                
                dados.giro.CFrame = dados.giro.CFrame * CFrame.Angles(math.rad(20), math.rad(25), math.rad(15))
            end
        end
    end
    
    for parte in pairs(paraRemover) do
        local dados = blocosControlados[parte]
        if dados then
            if dados.giro then pcall(function() dados.giro:Destroy() end) end
            if dados.velocidade then pcall(function() dados.velocidade:Destroy() end) end
            if parte and parte.Parent then
                pcall(function()
                    parte.Material = dados.materialOriginal
                    parte.Color = dados.corOriginal
                    parte:SetNetworkOwner(nil)
                end)
            end
            blocosControlados[parte] = nil
        end
    end
end

-- Escaneamento
local function escanear()
    local raiz = obterPersonagem()
    if not raiz then return end
    local centro = raiz.Position
    
    local contSoltos = 0
    local contAncorados = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and not ehPersonagem(obj) then
            if not obj.Anchored then
                contSoltos = contSoltos + 1
                if not blocosControlados[obj] then
                    local d = (obj.Position - centro).Magnitude
                    if d <= CONFIG.Raio then
                        controlarBloco(obj)
                    end
                end
            else
                contAncorados = contAncorados + 1
            end
        end
    end
    
    if CONFIG.PegarJogadores then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                controlarJogador(p)
            end
        end
    end
    
    -- Atualiza label do desastre
    if contSoltos > 5 then
        LabelDesastre.Text = string.format("🔥 DESASTRE ATIVO! %d blocos soltos", contSoltos)
        LabelDesastre.TextColor3 = Color3.fromRGB(255, 150, 100)
    else
        LabelDesastre.Text = string.format("🔍 Aguardando... (%d soltos / %d ancorados)", contSoltos, contAncorados)
        LabelDesastre.TextColor3 = Color3.fromRGB(180, 220, 255)
    end
end

function limparTudo()
    for parte, dados in pairs(blocosControlados) do
        if parte and parte.Parent then
            if dados.giro then pcall(function() dados.giro:Destroy() end) end
            if dados.velocidade then pcall(function() dados.velocidade:Destroy() end) end
            pcall(function()
                parte.Material = dados.materialOriginal
                parte.Color = dados.corOriginal
                parte:SetNetworkOwner(nil)
            end)
        end
    end
    blocosControlados = {}
    jogadoresControlados = {}
end

-- Loop principal
local conexaoPrincipal = nil
local conexaoTornado = nil

local function iniciarTornado()
    CONFIG.Ativado = true
    iniciarAntiQueda()
    criarTornadoVisual()
    iniciarSom()
    
    conexaoPrincipal = RunService.Heartbeat:Connect(function(dt)
        if not CONFIG.Ativado then return end
        atualizarBlocos()
    end)
    
    conexaoTornado = RunService.RenderStepped:Connect(function(dt)
        if not CONFIG.Ativado then return end
        animarTornadoVisual(dt)
    end)
    
    task.spawn(function()
        while CONFIG.Ativado and ScreenGui and ScreenGui.Parent do
            escanear()
            task.wait(0.4)
        end
    end)
end

function pararTornado()
    CONFIG.Ativado = false
    
    if conexaoPrincipal then conexaoPrincipal:Disconnect() end
    if conexaoTornado then conexaoTornado:Disconnect() end
    conexaoPrincipal = nil
    conexaoTornado = nil
    
    destruirTornadoVisual()
    pararSom()
    limparTudo()
end

-- Botão principal
BotaoPrincipal.MouseButton1Click:Connect(function()
    if CONFIG.Ativado then
        pararTornado()
        BotaoPrincipal.Text = "🌪️ ATIVAR TORNADO GIGANTE"
        Titulo.Text = "🌪️ TORNADO GIGANTE v23"
        Titulo.TextColor3 = Color3.fromRGB(150, 230, 255)
        LabelStatus.Text = "Status: Parado"
        LabelStatus.TextColor3 = Color3.fromRGB(140, 180, 220)
    else
        iniciarTornado()
        BotaoPrincipal.Text = "🌪️ DESATIVAR TORNADO"
        Titulo.Text = "🌪️ TORNADO v23 [ATIVO]"
        Titulo.TextColor3 = Color3.fromRGB(100, 255, 150)
        LabelStatus.Text = "Status: TORNADO GIGANTE ATIVO! 🔥"
        LabelStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Contador em tempo real
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(0.5)
        
        local countBlocos = 0
        for p in pairs(blocosControlados) do
            if p and p.Parent then countBlocos = countBlocos + 1 end
        end
        
        local countJogadores = 0
        for p in pairs(jogadoresControlados) do
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                countJogadores = countJogadores + 1
            end
        end
        
        LabelBlocos.Text = string.format("🧲 Blocos: %d | 👤 Jogadores: %d", countBlocos, countJogadores)
        
        if countBlocos > 100 then
            LabelBlocos.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif countBlocos > 40 then
            LabelBlocos.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            LabelBlocos.TextColor3 = Color3.fromRGB(120, 220, 255)
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if CONFIG.Ativado then
        limparTudo()
        criarTornadoVisual()
    end
end)

print("╔══════════════════════════════════════════╗")
print("║   🌪️ TORNADO GIGANTE v23.0 🌪️           ║")
print("║   Visual 3x+ maior que a v22!            ║")
print("║   Novo slider de ESCALA VISUAL!          ║")
print("╚══════════════════════════════════════════╝")
