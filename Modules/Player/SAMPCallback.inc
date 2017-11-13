#include <YSI\y_hooks>

hook OnPlayerConnect(playerid)
{
	RaceCheck[playerid]++;
	return 1;
}
hook OnPlayerDisconnect(playerid, reason)
{
	if(PlayerLogged[playerid]) SavePlayer(playerid);
	if(PlayerInfo[playerid][ID] != 0) orm_destroy(PlayerInfo[playerid][ORM_ID]);
	PlayerInfo[playerid][ID] = 0;
	PlayerLogged[playerid] = false;
	JumpMode[playerid] = false;
	GodMode[playerid] = false;
	RaceCheck[playerid]++;
	return 1;
}
hook OnPlayerRequestClass(playerid, classid)
{
	if(!IsPlayerNPC(playerid))
	{
	    if(PlayerLogged[playerid]) SetSpawnInfo(playerid,-1,PlayerInfo[playerid][Skin],PlayerInfo[playerid][Pos][0],PlayerInfo[playerid][Pos][1],PlayerInfo[playerid][Pos][2],PlayerInfo[playerid][Pos][3],0,0,0,0,0,0);
		else SetSpawnInfo(playerid,-1,299,0.0,0.0,0.0,0.0,0,0,0,0,0,0);
		SpawnPlayer(playerid);
	}
	return 1;
}
hook OnPlayerSpawn(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
	    if(!PlayerLogged[playerid])
	    {
	    	TogglePlayerSpectating(playerid,1);
	    	LoadPlayer(playerid);
	    }
	}
	return 1;
}
hook OnPlayerDeath(playerid,killerid,reason)
{
	SendDeathMessage(killerid,playerid,reason);
	PlayerInfo[playerid][Deaths]++;
	if(killerid != INVALID_PLAYER_ID)
	{
		PlayerInfo[killerid][Kills]++;
	}
	return 1;
}
hook OnPlayerUpdate(playerid)
{
	if(GodMode[playerid]) SetPlayerHealth(playerid,9999.0);
	return 1;
}
hook OnPlayerKeyStateChange(playerid,newkeys,oldkeys)
{
	if(JumpMode[playerid])
	{
		static Float:velo[3];
		if(Released(KEY_JUMP))
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
			{
				GetPlayerVelocity(playerid,velo[0],velo[1],velo[2]);
				SetPlayerVelocity(playerid,velo[0],velo[1],velo[2]+1.0);
			}
		}
		else if(Pressed(KEY_CROUCH))
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
				static vehid;
				vehid = GetPlayerVehicleID(playerid);
				GetVehicleVelocity(vehid,velo[0],velo[1],velo[2]);
				SetVehicleVelocity(vehid,velo[0],velo[1],velo[2]+0.25);
			}
		}
	}
	return 1;
}
