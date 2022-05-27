--[====[
-- Эта тулза сканирует все скрипты в папке gamedata\\scripts и ищет _потенциально_ неиспользуемые.
-- Перед удалением, надо обязательно проверять, не вызываются ли они из всяких диалогов, конфигов (биндеры) и тп.

local excluded_scripts = { --Скрипты, вызываемые из движка
	["_g"] = true,
	["class_registrator"] = true,
	["ui_wpn_params"] = true,
}

local script_storage --Таблица с именами всех скриптов. Формат: ["имя_скрипта"] = "полный путь до него"
local scrips_to_delete --Таблица с именами скриптов, которые потенциально могут быть мусором (не вызываются из других скриптов)

local function file_exists(name) --Более нормального способа проверить существование файла, в lua вроде бы нет.
	local f = io.open(name, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function init() --Составляет таблицу с именами всех скриптов в папке и путями до них
	script_storage, scrips_to_delete = {}, {}
	--
	local flist = getFS():file_list_open_ex( "$game_scripts$", FS.FS_ListFiles + FS.FS_ClampExt, "*.script" )
	for i = 0, flist:Size() - 1 do
		local file  = flist:GetAt( i )
		local name_short = file:NameShort()
		if name_short ~= script_name() then --самого себя не учитываем.
			local fname = name_short..".script"
			local full_path = getFS():update_path("$game_scripts$", fname)
			if file_exists(full_path) then --Если файл находится в папке со скриптами, а не в .db*
				script_storage[name_short] = full_path
			end
		end
	end
end

local function process()
	local found_musor = false
	for script_name, _ in pairs(script_storage) do
		if not excluded_scripts[script_name] then --Исключения не обрабатываем
			for check_script, script_full_path in pairs(script_storage) do
				if check_script ~= script_name then --самого себя не проверяем
					for line in io.lines(script_full_path) do --Перебираем все строки скрипта check_script в поисках обращения к script_name.
						--if line:find(script_name) then --так будет много пропусков.
						if
							line:find(script_name..".", 1, true)
							or line:find(script_name.."[", 1, true)
							or line:find("'"..script_name.."'", 1, true)
							or line:find('"'..script_name..'"', 1, true)
							or line:--[[trim():]]find(script_name..',', 1, true)
							or line:trim():find(','..script_name, 1, true)
						then
							goto CONTINUE
						end
					end
				end
			end
			--
			script_storage[script_name] = nil
			scrips_to_delete[script_name] = true
			found_musor = true
			::CONTINUE::
		end
	end
	return found_musor
end


function garbage_collect()
	if not script_storage then init() end --если надо, инициализируемся
	--
	while process() do end --Цикл выполняется пока process() возвращает true
	--
	log3("Potential garbage scripts: %s", scrips_to_delete) --Отчитываемся, какой мусор нашли
	--
	script_storage, scrips_to_delete = nil, nil
end
--]====]

--[====[
--Поиск старых визуалов и звуков в конфигах
local need_visuals, need_sounds = {},{}

local function check_section(sect)
	local t = get_section_keys_and_values(sect)
	for k,v in pairs(t) do
		if k:find("visual") then
			if v:find("weapons") and not v:find("dynamics") then
				local vis = v:find(".ogf") and v or v..".ogf"
				local exploded_vis = string.explode("\\", vis, true)
				need_visuals[exploded_vis[#exploded_vis]] = true
			end
		elseif k:find("snd_") and not get_string(sect, "visual", ""):find("dynamics") then
			if v:find("weapons") then
				local exploded_snd = string.explode("\\", v, true)
				local exploded_snd2 = string.explode(",", exploded_snd[#exploded_snd], true)
				need_sounds[#exploded_snd2 > 0 and exploded_snd2[1]..".ogg" or exploded_snd[#exploded_snd]..".ogg"] = true
			end
		end
	end
end

sys_ini:iterate_sections( check_section )



--Поиск старых визуалов в оллспавне
local path = getFS():update_path( "$game_spawn$", "" )
stdfs.recursive_directory_iterator( path, function( file )
  if file.extension == ".ltx" then
	for line in io.lines(file.full_path_name) do
		if line:find("visual") and line:find("weapons") and not line:find("dynamics") then
			for vis in pairs(need_visuals) do
				if line:find(vis) then
					goto CONTINUE
				end
			end
			local _vis = line:sub(15):find(".ogf") and line:sub(15) or line:sub(15)..".ogf"
			local exploded_vis = string.explode("\\", _vis, true)
			need_visuals[exploded_vis[#exploded_vis]] = true
		end
		::CONTINUE::
	end
  end
end )

log3("--need_old_wpn_visuals: %s", need_visuals)
log3("--need_old_wpn_sounds: %s", need_sounds)



local visuals_dirs = {
	"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xxfix\\gamedata\\meshes\\weapons",
	"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xpatch\\gamedata\\meshes\\weapons",
	"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_meshes\\gamedata\\meshes\\weapons",
}
for _, dir in ipairs(visuals_dirs) do
	stdfs.recursive_directory_iterator( dir, function( file )
		if need_visuals[file.full_filename] then
			log3("--NOT removed: [%s]", file.full_path_name)	
			return
		end

		log3("~~removed: [%s]", file.full_path_name)
		os.remove(file.full_path_name)
	end )
end


local sounds_dirs = {
	"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xxfix\\gamedata\\sounds\\weapons",
	"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xpatch\\gamedata\\sounds\\weapons",
}
for _, dir in ipairs(sounds_dirs) do
	stdfs.recursive_directory_iterator( dir, function( file )
		if need_sounds[file.full_filename] then
			log3("--NOT removed: [%s]", file.full_path_name)	
			return
		end

		log3("~~removed: [%s]", file.full_path_name)
		os.remove(file.full_path_name)
	end )
end

--]====]

--[===[
--Поиск старых визуалов и звуков в конфигах
local need_visuals, need_sounds = {},{}

local function check_section(sect)
	local t = get_section_keys_and_values(sect)
	for k,v in pairs(t) do
		if k:find("visual") then
			if v:find("weapons") and not v:find("dynamics") then
				need_visuals[v:find(".ogf") and v or v..".ogf"] = true
			end
		elseif k:find("snd_") and not get_string(sect, "visual", ""):find("dynamics") then
			if v:find("weapons") then
				local exploded_snd2 = string.explode(",", v, true)
				need_sounds[#exploded_snd2 > 0 and exploded_snd2[1]..".ogg" or v..".ogg"] = true
			end
		end
	end
end

sys_ini:iterate_sections( check_section )



--Поиск старых визуалов в оллспавне
local path = getFS():update_path( "$game_spawn$", "" )
stdfs.recursive_directory_iterator( path, function( file )
  if file.extension == ".ltx" then
	for line in io.lines(file.full_path_name) do
		if line:find("visual") and line:find("weapons") and not line:find("dynamics") then
			for vis in pairs(need_visuals) do
				if line:find(vis) then
					goto CONTINUE
				end
			end
			need_visuals[line:sub(15):find(".ogf") and line:sub(15) or line:sub(15)..".ogf"] = true
		end
		::CONTINUE::
	end
  end
end )

log3("--need_old_wpn_visuals: %s", need_visuals)
log3("--need_old_wpn_sounds: %s", need_sounds)



local visuals_dirs = {
	--"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xxfix\\gamedata\\meshes\\weapons",
	--"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xpatch\\gamedata\\meshes\\weapons",
	--"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_meshes\\gamedata\\meshes\\weapons",
}
for _, dir in ipairs(visuals_dirs) do
	stdfs.recursive_directory_iterator( dir, function( file )
		for visual in pairs(need_visuals) do
			if file.full_path_name:find(visual) then
				log3("--NOT removed: [%s]", file.full_path_name)			
				return
			end
		end

		log3("~~removed: [%s]", file.full_path_name)
		os.remove(file.full_path_name)
	end )
end

local sounds_dirs = {
	--"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xxfix\\gamedata\\sounds\\weapons",
	--"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_xpatch\\gamedata\\sounds\\weapons",
	"F:\\Games\\OGSR Mod\\!!!UNPACK\\gamedata_db_base_sounds\\gamedata\\sounds\\weapons",
}
for _, dir in ipairs(sounds_dirs) do
	stdfs.recursive_directory_iterator( dir, function( file )
		for snd in pairs(need_sounds) do
			if file.full_path_name:find(snd) then
				log3("--NOT removed: [%s]", file.full_path_name)			
				return
			end
		end

		log3("~~removed: [%s]", file.full_path_name)
		os.remove(file.full_path_name)
	end )
end
--]===]