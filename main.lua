-- C-curity by danny9484
PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("C-curity")
	Plugin:SetVersion(1)

	-- Hooks
		cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, MyOnPlayerSpawned);

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that

	-- Command Bindings
  cPluginManager.BindCommand("/cip", "ccurity.ip", cip_player, " ~ get ip of a player")
	cPluginManager.BindCommand("/ciplist", "ccurity.iplist", cip_list_player, " - get ip list of all online players")
	cPluginManager.BindConsoleCommand("cip", cip_console, " ~ get ip of a player")
	cPluginManager.BindConsoleCommand("ciplist", cip_list_console, " - get ip list of all online players")
	cPluginManager.BindCommand("/report", "ccurity.report",report_command, " ~ report a player")

	-- create database if exist
	db = cSQLiteHandler("c-curity.sqlite")
	create_database()

	LOG("Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())

	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function MyOnPlayerSpawned(Player)
	if Player:HasPermission("ccurtiy.admin") then
		show_not_seen_by_admin(Player)
	end
end

function show_not_seen_by_admin(Player)
	local whereList = cWhereList()
	:Where("seen_by_admin", "0")
	local res = db:Select("reports", "*", whereList)
	local counter = #res
	while counter > 0 do
		Player:SendMessage(res[counter]["reporter"] .. " Reported " .. res[counter]["reported"])
		set_seen_by_admin(res[counter]["reported"], res[counter]["reporter"])
		counter = counter - 1
	end
end

function set_seen_by_admin(reported_player, reporter)
	local updateList = cUpdateList()
	:Update("seen_by_admin", "1")
	local whereList = cWhereList()
	:Where("reporter", reporter)
	:Where("reported", reported_player)
	local res = db:Update("reports", updateList, whereList)
end

function count_reports(player_name)
	local whereList = cWhereList()
	:Where("reported", player_name)
	local res = db:Select("reports", "ID", whereList)
	return #res
end

function report(reported_player, reporter)
	local whereList = cWhereList()
	:Where("reported", reported_player)
	:Where("reporter", reporter)
	local res = db:Select("reports", "*", whereList)
	if res[1] ~= nil then
		return false
	end
	local insertList = cInsertList()
	:Insert("reporter", reporter)
	:Insert("reported", reported_player)
	:Insert("date", os.date())
	:Insert("seen_by_admin", 0)
	:Insert("reported_ip", string.sub(cget_ip(reported_player), 8))
	local res = db:Insert("reports", insertList)
	return true
end

function report_command(command, Player)
	if #command ~= 2 then
		Player:SendMessage("Usage: /report <player>")
		return true
	end
	if command[2] == Player:GetName() then
		Player:SendMessage("you can't report yourself")
		return true
	end
	local report_callback = function(Player)
		reported_player = Player:GetName()
		if Player:HasPermission("ccurity.admin") then
			IsAdmin = true
			return true
		end
		if count_reports(Player:GetName()) >= 10 then
			cRoot:QueueExecuteConsoleCommand("/ban " .. reported_player)
			cRoot:QueueExecuteConsoleCommand("/banip " .. string.sub(cget_ip(reported_player)))
		end
	end
	if cRoot:Get():FindAndDoWithPlayer(command[2], report_callback) then
		local reporter = Player:GetName()
		if IsAdmin then
			Player:SendMessage("Can't Report a Admin")
		end
		if report(reported_player, reporter) then
			Player:SendMessage("Player " .. reported_player .. " has been reported")
			return true
		else
			Player:SendMessage("You already reported " .. reported_player)
			return true
		end
	else
		Player:SendMessage("Player " .. command[2] .. " not found :(")
		return true
	end
end

function cip_player(name, Player)
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
		return true
	end
	local worlds = function (cWorld)
		cWorld:DoWithPlayer(player_s, cget_ip_callback)
		return true
	end
	ip = nil
	cRoot:Get():ForEachWorld(worlds)
	return ip
end

function cip_list_player(Command, User)
	local cget_ip_callback = function (Player)
		playername = Player:GetName()
		ip = Player:GetIP()
		User:SendMessage(playername .. " | " .. string.sub(ip, 8))
	end
	cRoot:Get():ForEachPlayer(cget_ip_callback)
	return true
end

function cip_list_console()
	local cget_ip_callback = function (Player)
		playername = Player:GetName()
		ip = Player:GetIP()
		LOG(playername .. " | " .. string.sub(ip, 8))
	end
	cRoot:Get():ForEachPlayer(cget_ip_callback)
	return true
end

function cip_console(name)
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

function create_database()
-- Create DB if not exists
local db = cSQLiteHandler("c-curity.sqlite",
	cTable("reports")
	:Field("ID", "INTEGER", "PRIMARY KEY AUTOINCREMENT")
	:Field("reporter", "TEXT")
	:Field("reported", "TEXT")
	:Field("reported_ip", "TEXT")
	:Field("date", "TEXT")
	:Field("seen_by_admin", "INTEGER")
)
  return true
end
