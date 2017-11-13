ptask PlayerTimer[1000](playerid)
{
	if(PlayerLogged[playerid])
	{
		PlayerInfo[playerid][Playtime]++;
		ChatFlood[playerid] = 0;
	}
}
