-- C-curity by danny9484
PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("C-curity")
	Plugin:SetVersion(1)

	-- Hooks

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that

	-- Command Bindings
  cPluginManager.BindCommand("/cip", "ccurity.ip", cip_player, " ~ get ip of a player")
	cPluginManager.BindCommand("/ciplist", "ccurity.iplist", cip_list_player, " - get ip list of all online players")
	cPluginManager.BindConsoleCommand("cip", cip_console, " ~ get ip of a player")
	cPluginManager.BindConsoleCommand("ciplist", cip_list_console, " - get ip list of all online players")


	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())

	return true
end

function OnDisable()
	Player:SendMessage(PLUGIN:GetName() .. " is shutting down...")
end

function cip_player (name, Player)
	if (#name ~= 2) then
		Player:SendMessage("Usage: cip [playername]")
		return true
	end
	ip = cget_ip(name[2])
	if ip == nil then
		Player:SendMessage("Player " .. name[2] .. " not found :(")
		return true
	end
	Player:SendMessage(string.sub(ip, 8))
	return true
end

function cget_ip(player_s)
	local cget_ip_callback = function (Player)
		ip = Player:GetIP()
		return ip
	end
	local worlds = function (cWorld)
		cWorld:DoWithPlayer(player_s, cget_ip_callback)
		return true
	end
	ip = nil
	cRoot:Get():ForEachWorld(worlds)
	return ip
end

function cip_list_player()
	local cget_ip_callback = function (Player)
		playername = Player:GetName()
		ip = Player:GetIP()
		Player:SendMessage(playername .. " | " .. ip)
		return ip
	end
	cRoot:Get():ForEachPlayer(cget_ip_callback)
end

function cip_list_console()
	local cget_ip_callback = function (Player)
		playername = Player:GetName()
		ip = Player:GetIP()
		LOG(playername .. " | " .. ip)
		return ip
	end
	cRoot:Get():ForEachPlayer(cget_ip_callback)
end

function cip_console (name)
	if (#name ~= 2) then
		LOG("Usage: cip [playername]")
		return true
	end
	ip = cget_ip(name[2])

	if ip == nil then
		LOG("Player " .. name[2] .. " not found :(")
		return true
	end
	LOG(string.sub(ip, 8))
	return true
end
