Dialog:PlayerVehicle_Create(playerid,response,listitem,inputtext[])
{
	if(response)
	{
		if(CreatePlayerVehicle(playerid,VehInfo[listitem][Model])) SendClientMessage(playerid,X11_LIGHTBLUE,"VEHICLE: "WHITE"Vehicle created!");
		else SEM(playerid,"ERROR: Failed to create vehicle, an unexpected error has occurred!");
	}
	return 1;
}
Dialog:PlayerVehicle_List(playerid,response,listitem,inputtext[])
{
	if(response)
	{
		new idx = 0;
		foreach(new v : PlayerVehicles<playerid>)
		{
			if(idx == listitem)
			{
				SelectedVehicle[playerid] = v;
				Dialog_Show(playerid,PlayerVehicle_Option,DIALOG_STYLE_LIST,"Vehicle Option","Teleport To\nTeleport Here\nDelete","Select","Close");
				break;
			}
			idx++;
		}
	}
	return 1;
}
Dialog:PlayerVehicle_Option(playerid,response,listitem,inputtext[])
{
	if(response)
	{
		new vehid = SelectedVehicle[playerid];
		switch(listitem)
		{
			case 0:
			{
				SetVehicleVirtualWorld(vehid,GetPlayerVirtualWorld(playerid));
				PutPlayerInVehicle(playerid,vehid,0);
			}
			case 1:
			{
				new Float:cPos[4];
				GetPlayerPos(playerid,cPos[0],cPos[1],cPos[2]);
				GetPlayerFacingAngle(playerid,cPos[3]);
				SetVehiclePos(vehid,cPos[0],cPos[1],cPos[2]);
				SetVehicleVirtualWorld(vehid,GetPlayerVirtualWorld(playerid));
				LinkVehicleToInterior(vehid,GetPlayerInterior(playerid));
				PutPlayerInVehicle(playerid,vehid,0);
				SetVehicleZAngle(vehid,cPos[3]);
			}
			case 2: DeletePlayerVehicle(vehid);
		}
	}
	return 1;
}
