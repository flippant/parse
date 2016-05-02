--[[ TO DO

	-- Specific handling of acc/racc to be more user-friendly
	-- Specific handling of da/ta/qa/ua/sa/ea/oa?

]]

function report_data(stat,chatmode,chattarget)
	local valid_chatmodes = S{'s','p','t','l','l2'}
	
	-- If user doesn't enter a damage, then correct arguments
	if not stat then
		stat = 'damage'
	elseif valid_chatmodes[stat] then
		chattarget = chatmode
		chatmode = stat
		stat = 'damage'
	end
	if not valid_chatmodes[chatmode] then
		chatmode = nil
	end
	if chatmode == 't' and chattarget then
		chat_prefix = chatmode..' '..chattarget
	else
		chat_prefix = chatmode
	end
	
	if S{'acc','accuracy','hitrate'}:contains(stat) then
		stat = 'melee'
	elseif S{'racc'}:contains(stat) then
		stat = 'ranged'
	elseif S{'evasion','eva'}:contains(stat) then
		stat = 'evade'
	end
	
	report_string = ""
	sorted_players = L{}
	sorted_players = get_sorted_players(stat,20)

	-- if stat is damage
	if stat == 'damage' then
		report_string = report_string .. '[Total damage] '..update_filters()..' | '
		for player in sorted_players:it() do
			report_string = report_string .. (player..': '..get_player_stat_percent(stat,player)..'% ('..get_player_damage(player)..'), ')
		end
	elseif get_stat_type(stat)=='category' then		
		report_string = report_string .. '[Reporting '..stat..' stats] '..update_filters()..' | '
		player_spell_table = get_player_spell_table(stat)
		for player in sorted_players:it() do
			report_string = report_string .. (player..': ')
			report_string = report_string .. ('{Total} ')
			if get_player_stat_avg(stat,player) then report_string = report_string .. ('~'..get_player_stat_avg(stat,player)..'avg ') end	
			report_string = report_string .. ('('..get_player_stat_tally(stat,player)..'s) ')
			for spell,spell_table in pairs(player_spell_table[player]) do	
				report_string = report_string .. ('['..spell..'] ')
				report_string = report_string .. ('~'..math.floor(spell_table.damage / spell_table.tally)..'avg ')			
				report_string = report_string .. ('('..spell_table.tally..'s) ')				
			end
			report_string = report_string .. (' | ')			
		end
	elseif get_stat_type(stat)=='multi' or stat=='multi' then
		report_string = report_string .. '[Reporting multihit stats] '..update_filters()..' | '
		for player in sorted_players:it() do
			report_string = report_string .. (player..': ')
			report_string = report_string .. ('{Total} ')
			report_string = report_string .. ('~'..get_player_stat_avg(stat,player)..'avg ')			
			for i=1,8,1 do
				report_string = report_string .. ('['..i..'-hit] ')
				if get_player_stat_percent(i,player) then report_string = report_string .. (''..get_player_stat_percent(tostring(i),player)..'% ') end		
				report_string = report_string .. ('('..get_player_stat_tally(tostring(i),player)..'s)')
				report_string = report_string .. (', ')
			end
			report_string = report_string .. (' | ')
		end
	elseif get_stat_type(stat) then
		report_string = report_string .. '[Reporting '..stat..' stats] '..update_filters()..' | '
		for player in sorted_players:it() do
			report_string = report_string .. (player..': ')
			--report_string = report_string .. (get_player_stat_damage(stat,player)..' ')
			if get_player_stat_percent(stat,player) then report_string = report_string .. (''..get_player_stat_percent(stat,player)..'% ') end
			if get_player_stat_avg(stat,player) then report_string = report_string .. ('~'..get_player_stat_avg(stat,player)..'avg ') end		
			report_string = report_string .. ('('..get_player_stat_tally(stat,player)..'s)')
			report_string = report_string .. (', ')
		end
	else
		message('That stat was not found. Reportable stats include:')
		message('damage, melee, crit, miss, ranged, r_crit, r_miss, spike, sc, add, hit, block, evade, parry, intimidate, absorb, ws, ws_miss, ja, ja_miss, spell')
		return
	end
	
	--remove last two characters of report_string (extra comma+space)
	report_string = report_string:slice(1,#report_string-2)
	
	-- Split lines into table of 100-char strings
	line_cap = 90
	--report_table = report_string:chunks(line_cap)
	report_table = report_string:split('| ')
	report_table['n'] = nil
	
	-- report
	for i,line in pairs(report_table) do
		if #line <= line_cap then
			if chat_prefix then windower.send_command('input /'..chat_prefix..' '..line) coroutine.sleep(1.5)
			else message(line) end		
		else
			-- line_table = line:chunks(line_cap)
			line_table = prepare_string(line,line_cap)
			line_table['n'] = nil
			for i,subline in pairs(line_table) do
				if chat_prefix then windower.send_command('input /'..chat_prefix..' '..subline) coroutine.sleep(1.5)
				else message(subline) end		
			end
		end
	end
end


-- Takes string and returns table of strings
function prepare_string(str,cap) 
	-- split into tables by " "
	str_table = str:split(' ')
	str_table['n'] = nil
	new_string = ""
	new_table = L{}
	
	for i,word in pairs(str_table) do		
		new_string = new_string .. word .. ' '
		if #new_string > cap then
			new_table:append(new_string)
			new_string = ""
		end		
	end
	
	if new_string ~= "" then new_table:append(new_string) end
	
	return new_table
end