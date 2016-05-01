# parse
An FFXI Parser Addon for Windower. This addon parses both offensive and defensive data, as well as storing WS, JAs, and spells independently so that you can have more accurate data.

### Commands

`//parse pause`
Pauses the parser.

`//parse reset`
Resets the currently stored data.

`//parse report [stat] [chatmode]`
Reports stat to party. If [stat] not provided, will report total damage. If [chatmode] not provided, will print to personal chatlog. Valid stats include, but aren't limited to:
*damage
*melee|ranged (% reported is hit rate)
*crit|r_crit
*block|parry|evade
*ws|ja|spell (reports averages for each individual spell)

Valid chatmodes include:
*p: party
*s: say
*l: linkshell
*l2: linkshell2
*t [player name]: tell

`//parse filter add|remove|clear`
Filters data by monster name according to substrings.

`//parse show melee|ranged|magic|defense`
Toggles visibility of each display box. Note that while data is still parsed regardless of visibility, these displays are not updated unless visible, saving resources.

`//parse interval [number]`
Changes the interval rate at which the display boxes are updated. Default is '3', meaning the box will update once for every three recorded action packets.

`//parse rename [player/monster name] [new name]`
Renames a player or monster to a new name for all future, incoming data.

`//parse save [file name]`
Saves raw data as a tab-delimited file to the data/parse folder. Note that as raw data, it does not output percentages or averages, only total damage (or damage taken), and cardinality.

`//parse export|import [file name]`
Exports/imports XML data to/from the data/export folder. Imported data is merged with any current in-game data.
