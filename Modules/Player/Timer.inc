ptask PlayerTimer[1000](playerid)
{
	if(PlayerLogged[playerid])
	{
		PlayerInfo[playerid][Playtime]++;
		ChatFlood[playerid] = 0;
	}
}
timer EnableChat[5000](playerid)
{
	ChatFlood[playerid] = 0;
}
