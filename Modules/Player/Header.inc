enum E_PLAYER_DATA
{
	ORM:ORM_ID,
	ID,
	Name[32],
	Password[130],
	RegisterDate,
	LastLoginDate,
	Playtime,
	Skin,
	Float:Pos[4],
	Kills,
	Deaths
}
new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];
new RaceCheck[MAX_PLAYERS];
new bool:PlayerLogged[MAX_PLAYERS] = { false , ... };
new bool:GodMode[MAX_PLAYERS] = { false , ... };
new bool:JumpMode[MAX_PLAYERS] = { false , ... };
new bool:NoTele[MAX_PLAYERS] = { false , ... };
