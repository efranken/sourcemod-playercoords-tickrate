

# Tickdb.sp

 Sourcemod plugin that writes player coordinates, angle, and horizontal speed to a database each tick.

## Database configuration:

 - Create a new Schema named ML in MySQL workbench
 - Send the following query to it to build the database structure

```
CREATE TABLE IF NOT EXISTS playerloc (
	id 	TINYINT 	UNSIGNED 	NOT NULL,
	x 	SMALLINT 			NOT NULL,
	y 	SMALLINT 			NOT NULL,
	z 	SMALLINT 			NOT NULL,
	angle 	SMALLINT 			NOT NULL,
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

  

## Running the plugin:

Either compile the sp file with spcomp.exe after modifying to your liking, or drag and drop tickdb.smx into `\addons\sourcemod\plugins`

By default, dbWriteEnabled and PrintToChatEnabled are both 1
