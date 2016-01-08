#include <sourcemod>
#include <serversys>

public Plugin myinfo = {
	name = "[Server-Sys] Analytics",
	description = "Providing analytical data for Server-Sys.",
	author = "whocodes",
	version = SERVERSYS_VERSION,
	url = SERVERSYS_URL
}

/* Player data */
float g_fJoinTime[MAXPLAYERS+1];

int g_iKills[MAXPLAYERS+1];
int g_iDeaths[MAXPLAYERS+1];
int g_iShotsFired[MAXPLAYERS+1];
int g_iShotsHit[MAXPLAYERS+1];
int g_iWin[MAXPLAYERS+1];
int g_iLose[MAXPLAYERS+1];
int g_iTied[MAXPLAYERS+1];
int g_iSurvived[MAXPLAYERS+1];

int g_iPlaytime[MAXPLAYERS+1];
int g_iTotalTime[MAXPLAYERS+1];

bool g_bLoaded[MAXPLAYERS+1];

/* Map data */
float g_fMapStartTime[MAXPLAYERS+1];
int g_fMapTime;


public void OnPlayerIDLoaded(int client, int playerid){
	g_fJoinTime[client] = GetEngineTime();

	Sys_DB_LoadAnalytics(client);
}

public void OnClientDisconnect(int client){
	Sys_DB_UpdateAnalytics(client, true);
}

public void OnMapIDLoaded(int mapid){
	g_fMapStartTime = GetEngineTime();
}

public void OnMapEnd(){
	/* Map time tracking */
	if(Sys_GetMapID() != -1){
		char query[1024];
		Format(query, sizeof(query), "INSERT INTO maptime (sid, mid) VALUES (%d, %d) ON DUPLICATE KEY UPDATE time = time + %d;",
			Sys_GetServerID(), Sys_GetMapID(), RoundToFloor(GetEngineTime() - g_fMapStartTime));

		Sys_DB_TQuery(GenericCB, query);
	}
}

public void Sys_DB_LoadAnalytics(int client){
	g_bLoaded[client] = false;

	char query[255];
	Format(query, sizeof(query), "SELECT time, kills, deaths, mvp, assist, damage_done, damage_taken, shots_fired, shots_hit,  FROM stats WHERE pid = %d AND sid = %d;", Sys_GetPlayerID(client), Sys_GetServerID());

	Sys_DB_TQuery(Sys_DB_LoadAnalytics_CB, query, GetClientSerial(client));
}

public void Sys_DB_LoadAnalytics_CB(Handle owner, Handle hndl, const char[] error, any data){
	int client = GetClientFromSerial(data);

	if(client == 0 || (!IsClientConnected(client)))
		return;

	if(hndl == INVALID_HANDLE){
		LogError("[serversys] core :: Error loading analytics data for (%N): %s", client, error);
		return;
	}

	if(!SQL_FetchRow(hndl)){
		/* Now we create their row */
		int pid = Sys_GetPlayerID(client);
		int sid = Sys_GetServerID();

		char query[255];
		Format(query, sizeof(query), "INSERT INTO stats (pid, sid) VALUES (%d, %d);", pid, sid);

		Sys_DB_TQuery(Sys_DB_RegisterAnalytics_CB, query, GetClientSerial(client));
	} else {
		g_bLoaded[client] = true;

		g_iPlayTime[client] = SQL_FetchInt(hndl, 0);
	}
}

public void Sys_DB_RegisterAnalytics_CB(Handle owner, Handle hndl, const char[] error, any data){
	int client = GetClientFromSerial(data);

	if(client == 0 || (!IsClientConnected(client)))
		return;

	if(hndl == INVALID_HANDLE){
		LogError("[serversys] core :: Error registering stats for (%N): %s", client, error);
		return;
	} else {
		/* Player is now for sure created, let's try again */
		Sys_DB_LoadPlayTime(client);
	}
}

public void Sys_DB_UpdateAnalytics(int client, bool disc = false, Transaction hTransaction = view_as<Handle>(INVALID_HANDLE)){
	if(!g_bLoaded[client])
		return;

	int pid = Sys_GetPlayerID(client);
	int sid = Sys_GetPlayerID;

	int time = RoundToFloor(GetEngineTime() - g_fPlayerJoinTime[client]);
	char query[255];

	if(disc && time > 0){
		Format(query, sizeof(query), "UPDATE stats SET time = ((SELECT time FROM playtime AS x WHERE pid = %d AND sid=%d) + %d) WHERE pid = %d AND sid = %d;",
			pid, sid, time, pid, sid);
	}else{
		Format(query, sizeof(query), "UPDATE stats SET kills = %d, dea");
	}

	if(hTransaction != INVALID_HANDLE)
		hTransaction.AddQuery(query, GetClientSerial(client));
	else
		Sys_DB_TQuery(GenericCB, query, GetClientSerial(client));
}

public void GenericCB(Handle owner, Handle hndl, const char[] error, any data){
	if(hndl == INVALID_HANDLE){
		LogError("[serversys] analytics :: Error on SQL from generic CB: %s", error);
		return;
	}
}
