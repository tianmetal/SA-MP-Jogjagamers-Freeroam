function Player_LoadData(playerid,check)
{
	if(check == RaceCheck[playerid])
	{
		new rows;
		cache_get_row_count(rows);
		if(rows == 1)
		{
			new ORM:ormid = CreatePlayerORM(playerid);
			orm_setkey(ormid,"id");
			orm_apply_cache(ormid,0);
			ShowLoginDialog(playerid);
		}
		else ShowRegisterDialog(playerid);
	}
	// if(check == RaceCheck[playerid])
	// {
	// 	new E_ORM_ERROR:errno = orm_errno(PlayerInfo[playerid][ORM_ID]);
	// 	if(errno == ERROR_OK)
	// 	{
	// 		orm_setkey(PlayerInfo[playerid][ORM_ID],"id");
	// 		ShowLoginDialog(playerid);
	// 	}
	// 	else if(errno == ERROR_NO_DATA)
	// 	{
	// 		orm_destroy(PlayerInfo[playerid][ORM_ID]);
	// 		ShowRegisterDialog(playerid);
	// 	}
	// 	else
	// 	{
	// 		orm_destroy(PlayerInfo[playerid][ORM_ID]);
	// 		SEM(playerid,"ERROR: An unexpected error has occurred, please try again later!");
	// 		Kick(playerid);
	// 	}
	// }
	// else
	// {
	// 	orm_destroy(PlayerInfo[playerid][ORM_ID]);
	// }
	return 1;
}
function Player_Register(playerid,check)
{
	if(check == RaceCheck[playerid])
	{
		if(orm_errno(PlayerInfo[playerid][ORM_ID]) == ERROR_OK)
		{
			SetSpawnInfo(playerid,-1,PlayerInfo[playerid][Skin],PlayerInfo[playerid][Pos][0],PlayerInfo[playerid][Pos][1],PlayerInfo[playerid][Pos][2],PlayerInfo[playerid][Pos][3],0,0,0,0,0,0);
			TogglePlayerSpectating(playerid,0);
			PlayerLogged[playerid] = true;
		}
		else
		{
			orm_destroy(PlayerInfo[playerid][ORM_ID]);
			SEM(playerid,"ERROR: An unexpected error has occurred, please try again later!");
			Kick(playerid);
		}
	}
	else
	{
		orm_destroy(PlayerInfo[playerid][ORM_ID]);
	}
	return 1;
}
