#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <jwp>

#pragma newdecls required

#define PLUGIN_VERSION "1.3"
#define ITEM "coloring"

bool g_bColoring;

public Plugin myinfo = 
{
	name = "[JWP] Coloring",
	description = "Warden can divide players of terrorist team",
	author = "White Wolf",
	version = PLUGIN_VERSION,
	url = "http://hlmod.ru"
};

public void OnPluginStart()
{
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_PostNoCopy);
	if (JWP_IsStarted()) JWP_Started();
	
	LoadTranslations("jwp_modules.phrases");
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bColoring = false;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bColoring = false;
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
	FormatEx(buffer, maxlength, "[%s]%T", (g_bColoring) ? '-' : '+', "Coloring_Menu", client);
	return true;
}

public bool OnFuncSelect(int client)
{
	g_bColoring = !g_bColoring;
	if (g_bColoring)
	{
		bool red;
		for (int i = 1; i <= MaxClients; ++i)
		{
			if (CheckClient(i) && !JWP_PrisonerHasFreeday(i))
			{
				SetEntityRenderMode(i, RENDER_TRANSCOLOR);
				
				red = !red;
				if (red)
				{
					SetEntityRenderColor(i, 255, 0, 0, 255);
					JWP_ActionMsg(i, "%t %t", "Coloring_Your_Color", "Coloring_Red_Color");
				}
				else
				{
					SetEntityRenderColor(i, 0, 0, 255, 255);
					JWP_ActionMsg(i, "%t %t", "Coloring_Your_Color", "Coloring_Blue_Color");
				}
			}
		}
	}
	else
	{
		for (int i = 1; i <= MaxClients; ++i)
		{
			if (CheckClient(i) && !JWP_PrisonerHasFreeday(i))
			{
				SetEntityRenderMode(i, RENDER_TRANSCOLOR);
				SetEntityRenderColor(i, 255, 255, 255, 255);
				JWP_ActionMsg(i, "%t %t", "Coloring_Your_Color", "Coloring_Standart_Color");
			}
		}
	}
	
	char menuitem[48];
	if (g_bColoring)
	{
		FormatEx(menuitem, sizeof(menuitem), "[-]%T", "Coloring_Menu", client);
		JWP_RefreshMenuItem(ITEM, menuitem);
	}
	else
	{
		FormatEx(menuitem, sizeof(menuitem), "[+]%T", "Coloring_Menu", client);
		JWP_RefreshMenuItem(ITEM, menuitem);
	}
	JWP_ActionMsg(client, "%t %t", "Coloring_ActionMessage", (g_bColoring) ? "Coloring_State_On" : "Coloring_State_Off");
	JWP_ShowMainMenu(client);
	return true;
}

bool CheckClient(int client)
{
	return (IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client) && (GetClientTeam(client) == CS_TEAM_T) && IsPlayerAlive(client));
}