local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "MY FIRST SCRIPT",
    Icon = "door-open", -- lucide icon
    Author = "PRIME",
    Folder = "MySuperHub",
    

    
    --  This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    

    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },

    
})
local Tab = Window:Tab({
    Title = "Auto Farm",
    Locked = false,
})

Window:SetToggleKey(Enum.KeyCode.LeftControl)

local ToggleAutoRaccolta = Tab:Toggle({
    Title = "Raccolta automatica",
    Desc = "Raccolta oro",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        getgenv().Raccolta = state
        if state then
            print("Auto raccolta attivata")
            task.spawn(function()
                while getgenv().Raccolta do
                    local goldsFolder = workspace:FindFirstChild("Golds")
                    if goldsFolder then
                         for _, gold in pairs(goldsFolder:GetChildren()) do
                                
                                    local player = game.Players.LocalPlayer
                                    local char = player.Character or player.CharacterAdded:Wait()
                                    local root = char:WaitForChild("HumanoidRootPart")
                                    if not getgenv().Raccolta then break end
                                    gold.CFrame=root.CFrame
                                end
                        end
                    task.wait(0.5)
                    end
                    print("stop auto raccolta")
                end)
        else
            getgenv().Raccolta=false
        end
    end
})

local ToggleAutoFarmDistanceRage = Tab:Toggle({
    Title = "Auto Farm Distance Rage",
    Desc = "Auto Farm dalla distanza attaca tutti i nemici senza aspettare la morte",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarmDistanceRage = state
        if state then
            print("AutoFarm rage Attivato")
            task.spawn(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                    local ClickEnemy = Remotes:WaitForChild("ClickEnemy")
                    local PlayerClickAttackSkill = Remotes:WaitForChild("PlayerClickAttackSkill")
                    local enemiesFolder = workspace:FindFirstChild("Enemys")
                    while getgenv().AutoFarmDistanceRage do
                        if enemiesFolder then
                            for _, enemy in pairs(enemiesFolder:GetChildren()) do
                                if not getgenv().AutoFarmDistanceRage then break end
                                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                                local enemyGUID = enemy:GetAttribute("EnemyGuid")
                                if hrp then
                                    local player = game.Players.LocalPlayer
                                    local char = player.Character or player.CharacterAdded:Wait()
                                    local root = char:WaitForChild("HumanoidRootPart")
                                    ClickEnemy:InvokeServer({ enemyGuid = enemyGUID, enemyPos = root.CFrame.Position})
                                    PlayerClickAttackSkill:FireServer({attackEnemyGUID = enemyGUID})
                                    task.wait(0.2) 
                                end
                            end
                        end
                        task.wait(0.3)
                    end
                    print("stop auto farm distance rage")
            end)
        else
            getgenv().AutoFarmDistance=false
        end
    end
})



local ToggleAutoFarmDistanceV2 = Tab:Toggle({
    Title = "Auto Farm Distance V2",
    Desc = "Auto Farm dalla distanza",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarmDistanceV2 = state

        if state then
            print("AutoFarm Distance attivato")

            task.spawn(function()
                -- Servizi e variabili base
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                local ClickEnemy = Remotes:WaitForChild("ClickEnemy")
                local PlayerClickAttackSkill = Remotes:WaitForChild("PlayerClickAttackSkill")
                local EnemyDeath = Remotes:WaitForChild("EnemyDeath")
                local UpdateMapTeleport = Remotes:WaitForChild("LocalPlayerTeleportToMap")
                local enemiesFolder = workspace:FindFirstChild("Enemys")

                -- Tabella per memorizzare i nemici uccisi
                local killedEnemies = {}
                --Per rilevare il cambio mappa
                local MapChanging = false

                -- Ascolta la morte dei nemici dal server
                EnemyDeath.OnClientEvent:Connect(function(data)
                    if typeof(data) == "table" and data.guid then
                        local guid = data.guid
                        killedEnemies[guid] = true
                        --print("Nemico ucciso GUID:", guid)
                    end
                end)

                --ascolta il cambio mappa
                UpdateMapTeleport.OnClientEvent:Connect(function(map)
                        MapChanging = true
                        print("ricevuto cambio mappa")
                end)

                -- Loop principale AutoFarm
                while getgenv().AutoFarmDistanceV2 do
                    if enemiesFolder then
                        for _, enemy in pairs(enemiesFolder:GetChildren()) do
                            if not getgenv().AutoFarmDistanceV2 then break end

                            local hrp = enemy:FindFirstChild("HumanoidRootPart")
                            local enemyGUID = enemy:GetAttribute("EnemyGuid")

                            -- Se il nemico esiste, ha un GUID, e non e' ancora morto
                            if hrp and enemyGUID and not killedEnemies[enemyGUID] then
                                local player = game.Players.LocalPlayer
                                local char = player.Character or player.CharacterAdded:Wait()
                                local root = char:WaitForChild("HumanoidRootPart")

                                -- Finche' il nemico e' vivo e AutoFarm e' attivo
                                while getgenv().AutoFarmDistanceV2 and not killedEnemies[enemyGUID] and not MapChanging do
                                    ClickEnemy:InvokeServer({
                                        enemyGuid = enemyGUID,
                                        enemyPos = root.CFrame.Position
                                    })
                                    PlayerClickAttackSkill:FireServer({
                                        attackEnemyGUID = enemyGUID
                                    })
                                    task.wait(0.2)
                                end
                                if MapChanging then
                                    killedEnemies = {} -- reset nemici
                                    --Ripeto finchè entrando nella nuova mappa non ricevo il nuovo folder di nemici
                                     repeat
                                        task.wait(3)
                                        enemiesFolder = workspace:FindFirstChild("Enemys")
                                    until enemiesFolder and #enemiesFolder:GetChildren() > 0


                                    MapChanging = false -- reset controllo
                                    print("reset cambio mappa")
                                    break -- esci per ricaricare gli enemy della nuova mappa
                                end

                            end
                        end
                    end

                    task.wait(0.3)
                end

                print("AutoFarm Distance disattivato")
            end)

        else
            getgenv().AutoFarmDistanceV2 = false
            print("AutoFarm Distance disattivato manualmente")
        end
    end
})


local ToggleAutoFarmTpV2 = Tab:Toggle({
    Title = "Auto Farm TP V2",
    Desc = "Auto Farm con teletrasporto",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarmDistanceTpV2 = state

        if state then
            print("Auto Farm con teletrasporto")

            task.spawn(function()
                -- Servizi e variabili base
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                local ClickEnemy = Remotes:WaitForChild("ClickEnemy")
                local PlayerClickAttackSkill = Remotes:WaitForChild("PlayerClickAttackSkill")
                local EnemyDeath = Remotes:WaitForChild("EnemyDeath")
                local enemiesFolder = workspace:FindFirstChild("Enemys")

                -- Tabella per memorizzare i nemici uccisi
                local killedEnemies = {}

                -- Ascolta la morte dei nemici dal server
                EnemyDeath.OnClientEvent:Connect(function(data)
                    if typeof(data) == "table" and data.guid then
                        local guid = data.guid
                        killedEnemies[guid] = true
                        --print("Nemico ucciso GUID:", guid)
                    end
                end)

                -- Loop principale AutoFarm
                while getgenv().AutoFarmDistanceTpV2 do
                    if enemiesFolder then
                        for _, enemy in pairs(enemiesFolder:GetChildren()) do
                            if not getgenv().AutoFarmDistanceTpV2 then break end

                            local hrp = enemy:FindFirstChild("HumanoidRootPart")
                            local enemyGUID = enemy:GetAttribute("EnemyGuid")

                            -- Se il nemico esiste, ha un GUID, e non e' ancora morto
                            if hrp and enemyGUID and not killedEnemies[enemyGUID] then
                                local player = game.Players.LocalPlayer
                                local char = player.Character or player.CharacterAdded:Wait()
                                local root = char:WaitForChild("HumanoidRootPart")
                                root.CFrame=hrp.CFrame+Vector3.new(3, 3, 3)
                                
                                -- Finch￯﾿ﾯ￯ﾾ﾿￯ﾾﾃ￯﾿ﾯ￯ﾾﾾ￯ﾾﾩ il nemico ￯﾿ﾯ￯ﾾ﾿￯ﾾﾃ￯﾿ﾯ￯ﾾﾾ￯ﾾﾨ vivo e AutoFarm e' attivo
                                while getgenv().AutoFarmDistanceTpV2 and not killedEnemies[enemyGUID] do
                                    ClickEnemy:InvokeServer({
                                        enemyGuid = enemyGUID,
                                        enemyPos = root.CFrame.Position
                                    })
                                    PlayerClickAttackSkill:FireServer({
                                        attackEnemyGUID = enemyGUID
                                    })
                                    task.wait(0.2)
                                end
                            end
                        end
                    end

                    task.wait(0.3)
                end

                print("Auto Farm con teletrasporto disattivato")
            end)

        else
            getgenv().AutoFarmDistanceTpV2 = false
            print("Auto Farm con teletrasporto disattivato manualmente")
        end
    end
})

local Tab = Window:Tab({
    Title = "Auto Reroll Ornamenti",
    Locked = false,
})

local ToggleAutoRerollHead = Tab:Toggle({
    Title = "Auto Reroll Head",
    Desc = "Roll automatico dei cappelli",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        getgenv().AutoRerollHead = state
        if state then
            print("Auto Reroll cappelli")
            task.spawn(function()
                while getgenv().AutoRerollHead do
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RerollOrnament"):InvokeServer(400001)
                    task.wait(0.03)
                end
            end)

        else
            getgenv().AutoRerollHead = false
            print("Auto Reroll cappelli disattivato manualmente")
        end
    end
})

local ToggleAutoRerollShoulder = Tab:Toggle({
    Title = "Auto Reroll Shoulder",
    Desc = "Roll automatico della schiena",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        getgenv().AutoRerollShoulder = state
        if state then
            print("Auto Reroll Shoulder")
            task.spawn(function()
                while getgenv().AutoRerollShoulder do
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RerollOrnament"):InvokeServer(400002)
                    task.wait(0.03)
                end
            end)

        else
            getgenv().AutoRerollShoulder = false
            print("Auto Reroll shoulder disattivato manualmente")
        end
    end
})

local Tab = Window:Tab({
    Title = "Hero skill",
    Locked = false,
})


--stanpa info
local Paragraph = Tab:Paragraph({
    Title = "Quirk status: ",
    Desc = "Rerolla una volta dal npc prima",
    Color = "White",
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = ""
})

-- Ascolta l'evento dal server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateHeroQuirk = Remotes:WaitForChild("UpdateHeroQuirk")

UpdateHeroQuirk.OnClientEvent:Connect(function(data)
    print("sono dentro l'update quirk")
    -- Controlla che i dati siano validi
    if not data or not data.heroData then
        warn("Dati non validi ricevuti da UpdateHeroQuirk")
        return
    end

    local heroData = data.heroData
    local guid = heroData.guid or "N/A"
    local quirks = heroData.quirks or {}

    -- Crea una stringa leggibile con le abilità (quirks)
    local quirksList = table.concat(quirks, ", ")

    -- Aggiorna la descrizione del paragrafo
    Paragraph:SetDesc(string.format(
        "Hero GUID: %s\nAbilities: %s",
        guid,
        quirksList
    ))

    print("Aggiornato Quirk status:", guid, quirksList)
end)


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuirkConfig = require(ReplicatedStorage.Scripts.Configs.QuirksNew)

-- Funzione per filtrare i Quirk in base al DrawId
local function GetQuirksByDrawId(drawId)
    local result = {}
    for _, quirk in ipairs(QuirkConfig) do
        if quirk.DrawId == drawId then
            table.insert(result, {
                Title = quirk.QuirksName, -- Nome visualizzato
                id = tostring(quirk.Id) -- Mettiamo l’ID dell’abilità come "icona"
            })
        end
    end
    return result
end

-- Ottieni le categorie in base ai DrawId
local quirksSet1 = GetQuirksByDrawId(920001)
local quirksSet2 = GetQuirksByDrawId(920002)
local quirksSet3 = GetQuirksByDrawId(920003)


-- Crea i 3 dropdown usando il tuo stile originale
local Dropdown1 = Tab:Dropdown({
    Title = "Hero Quirk 1",
    Desc = "Quirk 1",
    Values = quirksSet1,
    Value = quirksSet1[1] and quirksSet1[1].Title or "Nessuno",
    Callback = function(option)
        print("Hai selezionato:", option.Title, "(ID:", option.id .. ")")
    end
})

local Dropdown2 = Tab:Dropdown({
    Title = "Hero Quirk 2",
    Desc = "Quirk 2",
    Values = quirksSet2,
    Value = quirksSet2[1] and quirksSet2[1].Title or "Nessuno",
    Callback = function(option)
        print("Hai selezionato:", option.Title, "(ID:", option.id .. ")")
    end
})

local Dropdown3 = Tab:Dropdown({
    Title = "Hero Quirk 3",
    Desc = "Qurik 3",
    Values = quirksSet3,
    Value = quirksSet3[1] and quirksSet3[1].Title or "Nessuno",
    Callback = function(option)
        print("Hai selezionato:", option.Title, "(ID:", option.id .. ")")
    end
})


local Tab = Window:Tab({
    Title = "utility",
    Locked = false,
})


local SliderSpeedPlayer = Tab:Slider({
    Title = "Setta la velocità",
    Desc = "Imposta la velocità del player",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 1,
    Value = {
        Min = 20,
        Max = 200,
        Default = game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed,
    },
    Callback = function(value)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("Humanoid")
        root.WalkSpeed=value
    end
})