#include <sdktools>
#include <socket>

float playerVelocity[3];
float PlayerfSpeed;
float posAng[3];
float posCoord[3];

int x;
int y;
int z;
int WriteNum = 0;
int TickNum = 0;

Handle g_BroadcastSocket;
int g_BroadcastPort = 27016;

Handle UDPEnabled;
Handle PrintToChatEnabled;

public Plugin myinfo = {
    name = "TickPosUDP",
    author = "Richard Franks",
    description = "Writes player data to a UDP stream each tick",
    version = "1.0",
    url = "http://nkenberger.com"
}

public void OnSocketError(Handle socket, int errorType, int errorNum, any arg) {
    LogError("Socket error: %d", errorNum);
    CloseHandle(socket);
}

public void InitUDP() {
    g_BroadcastSocket = SocketCreate(SOCKET_UDP, OnSocketError);
    SocketSetOption(g_BroadcastSocket, SocketReuseAddr, true);
    SocketSetOption(g_BroadcastSocket, SocketBroadcast, true);
}

public void OnPluginStart() {
    UDPEnabled = CreateConVar("sm_udp", "1", "1 enables UDP stream, any other disables");
    PrintToChatEnabled = CreateConVar("sm_tick_print", "0", "1 enables chat print, any other disables");
    AutoExecConfig();
    InitUDP();
}

public void OnGameFrame() {
    WriteNum++;

    for(int i = 1; i < MaxClients; i++) {
        if(IsClientInGame(i)) {
            GetEntPropVector(i, Prop_Data, "m_vecVelocity", playerVelocity);
            PlayerfSpeed = SquareRoot(playerVelocity[0]*playerVelocity[0] + playerVelocity[1]*playerVelocity[1]);
            TickNum++;
            GetClientAbsAngles(i, posAng);
            GetClientAbsOrigin(i, posCoord);

            x = RoundFloat(posCoord[0]);
            y = RoundFloat(posCoord[1]);
            z = RoundFloat(posCoord[2]);

            char message[256]; // Fixed declaration
        
            if(GetConVarInt(UDPEnabled) == 1) {
                // id, x, y, z, angle, speed, ticknum, writenum
                Format(message, sizeof(message), "%d, %d, %d, %d, %0.0f, %-.2f, %d, %d", i, x, y, z, posAng[1], PlayerfSpeed, TickNum, WriteNum);
                
                SendUDPData(message);

                if(GetConVarInt(PrintToChatEnabled) == 1) {
                    PrintToChat(i, "UDP written: %s", message);
                }
            }
        }
    }
}

// Fixed function signature
public void SendUDPData(const char[] broadcastData) {
    if(g_BroadcastSocket != INVALID_HANDLE) {
        SocketSendTo(g_BroadcastSocket, broadcastData, strlen(broadcastData), "255.255.255.255", g_BroadcastPort);
    }
}