#include <YSI\y_hooks>

hook OnVehicleSpawn(vehicleid)
{
	if(VehicleGodMode[vehicleid]) SetVehicleHealth(vehicleid,99999.0);
	return 1;
}
hook OnPlayerUpdate(playerid)
{
	static Float:speed,vehid,newkeys,updown,leftright;
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		vehid = GetPlayerVehicleID(playerid);
		if(BoostMode[playerid])
		{
			GetPlayerKeys(playerid,newkeys,updown,leftright);
			if(Holding(KEY_FIRE))
			{
				speed = GetVehicleSpeed(vehid);
				SetVehicleSpeed(vehid,(speed+5.0));
			}
		}
		if(VehicleGodMode[vehid])
		{
			UpdateVehicleDamageStatus(vehid,0,0,0,0);
			SetVehicleHealth(vehid,99999.0);
		}
	}
	return 1;
}
hook OnPlayerDisconnect(playerid, reason)
{
	BoostMode[playerid] = false;
	DeletePlayerVehicles(playerid);
	return 1;
}
