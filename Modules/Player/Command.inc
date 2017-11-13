CMD:godmode(playerid,params[])
{
	GodMode[playerid] = !(GodMode[playerid]);
	if(GodMode[playerid]) SendClientMessage(playerid,X11_LIGHTBLUE,"GODMODE: "WHITE"Godmode "GREEN"enabled");
	else
	{
		SetPlayerHealth(playerid,100.0);
		SendClientMessage(playerid,X11_LIGHTBLUE,"GODMODE: "WHITE"Godmode "RED"disabled");
	}
	return 1;
}
CMD:mycolor(playerid,params[])
{
	new red,green,blue;
	if(!sscanf(params,"ddd",red,green,blue))
	{
		SetPlayerColor(playerid,RGBAToInt(red,green,blue,255));
	}
	else SEM(playerid,"USAGE: /mycolor [red] [green] [blue]");
	return 1;
}
CMD:skin(playerid, params[])
{
    new skin = strval(params);
    if(IsNull(params) || !IsValidSkin(skin)) return SEM(playerid,"USAGE: /skin [skin id (0 - 311)]");
    SetPlayerSkin(playerid,skin);
    return 1;
}
CMD:killme(playerid,params[])
{
    SetPlayerHealth(playerid,0.0);
    SendClientMessage(playerid,X11_LIGHTBLUE,"SERVER: "WHITE"You have been killed!");
    return 1;
}
CMD:weap(playerid,params[])
{
    new weapon;
    if(sscanf(params,"k<weapon>",weapon)) return SEM(playerid,"USAGE: /weap [weapon name/id]");
    if(weapon == -1 || weapon == 44 || weapon == 45) return SEM(playerid,"ERROR: Invalid weapon!");
    GivePlayerWeapon(playerid,weapon,20000);
	return 1;
}
CMD:jumpmode(playerid,params[])
{
	JumpMode[playerid] = !(JumpMode[playerid]);
	if(JumpMode[playerid])
	{
		SendClientMessage(playerid,X11_LIGHTBLUE,"SERVER: "WHITE"Jump mode "GREEN"enabled!");
		SendClientMessage(playerid,X11_LIGHTBLUE,"HINT: "WHITE"Press "YELLOW"~k~~PED_JUMPING~ "WHITE"while on foot to jump higher!");
		SendClientMessage(playerid,X11_LIGHTBLUE,"HINT: "WHITE"Press "YELLOW"~k~~VEHICLE_HORN~  "WHITE"while driving to jump vehicle!");
	}
	else SendClientMessage(playerid,X11_LIGHTBLUE,"SERVER: "WHITE"Jump mode "RED"disabled!");
	return 1;
}
CMD:jetpack(playerid,params[])
{
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USEJETPACK);
	return 1;
}
CMD:notele(playerid,params[])
{
	NoTele[playerid] = !(NoTele[playerid]);
	if(NoTele[playerid]) SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "RED"Blocked "WHITE"other players for teleporting to you");
	else SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "GREEN"Allowed "WHITE"other players for teleporting to you");
	return 1;
}
CMD:goto(playerid,params[])
{
	new Float:cPos[3],targetid;
	if(sscanf(params,"u",targetid)) return SEM(playerid,"USAGE: /goto [playerid/name]");
	if(targetid == INVALID_PLAYER_ID) return SEM(playerid,"ERROR: Invalid playerid / name");
	if(NoTele[targetid]) return SEM(playerid,"ERROR: Not allowed to teleport to that player!");
	if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(playerid)) return SEM(playerid,"ERROR: Target player is not in the same virtual world as you!");
	GetPlayerPos(targetid,cPos[0],cPos[1],cPos[2]);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid),cPos[0],cPos[1],cPos[2]);
	else SetPlayerPos(playerid,cPos[0],cPos[1],cPos[2]);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
