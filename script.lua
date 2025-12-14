-- Flick Ultimate Script v3.3 (с цветными тогглами)
-- Дополнение к предыдущему коду

-- Функция для отрисовки цветного переключателя
local function ToggleSwitch(label, state, colorOn, colorOff)
    local toggleWidth = 40
    local toggleHeight = 20
    local toggleRadius = toggleHeight / 2
    
    -- Получаем позицию курсора для определения ховера
    local mouseX, mouseY = imgui.GetMousePos()
    local toggleX = imgui.GetCursorScreenPos()
    local toggleY = toggleY or toggleX.y
    local cursorX = imgui.GetCursorPosX()
    
    -- Рисуем текст
    imgui.Text(label)
    imgui.SameLine()
    
    -- Вычисляем позицию тоггла
    local availableWidth = imgui.GetContentRegionAvail()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - toggleWidth - 25)
    
    -- Определяем цвет тоггла
    local color
    if state then
        color = colorOn or {0.6, 0.2, 0.9, 1.0} -- Светло-фиолетовый при включении
    else
        color = colorOff or {0.3, 0.3, 0.3, 1.0} -- Тёмно-серый при выключении
    end
    
    -- Рисуем фон тоггла
    imgui.PushStyleColor(imgui.Col.FrameBg, {0.15, 0.15, 0.15, 1.0})
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, {0.2, 0.2, 0.2, 1.0})
    
    -- Кнопка-переключатель
    if imgui.Button("##" .. label, toggleWidth, toggleHeight) then
        state = not state
    end
    
    -- Заполняем цветом состояния
    local drawList = imgui.GetWindowDrawList()
    local min = imgui.GetItemRectMin()
    local max = imgui.GetItemRectMax()
    
    -- Скруглённый прямоугольник с цветом состояния
    drawList:AddRectFilled(min, max, imgui.GetColorU32(color), toggleRadius)
    
    -- Белая точка-индикатор
    if state then
        local circlePos = {min.x + toggleWidth - toggleRadius - 2, min.y + toggleRadius}
        drawList:AddCircleFilled(circlePos, toggleRadius - 3, imgui.GetColorU32({1,1,1,1}))
    else
        local circlePos = {min.x + toggleRadius + 2, min.y + toggleRadius}
        drawList:AddCircleFilled(circlePos, toggleRadius - 3, imgui.GetColorU32({0.8,0.8,0.8,1}))
    end
    
    -- Контур
    drawList:AddRect(min, max, imgui.GetColorU32({0.5,0.5,0.5,1}), toggleRadius)
    
    imgui.PopStyleColor(2)
    
    return state
end

-- Обновлённая функция отрисовки интерфейса
local function DrawMenu()
    if not Config.Menu.Visible then return end
    
    -- Установка позиции и размера окна
    imgui.SetNextWindowPos(Config.Menu.X, Config.Menu.Y, imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(Config.Menu.Width, Config.Menu.Height)
    
    -- Стиль окна
    imgui.PushStyleColor(imgui.Col.WindowBg, {0.08, 0.06, 0.12, Config.Menu.Alpha})
    imgui.PushStyleColor(imgui.Col.TitleBg, {0.25, 0.00, 0.50, 1.00})
    imgui.PushStyleColor(imgui.Col.TitleBgActive, {0.35, 0.00, 0.70, 1.00})
    imgui.PushStyleColor(imgui.Col.Button, {0.40, 0.00, 0.80, 1.00})
    imgui.PushStyleColor(imgui.Col.ButtonHovered, {0.50, 0.00, 1.00, 1.00})
    
    -- Начало окна
    if imgui.Begin("Flick Ultimate v3.3", Config.Menu.Visible, 
        imgui.WindowFlags.NoCollapse | 
        imgui.WindowFlags.NoResize | 
        imgui.WindowFlags.NoScrollbar) then
        
        -- Заголовок с кнопками управления
        imgui.TextColored({0.8, 0.4, 1.0, 1.0}, "FLICK ULTIMATE")
        imgui.SameLine(imgui.GetWindowWidth() - 100)
        
        -- Кнопка сворачивания
        if imgui.Button("_", 20, 20) then
            Config.Menu.Height = 30 -- Минимальная высота
        end
        
        imgui.SameLine()
        
        -- Кнопка закрытия (крестик)
        if imgui.Button("X", 20, 20) then
            Config.Menu.Visible = false
        end
        
        imgui.Separator()
        
        -- Проверка высоты для сворачивания
        if Config.Menu.Height > 30 then
            -- Табы
            if imgui.BeginTabBar("MainTabs") then
                -- ВКЛАДКА 1: AIMBOT
                if imgui.BeginTabItem("Aimbot") then
                    imgui.BeginChild("AimbotTab", {0, 0}, true)
                    
                    -- Переключатель аимбота
                    Config.Aimbot.Active = ToggleSwitch("Aimbot", Config.Aimbot.Active)
                    
                    if Config.Aimbot.Active then
                        imgui.Indent(15)
                        
                        -- Настройки аимбота
                        imgui.TextColored({0.7, 0.7, 1.0, 1.0}, "Настройки:")
                        
                        -- Поле зрения
                        _, Config.Aimbot.FOV = imgui.SliderInt("FOV", math.floor(Config.Aimbot.FOV), 10, 360)
                        
                        -- Сглаживание
                        _, Config.Aimbot.Smooth = imgui.SliderFloat("Сглаживание", Config.Aimbot.Smooth, 0.01, 1.0, "%.2f")
                        
                        -- Проверка стен
                        Config.Aimbot.WallCheck = ToggleSwitch("Проверка стен", Config.Aimbot.WallCheck)
                        
                        -- Предсказание
                        Config.Aimbot.Prediction = ToggleSwitch("Предсказание", Config.Aimbot.Prediction)
                        
                        -- Кость для прицеливания
                        local bones = {"Голова", "Грудь", "Таз"}
                        local currentBone = 1
                        if Config.Aimbot.BonePriority[1] == "Head" then currentBone = 1
                        elseif Config.Aimbot.BonePriority[1] == "UpperTorso" then currentBone = 2
                        else currentBone = 3 end
                        
                        _, currentBone = imgui.Combo("Кость", currentBone, bones, #bones)
                        Config.Aimbot.BonePriority[1] = currentBone == 1 and "Head" or (currentBone == 2 and "UpperTorso" or "LowerTorso")
                        
                        -- Человечность
                        if imgui.CollapsingHeader("Человечность") then
                            Config.Aimbot.Humanizer.Enabled = ToggleSwitch("Включить", Config.Aimbot.Humanizer.Enabled)
                            
                            if Config.Aimbot.Humanizer.Enabled then
                                _, Config.Aimbot.Humanizer.ReactionTime = imgui.SliderInt("Реакция (мс)", Config.Aimbot.Humanizer.ReactionTime, 50, 300)
                                _, Config.Aimbot.Humanizer.Jitter = imgui.SliderFloat("Джиттер", Config.Aimbot.Humanizer.Jitter, 0, 0.2, "%.2f")
                                _, Config.Aimbot.Humanizer.MissChance = imgui.SliderInt("Шанс промаха %", Config.Aimbot.Humanizer.MissChance, 0, 30)
                            end
                        end
                        
                        imgui.Unindent(15)
                    end
                    
                    imgui.EndChild()
                    imgui.EndTabItem()
                end
                
                -- ВКЛАДКА 2: ESP
                if imgui.BeginTabItem("ESP") then
                    imgui.BeginChild("ESPTab", {0, 0}, true)
                    
                    Config.ESP.Enabled = ToggleSwitch("ESP", Config.ESP.Enabled)
                    
                    if Config.ESP.Enabled then
                        imgui.Indent(15)
                        
                        -- Настройки игроков
                        if imgui.CollapsingHeader("Игроки") then
                            Config.ESP.Players.Box = ToggleSwitch("Боксы", Config.ESP.Players.Box)
                            Config.ESP.Players.Health = ToggleSwitch("Здоровье", Config.ESP.Players.Health)
                            Config.ESP.Players.Name = ToggleSwitch("Имена", Config.ESP.Players.Name)
                            Config.ESP.Players.Distance = ToggleSwitch("Дистанция", Config.ESP.Players.Distance)
                            Config.ESP.Players.Snapline = ToggleSwitch("Линии", Config.ESP.Players.Snapline)
                        end
                        
                        -- Цвета
                        if imgui.CollapsingHeader("Цвета") then
                            _, Config.ESP.Players.BoxColor = imgui.ColorEdit4("Цвет боксов", Config.ESP.Players.BoxColor)
                            _, Config.ESP.Players.HealthColor = imgui.ColorEdit4("Цвет здоровья", Config.ESP.Players.HealthColor)
                            _, Config.ESP.Players.SnaplineColor = imgui.ColorEdit4("Цвет линий", Config.ESP.Players.SnaplineColor)
                        end
                        
                        -- Дистанция
                        _, Config.ESP.Players.MaxDist = imgui.SliderInt("Макс. дистанция", Config.ESP.Players.MaxDist, 50, 500)
                        
                        imgui.Unindent(15)
                    end
                    
                    imgui.EndChild()
                    imgui.EndTabItem()
                end
                
                -- ВКЛАДКА 3: MOVEMENT
                if imgui.BeginTabItem("Движение") then
                    imgui.BeginChild("MovementTab", {0, 0}, true)
                    
                    -- Банихоп
                    Config.Movement.Bhop.Enabled = ToggleSwitch("Банихоп", Config.Movement.Bhop.Enabled)
                    
                    if Config.Movement.Bhop.Enabled then
                        imgui.Indent(15)
                        local modes = {"Простой", "Идеальный", "Рандомный"}
                        _, Config.Movement.Bhop.Mode = imgui.Combo("Режим", Config.Movement.Bhop.Mode, modes, #modes)
                        _, Config.Movement.Bhop.HitChance = imgui.SliderInt("Шанс срабатывания %", Config.Movement.Bhop.HitChance, 50, 100)
                        Config.Movement.Bhop.Strafe = ToggleSwitch("Страфы", Config.Movement.Bhop.Strafe)
                        imgui.Unindent(15)
                    end
                    
                    -- Бесконечный прыжок
                    Config.Movement.InfiniteJump = ToggleSwitch("Беск. прыжок", Config.Movement.InfiniteJump)
                    
                    if Config.Movement.InfiniteJump then
                        imgui.Indent(15)
                        _, Config.Movement.JumpPower = imgui.SliderFloat("Сила прыжка", Config.Movement.JumpPower, 0.5, 3.0, "%.2f")
                        imgui.Unindent(15)
                    end
                    
                    -- Скорость
                    _, Config.Movement.Speed = imgui.SliderFloat("Скорость", Config.Movement.Speed, 0.5, 3.0, "%.2f")
                    
                    -- Автостраф
                    Config.Movement.AutoStrafe = ToggleSwitch("Автостраф", Config.Movement.AutoStrafe)
                    
                    imgui.EndChild()
                    imgui.EndTabItem()
                end
                
                -- ВКЛАДКА 4: ВИЗУАЛЫ
                if imgui.BeginTabItem("Визуалы") then
                    imgui.BeginChild("VisualsTab", {0, 0}, true)
                    
                    Config.Visuals.NoFlash = ToggleSwitch("Убрать вспышку", Config.Visuals.NoFlash)
                    Config.Visuals.NoSmoke = ToggleSwitch("Убрать дым", Config.Visuals.NoSmoke)
                    
                    -- ФОВ
                    _, Config.Visuals.FOV = imgui.SliderInt("Поле зрения", Config.Visuals.FOV, 70, 120)
                    
                    -- Яркость
                    _, Config.Visuals.Brightness = imgui.SliderFloat("Яркость", Config.Visuals.Brightness, 0.5, 2.0, "%.1f")
                    
                    -- Прицел
                    Config.Visuals.Crosshair = ToggleSwitch("Прицел", Config.Visuals.Crosshair)
                    
                    if Config.Visuals.Crosshair then
                        imgui.Indent(15)
                        _, Config.Visuals.CrosshairColor = imgui.ColorEdit4("Цвет прицела", Config.Visuals.CrosshairColor)
                        imgui.Unindent(15)
                    end
                    
                    imgui.EndChild()
                    imgui.EndTabItem()
                end
                
                -- ВКЛАДКА 5: БЕЗОПАСНОСТЬ
                if imgui.BeginTabItem("Безопасность") then
                    imgui.BeginChild("SafetyTab", {0, 0}, true)
                    
                    Config.Safety.RandomDelays = ToggleSwitch("Случайные задержки", Config.Safety.RandomDelays)
                    Config.Safety.MimicHuman = ToggleSwitch("Имитация человека", Config.Safety.MimicHuman)
                    Config.Safety.SpoofCalls = ToggleSwitch("Скрытие вызовов", Config.Safety.SpoofCalls)
                    
                    -- Макс. действий в секунду
                    _, Config.Safety.MaxAPSCheck = imgui.SliderInt("Макс. APS", Config.Safety.MaxAPSCheck, 20, 120)
                    
                    imgui.EndChild()
                    imgui.EndTabItem()
                end
                
                imgui.EndTabBar()
            end
            
            imgui.Separator()
            
            -- СТАТУС БАР
            local statusText = "Активен"
            local statusColor = {0.0, 1.0, 0.0, 1.0}
            
            imgui.TextColored(statusColor, "✓ " .. statusText)
            imgui.SameLine()
            imgui.TextColored({0.7, 0.7, 0.7, 1.0}, "| FPS: " .. math.floor(1/RunService.RenderStepped:Wait()))
        end
        
        imgui.End()
    end
    
    imgui.PopStyleColor(5)
end

-- Обработчик клавиши F
local function HandleHotkeys()
    if UserInputService:IsKeyDown(Enum.KeyCode.F) then
        if not keyPressed then
            Config.Menu.Visible = not Config.Menu.Visible
            if Config.Menu.Visible and Config.Menu.Height <= 30 then
                Config.Menu.Height = 550 -- Восстановление высоты
            end
            keyPressed = true
        end
    else
        keyPressed = false
    end
end

-- Основной цикл
local function MainLoop()
    while task.wait(0.01) do
        -- Обработка горячих клавиш
        HandleHotkeys()
        
        -- Рендер интерфейса
        DrawMenu()
        
        -- Применение функций читов
        if Config.Aimbot.Active then
            ApplyAimbot()
        end
        
        if Config.ESP.Enabled then
            DrawESP()
        end
        
        if Config.Movement.Bhop.Enabled then
            ApplyBunnyhop()
        end
        
        if Config.Movement.InfiniteJump then
            ApplyInfiniteJump()
        end
    end
end

-- Запуск с задержкой
task.wait(2)
MainLoop()
