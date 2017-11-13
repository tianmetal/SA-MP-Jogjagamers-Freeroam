CMD:gotols(playerid,params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid),1529.6,-1691.2,13.3);
    else SetPlayerPos(playerid,1529.6,-1691.2,13.3);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
CMD:gotosf(playerid,params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), -2015.261108, 154.379516, 27.687500);
    else SetPlayerPos(playerid, -2015.261108, 154.379516, 27.687500);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
CMD:gotolv(playerid,params[])
{
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), 1699.2,1435.1, 10.7);
    else SetPlayerPos(playerid, 1699.2,1435.1, 10.7);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
CMD:drift1(playerid,params[])
{
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), -2423.1755,-608.8604,132.3824);
    else SetPlayerPos(playerid, -2423.1755,-608.8604,132.3824);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
CMD:drift2(playerid,params[])
{
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), -300.5935,1523.9900,75.1813);
    else SetPlayerPos(playerid, -300.5935,1523.9900,75.1813);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
CMD:tune1(playerid, params[])
{
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), 2645.0479,-2029.2050,13.2063);
    else SetPlayerPos(playerid, 2645.0479,-2029.2050,13.2063);
    SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
    return 1;
}
CMD:tune2(playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), -2705.1987,217.7348,3.8386);
	else SetPlayerPos(playerid, -2705.1987,217.7348,3.8386);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
CMD:tune3(playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), 1041.0607,-1039.9507,31.4253);
	else SetPlayerPos(playerid, 1041.0607,-1039.9507,31.4253);
	SendClientMessage(playerid,X11_LIGHTBLUE,"TELEPORT: "WHITE"You have been teleported!");
	return 1;
}
