local RS = game:GetService("RunService")

local Camera = game:GetService("Workspace").CurrentCamera

local CurrentCamera = game:GetService("Workspace").CurrentCamera

local RunService = game:GetService("RunService")

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()

local UserInputService = game:GetService("UserInputService")



SilentTarget = nil



local silent_aim_fovcircle = Drawing.new("Circle")

silent_aim_fovcircle.Thickness = 1

silent_aim_fovcircle.Radius = getgenv().nebula.silent_aim.fov.fov_radius.value * 2

silent_aim_fovcircle.Visible = getgenv().nebula.silent_aim.fov.visible.value and getgenv().nebula.silent_aim.enabled.value

silent_aim_fovcircle.Transparency = 1

silent_aim_fovcircle.Color = getgenv().nebula.silent_aim.fov.color.value



local fovCircle = Drawing.new("Circle")

fovCircle.Thickness = 1

fovCircle.Radius = getgenv().nebula.aimbot.fov.fov_radius.value

fovCircle.Visible = getgenv().nebula.aimbot.fov.visible.value and getgenv().nebula.aimbot.enabled.value

fovCircle.Transparency = 1

fovCircle.Color = getgenv().nebula.aimbot.fov.color.value



RunService.RenderStepped:Connect(function()

    fovCircle.Position = UserInputService:GetMouseLocation()

end)



local function ApplyPrediction(targetPart)

    if getgenv().nebula.aimbot.enabled.value and getgenv().nebula.aimbot.prediction.enabled.value then

        local velocity = targetPart.Parent:FindFirstChild("HumanoidRootPart") and targetPart.Parent.HumanoidRootPart.Velocity or Vector3.zero

        local factorX = getgenv().nebula.aimbot.prediction.factor.x

        local factorY = getgenv().nebula.aimbot.prediction.factor.y

        return targetPart.Position + (velocity * Vector3.new(factorX, factorY, factorX))

    end

    return targetPart.Position

end





local function ApplySmoothing(currentCFrame, targetPosition)

    if getgenv().nebula.aimbot.smoothing.enabled.value then

        local smoothingFactor = getgenv().nebula.aimbot.smoothing.factor.value

        local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)

        return currentCFrame:Lerp(targetCFrame, smoothingFactor)

    end

    return CFrame.new(currentCFrame.Position, targetPosition)

end





local function FindClosestPlayerToCamera()

    local closestPlayer

    local shortestAngle = math.huge

    local cameraPosition = CurrentCamera.CFrame.Position

    local cameraLookDirection = CurrentCamera.CFrame.LookVector



    for i, v in pairs(game.Players:GetPlayers()) do

        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and

            v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then

            local characterPos = v.Character[getgenv().nebula.aimbot.target_part.value].Position

            local directionToPlayer = (characterPos - cameraPosition).unit

            local angle = math.acos(cameraLookDirection:Dot(directionToPlayer))



            if angle < shortestAngle then

                closestPlayer = v

                shortestAngle = angle

            end

        end

    end

    return closestPlayer

end



local keyBindConfig = getgenv().nebula.aimbot.key -- Short reference to the key bind configuration



local function IsKeyBindPressed(input)

    if keyBindConfig.bind_type == "keyboard" then

        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[keyBindConfig.bind:upper()]

    elseif keyBindConfig.bind_type == "mouse" then

        local mouseInputTypes = {

            ["MouseButton1"] = Enum.UserInputType.MouseButton1,

            ["MouseButton2"] = Enum.UserInputType.MouseButton2,

            ["MouseButton3"] = Enum.UserInputType.MouseButton3

        }

        return input.UserInputType == mouseInputTypes[keyBindConfig.bind]

    end

    return false

end



UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then return end -- Ignore inputs processed by the game



    if IsKeyBindPressed(input) then

        local aimbotConfig = getgenv().nebula.aimbot -- Short reference to aimbot settings



        aimbotConfig.enabled.value = not aimbotConfig.enabled.value -- Toggle aimbot



        if aimbotConfig.method.value == "Mouse" then

            Plr = aimbotConfig.enabled.value and FindClosestPlayer() or nil

        else

            Plr = aimbotConfig.enabled.value and FindClosestPlayerToCamera() or nil

        end

    end

end)



if getgenv().nebula.custom_assets.textures.enabled.value then

    local localPlayer = game.Players.LocalPlayer

    for _, v in pairs(workspace:GetDescendants()) do

        if v:IsA("BasePart") then

            if v.Parent and v.Parent ~= localPlayer.Character then

                v.Material = getgenv().nebula.custom_assets.textures.material.value

                if getgenv().nebula.custom_assets.textures.customcolor.value then

                    v.Color = getgenv().nebula.custom_assets.textures.color.value

                end

            end

        end

    end

end



if getgenv().nebula.custom_assets.skybox.enabled.value then

    local s = Instance.new("Sky")

    s.Name = "SKY"

    local customID = getgenv().nebula.custom_assets.skybox.custom_id.value

    s.SkyboxBk = "http://www.roblox.com/asset/?id=" .. customID

    s.SkyboxDn = "http://www.roblox.com/asset/?id=" .. customID

    s.SkyboxFt = "http://www.roblox.com/asset/?id=" .. customID

    s.SkyboxLf = "http://www.roblox.com/asset/?id=" .. customID

    s.SkyboxRt = "http://www.roblox.com/asset/?id=" .. customID

    s.SkyboxUp = "http://www.roblox.com/asset/?id=" .. customID

    s.Parent = game.Lighting

end



local function PassesChecks(player)

    local checks = getgenv().nebula.aimbot.checks

    if checks then

        if checks.knocked.value then

            local bodyEffects = player.Character:FindFirstChild("BodyEffects")

            if bodyEffects and bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value == true then

                return false

            end

        end



        if checks.grabbed.value then

            local bodyEffects = player.Character:FindFirstChild("BodyEffects")

            if bodyEffects and bodyEffects:FindFirstChild("Grabbed") and bodyEffects["Grabbed"].Value == true then

                return false

            end

        end



        if checks.dead.value then

            local bodyEffects = player.Character:FindFirstChild("BodyEffects")

            if bodyEffects and bodyEffects:FindFirstChild("Dead") and bodyEffects["Dead"].Value == true then

                return false

            end

        end

    end

    return true

end



local function GetClosestPlayer()

    local closestPlayer = nil

    local closestDistance = math.huge

    for _, player in pairs(game.Players:GetPlayers()) do

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

            local targetPart = player.Character:FindFirstChild(getgenv().nebula.aimbot.target_part.value)

            if targetPart and PassesChecks(player) then

                local screenPosition, onScreen = game:GetService("Workspace").CurrentCamera:WorldToScreenPoint(targetPart.Position)

                local mousePos = UserInputService:GetMouseLocation()

                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude

                if distance < closestDistance then

                    closestDistance = distance

                    closestPlayer = player

                end

            end

        end

    end

    return closestPlayer

end





RunService.RenderStepped:Connect(function()

    if getgenv().nebula.aimbot.enabled.value and Plr and Plr.Character and Plr.Character:FindFirstChild(getgenv().nebula.aimbot.target_part.value) then

        local targetPart = Plr.Character[getgenv().nebula.aimbot.target_part.value]

        

        if PassesChecks(Plr) then

            local predictedPosition = ApplyPrediction(targetPart)

            

            if getgenv().nebula.aimbot.method.value == "Camera" then

                -- Smooth camera transition

                CurrentCamera.CFrame = ApplySmoothing(CurrentCamera.CFrame, predictedPosition)

            elseif getgenv().nebula.aimbot.method.value == "Mouse" then

                -- Adjust mouse movement

                local mouseLocation = UserInputService:GetMouseLocation()

                local deltaX = (predictedPosition.X - mouseLocation.X) * 0.5

                local deltaY = (predictedPosition.Y - mouseLocation.Y) * 0.5

                mousemoverel(deltaX, deltaY)

            end

        end

    end

end)



local function GetClosestSilentPlayer()

    local Closest, ShortestDistance = nil, getgenv().nebula.silent_aim.fov.fov_radius.value

    local TargetPart = getgenv().nebula.silent_aim.target_part.value or "Head"

    local PredictionEnabled = getgenv().nebula.silent_aim.prediction.enabled.value

    local PredictionFactor = getgenv().nebula.silent_aim.prediction.factor.value or 0

    local Camera = game:GetService("Workspace").CurrentCamera



    for _, Player in pairs(Players:GetPlayers()) do

        if Player ~= LocalPlayer and Player.Character then

            local Part = Player.Character:FindFirstChild(TargetPart)

            if Part then

                local Position = Part.Position

                

                if PredictionEnabled then

                    local Velocity = Part.Velocity or Vector3.new(0, 0, 0)

                    Position = Position + (Velocity * PredictionFactor)

                end

                

                local ScreenPosition, OnScreen = Camera:WorldToScreenPoint(Position)

                if OnScreen then

                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude

                    if Distance < ShortestDistance then

                        Closest, ShortestDistance = Player, Distance

                    end

                end

            end

        end

    end

    return Closest

end



RunService.RenderStepped:Connect(function()

        silent_aim_fovcircle.Position = UserInputService:GetMouseLocation()

end)



local function silentaimchecks(player)

    if getgenv().nebula.silent_aim.enabled.value then

        local checks = getgenv().nebula.silent_aim.checks

        if checks then

            if checks.knocked and checks.knocked.value then

                local bodyEffects = player.Character:FindFirstChild("BodyEffects")

                if bodyEffects and bodyEffects:FindFirstChild("K.O") then

                    if bodyEffects["K.O"].Value == true then

                        return false

                    end

                end

            end



            if checks.grabbed and checks.grabbed.value then

                local bodyEffects = player.Character:FindFirstChild("BodyEffects")

                if bodyEffects and bodyEffects:FindFirstChild("Grabbed") then

                    if bodyEffects["Grabbed"].Value == true then

                        return false

                    end

                end

            end



            if checks.dead and checks.dead.value then

                local bodyEffects = player.Character:FindFirstChild("BodyEffects")

                if bodyEffects and bodyEffects:FindFirstChild("Dead") then

                    if bodyEffects["Dead"].Value == true then

                        return false

                    end

                end

            end

        end

    end

    return true

end



RunService.Heartbeat:Connect(function()

    if getgenv().nebula.silent_aim.enabled.value then

        SilentTarget = GetClosestSilentPlayer()

    end

end)



local grm = getrawmetatable(game)

local oldindex = nil

setreadonly(grm, false)

oldindex = grm.__index



grm.__index = function(self, Index)

    if not checkcaller() and self == Mouse then

        if Index == "Hit" or (Index == "Target" and game.PlaceId == 2788229376) then

            if SilentTarget and SilentTarget.Character then

                local TargetPart = SilentTarget.Character:FindFirstChild("Head")

                if TargetPart then

                    return CFrame.new(TargetPart.Position)

                end

            end

        end

    end

    return oldindex(self, Index)

end





game:GetService("RunService").RenderStepped:Connect(function()

    if not getgenv().nebula.movement.enabled.value then return end

    

    local localPlayer = game.Players.LocalPlayer

    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then

        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

        local hasWhitelistedWeapon = false

        

        if humanoid then

            for _, tool in next, localPlayer.Character:GetChildren() do

                if tool:IsA("Tool") then

                    for _, weaponName in next, getgenv().nebula.whitelist.weapons do

                        if tool.Name == weaponName then

                            hasWhitelistedWeapon = true

                            break

                        end

                    end

                end

            end

        end



        if getgenv().nebula.whitelist.enabled then

        if humanoid then

            if hasWhitelistedWeapon then

                humanoid.WalkSpeed = getgenv().nebula.movement.walk_speed.holding_weapon.value

            else

                humanoid.WalkSpeed = getgenv().nebula.movement.walk_speed.default.value

            end

        end

            



            if getgenv().nebula.whitelist.enabled then

            if hasWhitelistedWeapon then

                humanoid.JumpPower = getgenv().nebula.movement.jump_power.holding_weapon.value

            else

                humanoid.JumpPower = getgenv().nebula.movement.jump_power.default.value

            end

            end

        end

    end

end)



game:GetService("UserInputService").InputBegan:Connect(function(input)

    local macro = getgenv().nebula.macro



    if macro.enabled.value and input.KeyCode == Enum.KeyCode[string.upper(macro.bind.keybind)] then

        if macro.enabled.value then

            for i = 1, math.floor(macro.degrees.value / macro.speed.value) do

                Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(macro.speed.value), 0)

                RS.Heartbeat:Wait()

            end

        end

    end

end)



game:GetService("RunService").RenderStepped:Connect(function()

    if not getgenv().nebula.hitbox.enabled.value then return end

    

    local localPlayer = game.Players.LocalPlayer

    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then

        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

        local hasWhitelistedWeapon = false

        

        if humanoid then

            for _, tool in next, localPlayer.Character:GetChildren() do

                if tool:IsA("Tool") then

                    for _, weaponName in next, getgenv().nebula.whitelist.weapons do

                        if tool.Name == weaponName then

                            hasWhitelistedWeapon = true

                            break

                        end

                    end

                end

            end

        end

        

        for _, v in next, game.Players:GetPlayers() do

            if v ~= localPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then

                local bodyEffects = v.Character:FindFirstChild("BodyEffects")

                local isKnocked = getgenv().nebula.checks.knocked and bodyEffects and bodyEffects:FindFirstChild("K.O") and bodyEffects["K.O"].Value == true

                local isGrabbed = getgenv().nebula.checks.grabbed and bodyEffects and bodyEffects:FindFirstChild("Grabbed") and bodyEffects["Grabbed"].Value == true

                local isKOd = getgenv().nebula.checks.dead and bodyEffects and bodyEffects:FindFirstChild("Dead") and bodyEffects["Dead"].Value == true

                

                local hitboxSize = getgenv().nebula.hitbox.size.default.value

                local distance = (localPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude



                -- Ensure that minimum_size exists, and if not, use a default value (e.g., 2.00)

                local minimumSize = getgenv().nebula.hitbox.minimum_size and getgenv().nebula.hitbox.minimum_size.value or 2.00



                if distance < hitboxSize then

                    hitboxSize = math.max(distance, minimumSize)

                end

                

                if getgenv().nebula.whitelist.enabled then

                    if hasWhitelistedWeapon and getgenv().nebula.hitbox.custom_sizes_enabled.value then  -- Check if custom sizes are enabled

                        for weapon, size in pairs(getgenv().nebula.hitbox.custom_sizes) do

                            for _, tool in next, localPlayer.Character:GetChildren() do

                                if tool:IsA("Tool") and tool.Name == weapon then

                                    hitboxSize = size.value

                                    break

                                end

                            end

                        end

                    end

                end

                

                if isKnocked or isGrabbed or isKOd then

                    v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 2)

                    v.Character.HumanoidRootPart.CanCollide = false

                else

                    v.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)

                    v.Character.HumanoidRootPart.CanCollide = false

                end

            end

        end

    end

end)

