#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <jwp>

#pragma newdecls required

#define PLUGIN_VERSION "1.4"
#define ITEM "noblock"

EngineVersion engine;
int g_CollisionGroupOffset;
ConVar Cvar_SolidTeamMates;
bool g_bNoblock, g_bOldValue;

public Plugin myinfo = 
{
	name = "[JWP] Noblock",
	description = "Warden can toggle noblock",
	author = "White Wolf",
	version = PLUGIN_VERSION,
	url = "http://hlmod.ru"
};

public void OnPluginStart()
{
	engine = GetEngineVersion();
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	
	if (engine == Engine_CSS)
	{
		g_CollisionGroupOffset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
		if (g_CollisionGroupOffset == -1)
			LogError("CBaseEntity::m_CollisionGroup offset not found");
		HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
		g_bOldValue = false;
	}
	
	if (JWP_IsStarted()) JWP_Started();
	
	LoadTranslations("jwp_modules.phrases");
}

public void OnConfigsExecuted()
{
	if (engine == Engine_CSGO)
	{
		Cvar_SolidTeamMates = FindConVar("mp_solid_teammates");
		g_bOldValue = Cvar_SolidTeamMates.BoolValue;
	}
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (engine == Engine_CSGO)
	{
		Cvar_SolidTeamMates.SetBool(g_bOldValue, true, false);
		g_bNoblock = !g_bOldValue;
	}
	else
	{
		for (int i = 1; i <= MaxClients; ++i)
			NoblockEntity(i, false);
		g_bNoblock = g_bOldValue;
	}
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (engine == Engine_CSS)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		NoblockEntity(client, g_bNoblock);
	}
}

public void JWP_Started()
{
	JWP_AddToMainMenu(ITEM, OnFuncDisplay, OnFuncSelect);
}

public void OnPluginEnd()
{
	JWP_RemoveFromMainMenu();
}

public bool OnFuncDisplay(int client, char[] buffer, int maxlength, int style)
{
	FormatEx(buffer, maxlength, "[%s]%T", (g_bNoblock) ? '-' : '+', "Noblock_Menu", client);
	return true;
}

public bool OnFuncSelect(int client)
{
	char menuitem[48];
	g_bNoblock = !g_bNoblock;
	if (engine == Engine_CSGO)
		Cvar_SolidTeamMates.SetBool(!g_bNoblock, true, false);
	else
	{
		for (int i = 1; i <= MaxClients; ++i)
			NoblockEntity(i, g_bNoblock);
	}
	if (g_bNoblock)
	{
		FormatEx(menuitem, sizeof(menuitem), "[-]%T", "Noblock_Menu", client);
		JWP_RefreshMenuItem(ITEM, menuitem);
	}
	else
	{
		FormatEx(menuitem, sizeof(menuitem), "[+]%T", "Noblock_Menu", client);
		JWP_RefreshMenuItem(ITEM, menuitem);
	}
	JWP_ActionMsgAll("%t \x02%t", "Noblock_ActionMessage_Title", (g_bNoblock) ? "Noblock_ActionMessage_On":"Noblock_ActionMessage_Off");
	JWP_ShowMainMenu(client);
	return true;
}

void NoblockEntity(int client, bool state = true)
{
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_T)
		SetEntData(client, g_CollisionGroupOffset, (state) ? 2 : 5, 4, true);
}