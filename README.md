# parse v1.61
An FFXI Parser Addon for Windower. This addon parses both offensive and defensive data, stores WS/JAs/spells data by individual spell, tracks additional information like multihit rates, and provides the ability to export/import data in XML format and log individually recorded data.

### Settings
For now, refer to the Excel Spreadsheet for a brief description of Parse settings. Note that at some point, the settings will be getting a bit of a face lift...

### Commands

`//parse pause`
Pauses the parser.

`//parse reset`
Resets the currently stored data.

`//parse report [stat] [ability name] [chatmode]` Reports stat to party. 
If [stat] not provided, will report damage. Valid stats include, but aren't limited to:
* damage (% reported is player's portion of total damage)
* melee | ranged (% reported is hit rate)
* crit | r_crit
* multi (reports % and count of double attacks, triple attacks, etc., but does not distinguish between OAX, nor accommodates for killing blows; i.e. if you kill in one hit, it will only ever record as 1-hit)
* block | parry | evade (% reported is based on action hierarchy; for example, block % excludes evades and parry % excludes both evades and non-engaged hits taken)
* ws | ja | spell | mb | enfeeb (reports averages for total category, and each individual spell; also reports hit rate % for total ws/ja)
* ws_miss | ja_miss | enfeeb_miss (reports counts for individual spell)

If [ability name] is provided when reporting WS, JA, spell, MB, or enfeeb, it will only report that particular ability. **It must be an exact match to the database, and is thus case sensitive.** Replace all spaces with an underscore and omit all apostrophes and other special characters. For example:
* `//parse report ws Rudras_Storm`
* `//parse report mb Death l2`

If [chatmode] not provided, will print to personal chatlog. Valid chatmodes include:
* p: party
* s: say
* l: linkshell
* l2: linkshell2
* t [player name]: tell

`//parse show (melee|ranged|magic|defense)`
Toggles visibility of each display box. Note that while data is still parsed regardless of visibility, these displays are not updated unless visible, saving resources.

`//parse filter (add|remove) [substring]`
Adds/removes substring to monster filter list. Substring is not case sensitive; replace all spaces with underscores and omit special characters. If substring begins with '!' it will exclude any monsters with that substring. If substring begins with '^' it will only include exact matches. For example:
* `schah` will include Schah and all of his minions.
* `!schah` will exclude Schah and all of his minions (Schah's Bhata, etc.).
* `^schah` will only include Schah, and not his minions. 
* `!^schah` will exclude only Schah.

`//parse filter clear`
Clears filter list.

`//parse list (mobs|players)`
Lists mobs and players that are found in database.

`//parse rename [player/monster name] [new name]`
Renames a player or monster to a new name for all future, incoming data. To rename again, always use the original name. Replace any spaces with _ and omit all special characters.

`//parse (export|import) [file name]`
Exports/imports data to/from the "parse/data/export" folder. Imported data is merged with any current in-game data. If file name is taken, it will append os.clock. NOTE: Exported data will be saved according to any current filters.

`//parse autoexport [file name]`
Automatically exports database every 500 actions. This interval can be changed in settings under autoexport_interval. Use command again with no file name, or 'off' to turn it off.

`//parse log`
Toggles logging.

`//parse interval [number]`
Changes the interval rate at which the display boxes are updated in seconds. Default interval is in settings.

### Logging
As opposed to export, which saves the in-game database to an XML file, logging records each individual action's parameters to a file. For example, export will only save the total damage and total count of Flippant's Rudra's Storms against Wild Rabbits; but logging will save how much *each* Rudra's Storm did.

Logging data is automatic, as long as the player being recorded is listed in the logger option of your settings. This is case-sensitive, and wildcard (\*) at the end of a name is permitted (this allows defensive data to be recorded easily, despite changes in name due to special indexing).

Data is saved to /parse/data/log, in folders designated according to the *recording* player, to a file named after the recorded player, monster name, and stat (melee, ws, etc.). Data is *not* logged if it does not have a damage parameter—for example, it will not record parries, enfeebles, misses, etc. Category sections (ws, ja, spell, mb) will save the spell name next to the damage.

If data has not been saved to that file since the last time Parse was loaded, it will first append time and date for quick reference.
