CMD:myworld(playerid,params[])
{
	PlayerWorld[playerid] = (playerid+1);
	SetPlayerVirtualWorld(playerid,PlayerWorld[playerid]);
	SendClientMessage(playerid,X11_LIGHTBLUE,"WORLD: "WHITE"Welcome to your world!");
	return 1;
}
CMD:public(playerid,params[])
{
	PlayerWorld[playerid] = 0;
	SetPlayerVirtualWorld(playerid,PlayerWorld[playerid]);
	SendClientMessage(playerid,X11_LIGHTBLUE,"WORLD: "WHITE"Welcome to public world!");
	return 1;
}
CMD:invite(playerid,params[])
{
	if(!IsNull(params))
	{
		if(!strcmp(params,"accept",true))
		{
			if(WorldInvite[playerid] == -1) return SEM(playerid,"ERROR: Nobody sent you a world invite!");
			PlayerWorld[playerid] = WorldInvite[playerid];
			SetPlayerVirtualWorld(playerid,PlayerWorld[playerid]);
			WorldInvite[playerid] = -1;
		}
		else
		{
			new string[144],playername[MAX_PLAYER_NAME],targetid;
			if(GetPlayerVirtualWorld(playerid) != (playerid+1)) return SEM(playerid,"ERROR: You are not in your own virtual world!");
			if(sscanf(params,"u",targetid)) return SEM(playerid,"USAGE: /invite [playerid/name/accept]");
			if(targetid == INVALID_PLAYER_ID) return SEM(playerid,"ERROR: Invalid playerid/name!");
			WorldInvite[targetid] = PlayerWorld[playerid];
			GetPlayerName(playerid,playername,MAX_PLAYER_NAME);
			format(string,sizeof(string),"WORLD: "YELLOW"%s "WHITE"has sent you a world invite!",playername);
			SendClientMessage(targetid,X11_LIGHTBLUE,string);
			SendClientMessage(targetid,X11_LIGHTBLUE,"HINT: "WHITE"Use "YELLOW"/invite accept "WHITE"to accept world invite!");
			SendClientMessage(playerid,X11_LIGHTBLUE,"WORLD: "WHITE"World invite sent!");
		}
	}
	return 1;
}
