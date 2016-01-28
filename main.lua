-- C-curity by danny9484
PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("C-curity")
	Plugin:SetVersion(1)

	-- Hooks

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that

	-- Command Bindings
  cPluginManager.BindCommand("/cip", "ccurity.ip", cip_player, " ~ get ip of a player")
	cPluginManager.BindConsoleCommand("cip", cip_console, " ~ get ip of a player")


	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())

	-- Initialize Callback Functions
	worlds = function (cWorlds)
		local var = cWorlds:DoWithPlayer(name[2], get_ip)
		if 	var == nil then
			return true
		end
		ip = var
		return true
	end

	local get_ip = function (Player)
		ip = Player:GetIP()
		return ip
	end

	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function cip_player (name, Player)
	if (#name ~= 2) then
		Player:SendMessage("Usage: /cip [playername]")
		return true
	end
	cRoot:Get():FindAndDoWithPlayer(name[2], get_ip)
	if ip == nil then
		Player:SendMessage("Player " .. name[2] .. " not found :(")
		return true
	end
end

function cip_console (name)
	if (#name ~= 2) then
		LOG("Usage: cip [playername]")
		return true
	end
	cRoot:Get():ForEachWorld(worlds)
	-- cWorld = cRoot:Get():GetWorld("world")
	if ip == nil then
		LOG("Player " .. name[2] .. " not found :(")
		return true
	end
	LOG(string.sub(ip, 8))
	return true
end
