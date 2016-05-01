--[[ TO DO:

	-- Clean construct_database of extraneous details
	-- Completely rethink and redo the txt export	
	
]]

files = require('files')
xml = require('xml')

function import_parse(file_name)   
	local path = '/data/export/'..file_name
	
	import = files.new(path..'.xml', true)
	parsed, err = xml.read(import)
	
	if not parsed then
		message(err or 'XML error: Unknown error.')
		return
	end
	
	imported_database = construct_database(parsed)	
	merge_tables(database,imported_database)
	--message(print_table(database))

	message('Parse ['..file_name..'] was imported to database!')
end

function export_parse(file_name)   
	-- if   then
		-- message('No data found, could not export parse.')
		-- return
	-- end
	
    if not windower.dir_exists(windower.addon_path..'data') then
        windower.create_dir(windower.addon_path..'data')
    end
	if not windower.dir_exists(windower.addon_path..'data/export') then
        windower.create_dir(windower.addon_path..'data/export')
    end
	
	local path = windower.addon_path..'data/export/'
	if file_name then
		path = path..file_name
	else
		path = path..os.date(' %H %M %S%p  %y-%d-%m')
	end
	
	if windower.file_exists(path..'.xml') then
		path = path..'_'..os.clock()
	end
	
	local f = io.open(path..'.xml','w+')
	f:write('<database>\n')
	
	--f:write(to_xml(database))
	
	--in order to filter mobs
	for mob,data in pairs(database) do		
		if check_filters('mob',mob) then
			f:write('    <'..mob..'>\n')
			f:write(to_xml(data,'        '))
			f:write('    </'..mob..'>\n')
		end		
	end
	
	f:write('</database>')
	f:close()
	
	message('Database was exported to '..path..'.xml!')
	if get_filters()~="" then
		message('Note that the database was filtered by [ '..get_filters()..' ]')
	end
end

function to_xml(t,indent_string)
	local indent = indent_string or '    '
	local xml_string = ""
	for key,value in pairs(t) do
		xml_string = xml_string .. indent .. '<'..key:gsub(" ","_")..'>'		
		if type(value)=='number' then
			xml_string = xml_string .. value
			xml_string = xml_string .. '</'..key:gsub(" ","_")..'>\n'
		elseif type(value)=='table' then
			xml_string = xml_string .. '\n' .. to_xml(t[key],indent..'    ')
			xml_string = xml_string .. indent .. '</'..key:gsub(" ","_")..'>\n'
		end
		
	end
	
	return xml_string
end

-- Taking from config library, extraneous data here that should be taken out
function construct_database(node, settings, key, meta)
    settings = settings or T{}
    key = key or 'settings'
    meta = meta

    local t = T{}
    if node.type ~= 'tag' then
        return t
    end

    if not node.children:all(function(n)
        return n.type == 'tag' or n.type == 'comment'
    end) and not (#node.children == 1 and node.children[1].type == 'text') then
        error('Malformatted settings file.')
        return t
    end

    -- TODO: Type checking necessary? merge should take care of that.
    if #node.children == 1 and node.children[1].type == 'text' then
        local val = node.children[1].value
        if node.children[1].cdata then
            --meta.cdata:add(key)
            return val
        end

        if val:lower() == 'false' then
            return false
        elseif val:lower() == 'true' then
            return true
        end

        local num = tonumber(val)
        if num ~= nil then
            return num
        end

        return val
    end

    for child in node.children:it() do
        if child.type == 'comment' then
            meta.comments[key] = child.value:trim()
        elseif child.type == 'tag' then
            key = child.name
            local childdict
            if table.containskey(settings, key) then
                childdict = table.copy(settings)
            else
                childdict = settings
            end
            t[child.name] = construct_database(child, childdict, key, meta)
        end
    end

    return t
end

-- Very quick, very ugly way of saving parse...
-- Need something more fluid, and need to consider how to export it with mobs so that it can be imported later
function save_parse(file_name)   
	local player_table = collapse_mobs() or nil
	
	if not player_table then
		message('No data found, could not save parse. Try checking your filters.')
		return
	end
	
    if not windower.dir_exists(windower.addon_path..'data') then
        windower.create_dir(windower.addon_path..'data')
    end
	if not windower.dir_exists(windower.addon_path..'data/parse') then
        windower.create_dir(windower.addon_path..'data/parse')
    end
	
	local path = windower.addon_path..'data/parse/'
	if file_name then
		path = path..file_name
	else
		path = path..os.date(' %H %M %S%p  %y-%d-%m')
	end
	
	if windower.file_exists(path..'.txt') then
		path = path..'_'..os.clock()
	end
	
	local f = io.open(path..'.txt','w+')
	
	-- stats = L{'melee','crit','miss','ranged','r_crit','r_miss','ws','ws_miss','ja','ja_miss','spell','spike','sc','add','hit','block','evade','anticipate','intimidate','absorb'}
	-- f:write('player')
	-- for label in stats:it() do
		-- f:write('\t'..label)
	-- end
	-- f:write('\n')
	
	f:write('player\tmelee tally\tmelee damage\tmiss tally\tcrit tally\tcrit damage\tranged tally\tranged damage\tr_miss tally\tr_crit tally\tr_crit damage\t')
	f:write('ws tally\tws damage\tws_miss tally\tja tally\tja damage\tja_miss tally\tspell tally\tspell damage\t')
	f:write('hit tally\thit damage\tblock tally\tblock damage\tevade tally\tanticipate tally\tintimidate tally\tabsorb tally\tabsorb damage\t')
	f:write('spike tally\tspike damage\tsc tally\tsc damage\tadd tally\tadd damage')
	f:write('\n')
	
	for player,data_table in pairs(player_table) do
		f:write(player..'\t')
		if data_table["melee"] then
			if data_table["melee"]["melee"] then
				if data_table["melee"]["melee"].tally then
					f:write(data_table["melee"]["melee"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["melee"]["melee"].damage then
					f:write(data_table["melee"]["melee"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["melee"]["miss"] then
				if data_table["melee"]["miss"].tally then
					f:write(data_table["melee"]["miss"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["melee"]["crit"] then
				if data_table["melee"]["crit"].tally then
					f:write(data_table["melee"]["crit"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["melee"]["crit"].damage then
					f:write(data_table["melee"]["crit"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end	
		else
			f:write('0\t0\t0\t0\t0\t')
		end	
		if data_table["ranged"] then
			if data_table["ranged"]["ranged"] then
				if data_table["ranged"]["ranged"].tally then
					f:write(data_table["ranged"]["ranged"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["ranged"]["ranged"].damage then
					f:write(data_table["ranged"]["ranged"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["ranged"]["r_miss"] then
				if data_table["ranged"]["r_miss"].tally then
					f:write(data_table["ranged"]["r_miss"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["ranged"]["r_crit"] then
				if data_table["ranged"]["r_crit"].tally then
					f:write(data_table["ranged"]["r_crit"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["ranged"]["r_crit"].damage then
					f:write(data_table["ranged"]["r_crit"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
		else
			f:write('0\t0\t0\t0\t0\t')
		end
		if data_table["category"] then
			if data_table["category"]["ws"] then
				if data_table["category"]["ws"].tally then
					f:write(data_table["category"]["ws"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["category"]["ws"].damage then
					f:write(data_table["category"]["ws"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["category"]["ws_miss"] then
				if data_table["category"]["ws_miss"].tally then
					f:write(data_table["category"]["ws_miss"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["category"]["ja"] then
				if data_table["category"]["ja"].tally then
					f:write(data_table["category"]["ja"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["category"]["ja"].damage then
					f:write(data_table["category"]["ja"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["category"]["ja_miss"] then
				if data_table["category"]["ja_miss"].tally then
					f:write(data_table["category"]["ja_miss"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["category"]["spell"] then
				if data_table["category"]["spell"].tally then
					f:write(data_table["category"]["spell"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["category"]["spell"].damage then
					f:write(data_table["category"]["spell"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end			
		else
			f:write('0\t0\t0\t0\t0\t0\t0\t0\t')
		end
		if data_table["defense"] then
			if data_table["defense"]["hit"] then
				if data_table["defense"]["hit"].tally then
					f:write(data_table["defense"]["hit"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["defense"]["hit"].damage then
					f:write(data_table["defense"]["hit"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end			
			if data_table["defense"]["block"] then
				if data_table["defense"]["block"].tally then
					f:write(data_table["defense"]["block"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["defense"]["block"].damage then
					f:write(data_table["defense"]["block"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["defense"]["evade"] then
				if data_table["defense"]["evade"].tally then
					f:write(data_table["defense"]["evade"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["defense"]["anticipate"] then
				if data_table["defense"]["anticipate"].tally then
					f:write(data_table["defense"]["anticipate"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["defense"]["intimidate"] then
				if data_table["defense"]["intimidate"].tally then
					f:write(data_table["defense"]["intimidate"].tally..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t')
			end
			if data_table["defense"]["absorb"] then
				if data_table["defense"]["absorb"].tally then
					f:write(data_table["defense"]["absorb"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["defense"]["absorb"].damage then
					f:write(data_table["defense"]["absorb"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
		else
			f:write('0\t0\t0\t0\t0\t0\t0\t0\t0\t')
		end
		if data_table["other"] then
			if data_table["other"]["spike"] then
				if data_table["other"]["spike"].tally then
					f:write(data_table["other"]["spike"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["other"]["spike"].damage then
					f:write(data_table["other"]["spike"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["other"]["sc"] then
				if data_table["other"]["sc"].tally then
					f:write(data_table["other"]["sc"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["other"]["sc"].damage then
					f:write(data_table["other"]["sc"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end
			if data_table["other"]["add"] then
				if data_table["other"]["add"].tally then
					f:write(data_table["other"]["add"].tally..'\t')
				else
					f:write('0\t')
				end
				if data_table["other"]["add"].damage then
					f:write(data_table["other"]["add"].damage..'\t')
				else
					f:write('0\t')
				end
			else
				f:write('0\t0\t')
			end			
		else
			f:write('0\t0\t0\t0\t0\t0\t')
		end	
		f:write('\n')
	end
	
	f:close()
	
	message('Parse was saved to '..path..'.txt')
end