#include <sourcemod>
#include <sdktools>
#include <jwp>

#pragma newdecls required

#define PLUGIN_VERSION "1.3"
#define DROPEN "door_aim_open"
#define DRCLOSE "door_aim_close"

public Plugin myinfo = 
{
	name = "[JWP] Door Aim Control",
	description = "Give warden access to open certain doors",
	author = "White Wolf",
	version = PLUGIN_VERSION,
	url = "http://hlmod.ru"
};

public void OnPluginStart()
{
	if (JWP_IsStarted()) JWP_Started();
	LoadTranslations("jwp_modules.phrases");
}

public void JWP_Started()
{
	JWP_AddToMainMenu(DROPEN, OnFuncDrOpenDisplay, OnFuncDrOpenSelect);
	JWP_AddToMainMenu(DRCLOSE, OnFuncDrCloseDisplay, OnFuncDrCloseSelect);
}

public void OnPluginEnd()
{
	JWP_RemoveFromMainMenu();
}

public bool OnFuncDrOpenDisplay(int client, char[] buffer, int maxlength, int style)
{
	Format(buffer, maxlength, "%T", "DoorAimControl_Menu_Open", client);
	return true;
}

public bool OnFuncDrOpenSelect(int client)
{
	if (!JWP_IsFlood(client, 3))
		DoorManip(client, true);
	JWP_ShowMainMenu(client);
	return true;
}

public bool OnFuncDrCloseDisplay(int client, char[] buffer, int maxlength, int style)
{
	Format(buffer, maxlength, "%T", "DoorAimControl_Menu_Close", client);
	return true;
}

public bool OnFuncDrCloseSelect(int client)
{
	if (!JWP_IsFlood(client, 3))
		DoorManip(client, false);
	JWP_ShowMainMenu(client);
	return true;
}

void DoorManip(int client, bool open)
{
	int ent = TiB_GetAimInfo(client);
	char class[28];
	if (IsValidEdict(ent) && ent > MaxClients && GetEntityClassname(ent, class, sizeof(class)) && TiB_IsDoor(class))
	{
		AcceptEntityInput(ent, "Unlock");
		if (open)
		{
			AcceptEntityInput(ent, "Open");
			JWP_ActionMsg(client, "\x03%t", "DoorAimControl_ActionMessage_Open");
		}
		else
		{
			AcceptEntityInput(ent, "Close");
			JWP_ActionMsg(client, "\x02%t", "DoorAimControl_ActionMessage_Close");
		}
	}
	else
		PrintCenterText(client, "%t", "DoorAimControl_Take_Aim");
}

int TiB_GetAimInfo(int client)
{
	float origin[3], angles[3];
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);
	TR_TraceRayFilter(origin, angles, MASK_SHOT, RayType_Infinite, TraceFilter_Callback, client);
	if (!TR_DidHit()) return -1;
	return TR_GetEntityIndex();
}

public bool TraceFilter_Callback(int ent, int mask, int client)
{
	return (client != ent);
}

bool TiB_IsDoor(const char[] classname)
{
	return (StrContains(classname, "movelinear", false) || StrContains(classname, "door", false) || StrContains(classname, "plat", false) || StrContains(classname, "rotating", false) || StrContains(classname, "tracktrain", false));
}