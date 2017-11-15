CMD:veh(playerid,params[])
{
	static vehiclelist[4092];
	if(IsNull(vehiclelist))
	{
		strcat(vehiclelist,"Model\tName\tType",sizeof(vehiclelist));
		forex(i,sizeof(VehInfo))
		{
			format(vehiclelist,sizeof(vehiclelist),"%s\n%d\t%s\t%s",vehiclelist,VehInfo[i][Model],VehInfo[i][Name],VehInfo[i][Type]);
		}
	}
	Dialog_Show(playerid,PlayerVehicle_Create,DIALOG_STYLE_TABLIST_HEADERS,"Create Vehicle",vehiclelist,"Create","Close");
	return 1;
}
CMD:vehgodmode(playerid,params[])
{
	new vehid = GetPlayerVehicleID(playerid);
	if(vehid != 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		RepairVehicle(vehid);
		VehicleGodMode[vehid] = !(VehicleGodMode[vehid]);
		if(VehicleGodMode[vehid])
		{
			SetVehicleHealth(vehid,99999.0);
			SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Vehicle god-mode "GREEN"enabled");
		}
		else
		{
			SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Vehicle god-mode "RED"disabled");
		}
	}
	else SEM(playerid,"ERROR: You need to be a driver of a vehicle to use this command!");
	return 1;
}
CMD:fix(playerid,params[])
{
	new vehid = GetPlayerVehicleID(playerid);
	if(vehid != 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		RepairVehicle(vehid);
		if(VehicleGodMode[vehid]) SetVehicleHealth(vehid,99999.0);
		SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Vehicle repaired");
		PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
	}
	else SEM(playerid,"ERROR: You need to be a driver of a vehicle to use this command!");
	return 1;
}
CMD:mv(playerid,params[])
{
	if(Iter_Count(PlayerVehicles<playerid>) != 0)
	{
		new string[256],Float:cPos[3],model;
		strcat(string,"Vehicle\tDistance");
		foreach(new v : PlayerVehicles<playerid>)
		{
			model = GetVehicleModel(v);
			GetVehiclePos(v,cPos[0],cPos[1],cPos[2]);
			format(string,sizeof(string),"%s\n%s\t%.1f",string,VehInfo[(model-400)][Name],GetPlayerDistanceFromPoint(playerid,cPos[0],cPos[1],cPos[2]));
		}
		Dialog_Show(playerid,PlayerVehicle_List,DIALOG_STYLE_TABLIST_HEADERS,"Spawned Vehicles",string,"Select","Close");
	}
	else SEM(playerid,"ERROR: You do not have any vehicles!, create one using command '/veh'!");
	return 1;
}
CMD:vcolor(playerid,params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new color = strval(params);
		if(IsNull(params) || (color < 0 || color > 255)) return SEM(playerid,"USAGE: /vcolor [color (0 - 255)]");
		ChangeVehicleColor(GetPlayerVehicleID(playerid),color,color);
		PlayerPlaySound(playerid,1134,0.0,0.0,0.0);
	}
	return 1;
}
CMD:boostmode(playerid,params[])
{
	BoostMode[playerid] = !(BoostMode[playerid]);
	if(BoostMode[playerid])
	{
		SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Boost mode "GREEN"enabled");
		SendClientMessage(playerid,X11_LIGHTBLUE,"HINT: "WHITE"Hold "YELLOW"~k~~VEHICLE_FIREWEAPON~ "WHITE"to boost vehicle!");
	}
	else SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Boost mode "RED"disabled");
	return 1;
}
CMD:flip(playerid,params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new Float:angle,
			vehid = GetPlayerVehicleID(playerid);
		GetVehicleZAngle(vehid,angle);
		SetVehicleZAngle(vehid,angle);
	}
	return 1;
}
CMD:lock(playerid,params[])
{
	new vehid = GetPlayerVehicleID(playerid);
	if(vehid != 0)
	{
		if(Iter_Contains(PlayerVehicles<playerid>,vehid))
		{
			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehid, engine, lights, alarm, ((doors == 1) ? (0) : (1)), bonnet, boot, objective);
			if(doors == 1) SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Vehicle "GREEN"unlocked");
			else SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Vehicle "RED"locked");
		}
		else SEM(playerid,"ERROR: Can only lock your own vehicles!");
	}
	return 1;
}
CMD:tow(playerid,params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehid = GetPlayerVehicleID(playerid);
		if(IsTrailerAttachedToVehicle(vehid))
		{
			DetachTrailerFromVehicle(vehid);
			SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Trailer "RED"detached");
		}
		else
		{
			new Float:cPos[3],
				target = INVALID_VEHICLE_ID;
			foreach(new v : PlayerVehicles<playerid>)
			{
				if(v == vehid) continue;
				GetVehiclePos(v,cPos[0],cPos[1],cPos[2]);
				if(IsPlayerInRangeOfPoint(playerid,10.0,cPos[0],cPos[1],cPos[2]))
				{
					target = v;
					break;
				}
			}
			if(target != INVALID_VEHICLE_ID)
			{
				AttachTrailerToVehicle(target,vehid);
				SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Trailer "GREEN"attached");
			}
			else SEM(playerid,"ERROR: No nearby vehicle found!");
		}
	}
	return 1;
}
