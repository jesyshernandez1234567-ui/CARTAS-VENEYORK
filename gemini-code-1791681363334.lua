-- Servicios necesarios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuración
local EVENTS_HUNT_PATH = Workspace:WaitForChild("EventsHunt") -- Ruta basada en tu imagen
local DELAY_ENTRE_CARTAS = 1.5 -- Tiempo de espera en segundos al llegar a cada carta

-- Función para mover al jugador hacia la posición de la carta
local function teletransportarA(partTarget)
	if not partTarget then return end
	
	-- Obtenemos el CFrame o posición (asumiendo que tiene una parte base o Model con PrimaryPart/Pivot)
	local targetCFrame
	if partTarget:IsA("Model") then
		targetCFrame = partTarget:GetPivot()
	elseif partTarget:IsA("BasePart") then
		targetCFrame = partTarget.CFrame
	end

	if targetCFrame and humanoidRootPart then
		-- Nos elevamos ligeramente para evitar traspasar el suelo y causar bugs de físicas
		humanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 3, 0)
		task.wait(DELAY_ENTRE_CARTAS)
	end
end

-- Función principal para buscar y farmear las cartas de forma dinámica
local function iniciarAutoFarmCartas()
	print("Iniciando buscador automático de cartas en EventsHunt...")
	
	while true do
		-- Buscamos todos los elementos dentro de EventsHunt
		local hijos = EVENTS_HUNT_PATH:GetChildren()
		local cartasEncontradas = 0

		for _, item in ipairs(hijos) do
			-- Verificamos si coincide con la estructura vista en tu imagen (ej. modelos o carpetas que contienen un objeto "Card")
			local cartaObj = item:FindFirstChild("Card") or (item.Name == "Card" and item)
			
			if cartaObj then
				cartasEncontradas = cartasEncontradas + 1
				print("¡Carta detectada:", item.Name, "-> Teletransportando...")
				
				-- Nos movemos hacia la ubicación de la carta
				teletransportarA(cartaObj)
			end
		end

		if cartasEncontradas == 0 then
			-- Si no hay cartas, esperamos un momento antes de volver a escanear (útil para cuando se regeneran)
			task.wait(2)
		else
			task.wait(1) -- Pequeña pausa antes de re-escanear el entorno
		end
	end
end

-- Ejecutar el script
task.spawn(iniciarAutoFarmCartas)