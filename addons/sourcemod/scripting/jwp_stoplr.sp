#include <sourcemod>
#include <jwp>

#pragma newdecls required

#define PLUGIN_VERSION "1.2"
#define ITEM "stoplr"

ConVar g_CvarMaxStops;
int g_iStops;

public Plugin myinfo = 
{
	name = "[JWP] Stop LR",
	description = "Warden has access to stop lr",
	author = "White Wolf",
	version = PLUGIN_VERSION,
	url = "http://hlmod.ru"
};

public void OnPluginStart()
{
	g_CvarMaxStops = CreateConVar("jwp_stoplr_max", "2", "Сколько раз командир может останавливать lr за раунд");
	
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	if (JWP_IsStarted()) JWP_Started();
	AutoExecConfig(true, "stoplr", "jwp");
	
	LoadTranslations("jwp_modules.phrases");
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iStops = 0;
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
	if (!g_CvarMaxStops.IntValue)
		FormatEx(buffer, maxlength, "%T", "StopLR_Menu", client);
	else
		FormatEx(buffer, maxlength, "%T %T", "StopLR_Menu", client, "StopLR_StopLeft", client, g_CvarMaxStops.IntValue - g_iStops);
	return true;
}

public bool OnFuncSelect(int client)
{
	char langbuffer[48];
	if (!g_CvarMaxStops.IntValue)
	{
		JWP_ActionMsgAll("%T", "StopLR_ActionMessage_Stopped", client, client);
		ServerCommand("sm_stoplr"); // Stop lr by server.
	}
	else if (g_CvarMaxStops.IntValue && g_iStops < g_CvarMaxStops.IntValue)
	{
		JWP_ActionMsgAll("%T", "StopLR_ActionMessage_Stopped", client, client);
		ServerCommand("sm_stoplr"); // Stop lr by server.
		g_iStops++;
		int result = g_CvarMaxStops.IntValue - g_iStops;
		FormatEx(langbuffer, sizeof(langbuffer), "%T %T", "StopLR_Menu", client, "StopLR_StopLeft", client, result);
		JWP_RefreshMenuItem(ITEM, langbuffer, (!result) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	else
		JWP_ActionMsg(client, "%T", "StopLR_ActionMessage_ReachedMaximum", client);
	
	JWP_ShowMainMenu(client);
		
	return true;
}