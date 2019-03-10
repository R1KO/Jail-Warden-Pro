#include <sourcemod>
#include <jwp>

// Force 1.7 syntax
#pragma newdecls required

#define PLUGIN_VERSION "1.2"
#define ITEM "otkaz"

public Plugin myinfo =
{
	name = "[JWP] Otkaz Module",
	description = "JWP otkaz module for using from warden menu",
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
	JWP_AddToMainMenu(ITEM, OnFuncDisplay, OnFuncSelect);
}

public void OnPluginEnd()
{
	JWP_RemoveFromMainMenu();
}

public bool OnFuncDisplay(int client, char[] buffer, int maxlength, int style)
{
	FormatEx(buffer, maxlength, "%t", "Otkaz_Menu", client);
	return true;
}

public bool OnFuncSelect(int client)
{
	FakeClientCommandEx(client, "sm_wotkaz");
	return true;
}
