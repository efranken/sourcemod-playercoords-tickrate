

# What is

SourceMod plugin that writes the first player's coordinates, angle, and horizontal speed to a database (`tickdb.sp`) or UDP stream (`tickudp.sp`)

Database mod was the first pass at exfiltrating player data.  Using a database as a middle man to read from proved too slow.  UDP was the second pass, and is much faster for exfiltrating and reading player data.

## UDP configuration

Defaults to port 27016, broadcasts all traffic on 255.255.255.255 from all NICs on 0.0.0.0.  

Requires SourceMod extension [sm-ext-socket](https://github.com/JoinedSenses/sm-ext-socket/releases/tag/v0.2).  To install:
 - Copy  `socket.inc` from `sm-ext-socket-0.2/scripting/include/` to `(server root)/CSS/cstrike/addons/sourcemod/scripting/include`
 - Copy `socket.ext.dll` from `sm-ext-socket-0.2/` to `(server root)/CSS/cstrike/addons/sourcemod/extensions`

Convars:
`sm_udp` enables/disables UDP transmission
`sm_tick_print` enables/disables printing UDP message to chat

## Database configuration:

 - Create a new Schema named ML in MySQL workbench
 - Send the following query to it to build the database structure

```
CREATE TABLE IF NOT EXISTS playerloc (
	id 		TINYINT 	UNSIGNED 	NOT NULL,
	x 		SMALLINT 				NOT NULL,
	y 		SMALLINT 				NOT NULL,
	z 		SMALLINT 				NOT NULL,
	angle 	SMALLINT 				NOT NULL,
	speed 	SMALLINT	UNSIGNED 	NOT NULL,
	ticknum INT 		UNSIGNED 	NOT NULL,
	INDEX (id)
) ENGINE=MyISAM

```
- Create a user under server/users and priveleges
- Set the password to Standard, the default may be caching_sha2_password
- Give the user rights to the table you created
- Add the following to your `/addons/sourcemod/configs/databases.cfg`

```
	"ml"
	{
		"driver" "mysql"
		"host" "localhost"
		"database" "ml"
		"user" "ml" CHANGE THIS LINE TO YOUR USER
		"pass" "ml" CHANGE THIS LINE TO YOUR PW
	}
```
Convars:
`sm_tick_db` enables/disables DB writing
`sm_tick_print` enables/disables printing DB query to chat

## Running the plugin:

Either compile the sp file with spcomp.exe after modifying to your liking, or drag and drop tickdb.smx into `\addons\sourcemod\plugins`