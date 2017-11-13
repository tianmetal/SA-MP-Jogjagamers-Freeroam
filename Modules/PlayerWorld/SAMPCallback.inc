hook OnPlayerConnect(playerid)
{
	PlayerWorld[playerid] = 0;
	WorldInvite[playerid] = -1;
	return 1;
}
