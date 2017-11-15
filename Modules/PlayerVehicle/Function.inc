stock CreatePlayerVehicle(playerid,model)
{
	if(model > 611 || model < 400) return 0;
	if(Iter_Count(PlayerVehicles<playerid>) >= MAX_VEHICLES_PER_PLAYER)
	{
		new rv = Iter_Random(PlayerVehicles<playerid>);
		DeletePlayerVehicle(rv);
	}
	new Float:cPos[4],vehid;
	GetPlayerPos(playerid,cPos[0],cPos[1],cPos[2]);
	GetPlayerFacingAngle(playerid,cPos[3]);
	vehid = CreateVehicle(model,cPos[0],cPos[1],cPos[2],cPos[3],random(255),random(255),-1);
	LinkVehicleToInterior(vehid,GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(vehid,GetPlayerVirtualWorld(playerid));
	Iter_Add(PlayerVehicles<playerid>,vehid);
	VehicleOwner[vehid] = playerid;
	PutPlayerInVehicle(playerid,vehid,0);
	return 1;
}
stock DeletePlayerVehicle(vehicleid)
{
	new owner = VehicleOwner[vehicleid];
	if(Iter_Contains(PlayerVehicles<owner>,vehicleid))
	{
		DestroyVehicle(vehicleid);
		Iter_Remove(PlayerVehicles<owner>,vehicleid);
		VehicleOwner[vehicleid] = INVALID_PLAYER_ID;
		VehicleGodMode[vehicleid] = false;
	}
	return 0;
}
stock DeletePlayerVehicles(playerid)
{
	if(Iter_Count(PlayerVehicles<playerid>) != 0)
	{
		foreach(new vehicleid : PlayerVehicles<playerid>)
		{
			DestroyVehicle(vehicleid);
			VehicleOwner[vehicleid] = INVALID_PLAYER_ID;
			VehicleGodMode[vehicleid] = false;
		}
		Iter_Clear(PlayerVehicles<playerid>);
		return 1;
	}
	return 0;
}
stock SetVehicleSpeed(vehicleid, Float:speed, bool:kmh = true)
{
	new Float:vPos[4];
	GetVehicleVelocity(vehicleid,vPos[0],vPos[1],vPos[2]);
    GetVehicleZAngle(vehicleid, vPos[3]);
    speed = (kmh ? (speed / 136.666667) : (speed / 85.4166672));
    return SetVehicleVelocity(vehicleid, speed * floatsin(-vPos[3], degrees), speed * floatcos(-vPos[3], degrees), (vPos[2]-0.005));
}

stock Float:GetVehicleSpeed(vehicleid, bool:kmh = true, Float:velx = 0.0, Float:vely = 0.0, Float:velz = 0.0)
{
	if(	velx == 0.0 &&
		vely == 0.0 &&
		velz == 0.0)
 	{
		GetVehicleVelocity(vehicleid, velx, vely, velz);
	}
	return float(floatround((floatsqroot(((velx * velx) + (vely * vely)) + (velz * velz)) * (kmh ? (136.666667) : (85.4166672))), floatround_round));
}
