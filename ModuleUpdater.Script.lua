if game:GetService("RunService"):IsRunning() then return end

local InsertService, ServerScriptService = game:GetService("InsertService"), game:GetService("ServerScriptService")

local Stringify = require(2789644632)

local function CreateConfigString(Config, ConfigDefaults)
	Config.SetupVersion = nil
	
	local Cfg = "return {"
	for i, Data in ipairs(ConfigDefaults) do
		if type(Data) == "table" then
			local Val = Config[Data[1]]
			if Val == nil then
				Val = Data[2]
			end
			if Data[4] then
				Val = Data[4](Val)
			end
			Val = Stringify(Val, Data[1], nil, 1)
			
			Cfg = Cfg .. (i ~= 1 and "\n	" or "") .. "\n" .. (Data[3]and "	--[[" .. Data[3] .. "]]\n" or "") .. Val .. ", -- Default - " .. Stringify(Data[2], nil, {NewLine = "", SecondaryNewLine = "", Tab = ""})
		else
			Cfg = Cfg .. (i ~= 1 and "\n	" or "") .. "\n	--------[[" .. Data .. "]]--------"
		end
	end
	
	return Cfg .. '\n	\n	SetupVersion = "' .. ConfigDefaults.SetupVersion .. '", -- DO NOT CHANGE THIS\n}'
end

local function Handle(Setup)
	local IDs = loadstring(Setup.Config.IDs.Source)()
	local NewSetup = select(2, next(game:GetObjects("rbxassetid://" .. IDs.Setup)))
	local NewModule = type(IDs.Module) == "number" and select(2, next(game:GetObjects("rbxassetid://" .. IDs.Module)))
	local ConfigDefaults = require(require(NewModule or IDs.Module):Get().ConfigDefaults)
	
	local OriginalConfig = loadstring(Setup.Config.Source)()
	local OriginalVersion = OriginalConfig.SetupVersion
	if OriginalVersion ~= ConfigDefaults.SetupVersion then
		local NewConf = CreateConfigString(OriginalConfig, ConfigDefaults)
		
		Setup:Destroy()
		
		NewSetup.Config.Source = NewConf
		NewSetup.Parent = game:GetService("ServerScriptService")
		
		warn(NewSetup.Name .. " was updated to version s" .. ConfigDefaults.SetupVersion .. " from version s" .. OriginalVersion .. ", please publish!")
		
		return true
	else
		NewSetup:Destroy()
		if NewModule then
			NewModule:Destroy()
		end
		
		warn(NewSetup.Name .. " was already the latest version - s" .. ConfigDefaults.SetupVersion)
	end
end

local Button = plugin:CreateToolbar("ModuleUpdater"):CreateButton("Update Modules", "Updates all modules present in the game", "")
Button.ClickableWhenViewportHidden = true
Button.Click:Connect(function()
	local Updated
	for _, Obj in ipairs(ServerScriptService:GetChildren()) do
		if Obj:IsA("Folder") and Obj:FindFirstChild("Setup") and Obj:FindFirstChild("Config") and Obj.Config:FindFirstChild("IDs") then
			Updated = Handle(Obj) or Updated
		end
	end
	
	if Updated then
		warn("Modules have been updated")
	else
		warn("Modules are already up to date")
	end
	
	Button:SetActive(false)
end)