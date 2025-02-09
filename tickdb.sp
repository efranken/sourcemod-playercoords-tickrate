#include <sourcemod>
#include <sdktools>

new Float:playerVelocity[3];
new Float:PlayerfSpeed;
new Float:posAng[3];
new Float:posCoord[3];

new TickNum = 0;
new Handle:dbWriteEnabled = INVALID_HANDLE;
new Handle:PrintToChatEnabled = INVALID_HANDLE;
static Handle:database;
#define PLUGIN_VERSION "1.0"

public Plugin:myinfo = {
    name = "TickPos",
    author = "Richard Franks",
    description = "Writes player data to a database each tick",
    version = PLUGIN_VERSION,
    url = "http://nkenberger.com"
}

public OnPluginStart()
{
    //Initialize database
    decl String:error[255];
    database = SQL_Connect("ml", true, error, sizeof(error));
    if (database == INVALID_HANDLE) {
        SetFailState("dbstats plugin couldn't connect to database. Error: %s", error);
        return;
    }

    //Clear old records from database, leaving commented out for git
    /*
    new now = GetTime();
    decl String:query[255];    
    Format(query,sizeof(query), "DELETE FROM playerloc");
    SQL_TQuery(database, validate_delete_ml, query, now);
    */

    dbWriteEnabled = CreateConVar("sm_tick_db", "1", "1 enables db write, any other disables")
    PrintToChatEnabled = CreateConVar("sm_tick_print", "0", "1 enables chat print, any other disables")

    AutoExecConfig(); //create config if it didn't exist
}

public OnGameFrame()
{

    for (new i = 1; i < MaxClients; i++)
    {
        if(IsClientInGame(i))
        {
            GetEntPropVector(i, Prop_Data, "m_vecVelocity", playerVelocity);
            PlayerfSpeed = SquareRoot(playerVelocity[0]*playerVelocity[0] + playerVelocity[1]*playerVelocity[1]);
            TickNum++;
            GetClientAbsAngles(i, posAng);
            GetClientAbsOrigin(i, posCoord)

            //build query for DB, do not write unless dbWriteEnabled = 1
            new now = GetTime();
            decl String:query[255];
            Format(query, sizeof(query), "INSERT INTO playerloc (id, x, y, z, angle, speed, ticknum) VALUES(%d, %0.0f, %0.0f, %0.0f, %0.0f, %-.2f, %d)",
            i, posCoord[0], posCoord[1], posCoord[2], posAng[1], PlayerfSpeed, TickNum);

            if(GetConVarInt(PrintToChatEnabled))
            {
                PrintToChat(i, query);
            }

            if(GetConVarInt(dbWriteEnabled))
            {
                SQL_TQuery(database, validate_insert_ml, query, now);
                PrintToConsole(i, "wrote to DB with %s", query);
            }
        }
    }
}

public validate_insert_ml(Handle:owner, Handle:hndl, const String:error[], any:query_time) {
    static last_failure = 0;
    if (hndl == INVALID_HANDLE && query_time - last_failure >= 3600) {
        LogError("Insert into ml table failed with error: '%s'; subsequent warnings supressed for 1 hour", error);
        last_failure = query_time;
    }
}

public validate_delete_ml(Handle:owner, Handle:hndl, const String:error[], any:query_time) {
    static last_failure = 0;
    if (hndl == INVALID_HANDLE && query_time - last_failure >= 3600) {
        LogError("Delete ml table failed with error: '%s'; subsequent warnings supressed for 1 hour", error);
        last_failure = query_time;
    }
}