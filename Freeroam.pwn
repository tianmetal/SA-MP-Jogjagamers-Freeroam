#pragma tabsize 4

// Includes

#include <a_samp>
#include <a_mysql>
#include <sscanf2>

#include <YSI\y_iterate>

#undef MAX_PLAYERS
#define MAX_PLAYERS (50)

#include <zcmd>

#if !defined Loop
#define Loop(%0,%1) \
        for(new %0 = 0; %0 != %1; %0++)
#endif

#if !defined function
#define function%0(%1) \
        forward%0(%1); public%0(%1)
#endif

#if !defined PURPLE
#define PURPLE \
    0xBF60FFFF
#endif

#if !defined GREEN
#define GREEN \
    0x94D317FF
#endif

#if !defined TIME
#define TIME \
    180000
#endif

native WP_Hash(buffer[], len, const str[]); // Whirlpool plugin

// Defines

#pragma tabsize 0

#define yellow 0xFFFF00AA

#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_BLUE 0x1229FAFF

#define COL_GREEN "{6EF83C}"
#define COL_RED "{F81414}"
#define COL_BLUE "{00C0FF}"

#define DIALOG_REGISTER (1)
#define DIALOG_LOGIN (2)

#define forex(%0,%1) for(new %0 = 0; %0 < %1; %0++)
#define IsNull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#define RGBAToInt(%0,%1,%2,%3) ((16777216 * (%0)) + (65536 * (%1)) + (256 * (%2)) + (%3))
#define strToLower(%0) \
    for(new i; %0[i] != EOS; ++i) \
        %0[i] = ('A' <= %0[i] <= 'Z') ? (%0[i] += 'a' - 'A') : (%0[i])
        
#define DIALOG_CARMENU_MAINMENU 18
#define DIALOG_CARMENU_BIKES 19
#define DIALOG_CARMENU_CARS_A 20
#define DIALOG_CARMENU_CARS_B 21
#define DIALOG_CARMENU_CARS_C 22
#define DIALOG_CARMENU_CARS_D 23
#define DIALOG_CARMENU_HELI 24
#define DIALOG_CARMENU_PLANE 25
#define DIALOG_CARMENU_BOAT 26
#define DIALOG_CARMENU_TRAILER 27
#define DIALOG_CARMENU_RC 28
#define Grey 0xC0C0C0FF

// Variables

new
    bool:PlayerLogged[MAX_PLAYERS],
    bool:GodMode[MAX_PLAYERS],
    bool:VehGodMode[MAX_PLAYERS],
    Database,
    Text:Website,
	Text:Promo,
	Hour,
	Minute,
	Second,
	serverTimer,
	nitroTimer
;

new Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS], Name[MAX_PLAYER_NAME], IsBeingSpeced[MAX_PLAYERS],spectatorid[MAX_PLAYERS];

new Text:Date;

new PlayerVeh[MAX_PLAYERS];

new Text3D:label[MAX_PLAYERS];

new DmMinigames[MAX_PLAYERS];

enum pinfo
{
	ID,
	Score,
	Money,
	Admin,
}
new PlayerInfo[MAX_PLAYERS][pinfo];

// Hooks

stock RefreshThings(playerid)
{
	if(PlayerInfo[playerid][Score] != GetPlayerScore(playerid))
	{
	    SetPlayerScore(playerid,PlayerInfo[playerid][Score]);
	}
	if(PlayerInfo[playerid][Money] != GetPlayerMoney(playerid))
	{
	    ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid,PlayerInfo[playerid][Money]);
	}
	return 1;
}
stock New_SetPlayerScore(playerid,score)
{
	PlayerInfo[playerid][Score] = score;
	return SetPlayerScore(playerid,score);
}
stock New_GivePlayerMoney(playerid,money)
{
	PlayerInfo[playerid][Money] += money;
	return GivePlayerMoney(playerid,money);
}
#define SetPlayerScore New_SetPlayerScore
#define GivePlayerMoney New_GivePlayerMoney

// Forwards

forward ServerTimer();
forward AntiSpawnKill(playerid);
forward NitroReset();

// Stock Functions

stock CreatePlayerVehicle(playerid, modelid, worldid)
{
	if(PlayerVeh[playerid] != 0)
	{
	    DestroyPlayerVehicle(playerid);
	}
	new Float:pPos[4];
	GetPlayerPos(playerid,pPos[0],pPos[1],pPos[2]);
	GetPlayerFacingAngle(playerid,pPos[3]);
	PlayerVeh[playerid] = CreateVehicle(modelid,pPos[0],pPos[1],pPos[2]+1.0,pPos[3],random(126),random(126),300000);
	SetVehicleVirtualWorld(PlayerVeh[playerid],worldid);
	PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	return 0;
}

stock DestroyPlayerVehicle(playerid)
{
	if(PlayerVeh[playerid] != 0)
	{
		DestroyVehicle(PlayerVeh[playerid]);
		PlayerVeh[playerid] = 0;
	}
	return 0;
}
function IsPlayerRegistered(playerid)
{
    new string[256],rows,fields;
    cache_get_data(rows,fields);
    if(rows == 1)
	{
	    cache_get_row(0,0,string,Database);
	    SetPVarInt(playerid,"TempID",strval(string));
		cache_get_row(0,1,string,Database);
		SetPVarString(playerid,"TempPass",string);
		GetPlayerName(playerid,string,24);
	    format(string,sizeof(string),"{FFFFFF}Welcome "COL_BLUE"%s(%d){FFFFFF} to the server, you're registered\n\nPlease log in by inputting your password.", string, playerid);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login to Server", string, "Login", "Leave");
	}
	else
	{
	    GetPlayerName(playerid,string,24);
	    format(string,sizeof(string),"{FFFFFF}Welcome "COL_BLUE"%s(%d){FFFFFF} to the server, you're "COL_RED"not{FFFFFF} registered\n\nPlease log in by inputting your password.", string, playerid);
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Register to server", string, "Register", "Leave");
	}
	GetPlayerName(playerid,string,24);
    format(string,64,"{FF0000}%s {FFFFFF}has joined the server.",string);
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
	SendClientMessageToAll(0xFFFFFFAA,string);
	return 1;
}
function RegisterPlayer(playerid)
{
	PlayerLogged[playerid] = true;
	PlayerInfo[playerid][ID] = cache_insert_id(Database);
	GivePlayerMoney(playerid,500);
	SetPlayerScore(playerid,0);
	SendClientMessage(playerid, -1, "You have "COL_GREEN"successfully{FFFFFF} registered! You have been automatically logged in!");
	return 1;
}
function LoginPlayer(playerid)
{
	new string[256],rows,fields;
    cache_get_data(rows,fields);
	if(rows == 1)
	{
		SetPlayerScore(playerid,cache_get_row_int(0,4,Database));
		GivePlayerMoney(playerid,cache_get_row_int(0,5,Database));
		PlayerInfo[playerid][Admin] = ,cache_get_row_int(0,6,Database);
		PlayerLogged[playerid] = true;
		SendClientMessage(playerid, -1, "You have "COL_GREEN"successfully{FFFFFF} logged in! ");
	}
	else Kick(playerid);
	return 1;
}
function SavePlayerData(playerid)
{
	if(PlayerLogged[playerid])
	{
	    new Query[256],ip[24];
		GetPlayerIp(playerid,ip,sizeof(ip));
		format(Query,sizeof(Query),"UPDATE `USERS` SET `IP`='%s',`SCORE`='%d',`CASH`='%d',`ADMINLEVEL`='%d' WHERE `ID`='%d'",
		ip,PlayerInfo[playerid][Score],PlayerInfo[playerid][Money],PlayerInfo[playerid][Admin],PlayerInfo[playerid][ID]);
		mysql_function_query(Database,Query,false,"OnPlayerSaveData","d",playerid);
    }
    return 1;
}
function OnPlayerSaveData(playerid)
{
	PlayerInfo[playerid][ID] = -1;
	PlayerInfo[playerid][Score] = 0;
	PlayerInfo[playerid][Money] = 500;
	PlayerInfo[playerid][Admin] = 0;
    PlayerLogged[playerid] = false;
    return 1;
}
stock GetWeaponIDFromName(string[])
{
    if (!strcmp(string, "Unarmed",true)) return 0;
	else if (!strcmp(string, "Brass Knuckles",true)) return 1;
	else if (!strcmp(string, "Golf Club",true)) return 2;
	else if (!strcmp(string, "Night Stick",true)) return 3;
	else if (!strcmp(string, "Knife",true)) return 4;
	else if (!strcmp(string, "Baseball Bat",true)) return 5;
	else if (!strcmp(string, "Shovel",true)) return 6;
	else if (!strcmp(string, "Pool cue",true)) return 7;
	else if (!strcmp(string, "Katana",true)) return 8;
	else if (!strcmp(string, "Chainsaw",true)) return 9;
	else if (!strcmp(string, "Purple Dildo",true)) return 10;
	else if (!strcmp(string, "White Dildo",true)) return 11;
	else if (!strcmp(string, "Long White Dildo",true)) return 12;
	else if (!strcmp(string, "White Dildo 2",true)) return 13;
	else if (!strcmp(string, "Flowers",true)) return 14;
	else if (!strcmp(string, "Cane",true)) return 15;
	else if (!strcmp(string, "Grenades",true)) return 16;
	else if (!strcmp(string, "Tear Gas",true)) return 17;
	else if (!strcmp(string, "Molotovs",true)) return 18;
	else if (!strcmp(string, "Pistol",true)) return 22;
	else if (!strcmp(string, "Silenced Pistol",true)) return 23;
	else if (!strcmp(string, "Desert Eagle",true)) return 24;
	else if (!strcmp(string, "Shotgun",true)) return 25;
	else if (!strcmp(string, "Sawn Off Shotgun",true)) return 26;
	else if (!strcmp(string, "Combat Shotgun",true)) return 27;
	else if (!strcmp(string, "Micro Uzi",true)) return 28;
	else if (!strcmp(string, "Mac 10",true)) return 28;
	else if (!strcmp(string, "MP5",true)) return 29;
	else if (!strcmp(string, "AK47",true)) return 30;
	else if (!strcmp(string, "M4",true)) return 31;
	else if (!strcmp(string, "Tec9",true)) return 32;
	else if (!strcmp(string, "Rifle",true)) return 33;
	else if (!strcmp(string, "Sniper Rifle",true)) return 34;
	else if (!strcmp(string, "Sachel Charges",true)) return 39;
	else if (!strcmp(string, "Detonator",true)) return 40;
	else if (!strcmp(string, "Spray Paint",true)) return 41;
	else if (!strcmp(string, "Fire Extinguisher",true)) return 42;
	else if (!strcmp(string, "Camera",true)) return 43;
	else if (!strcmp(string, "Nightvision Goggles",true)) return 44;
	else if (!strcmp(string, "Thermal Goggles",true)) return 45;
	else if (!strcmp(string, "Parachute",true)) return 46;
	return -1;
}

// Default SA:MP Callbacks

main() { } // Don't ever use this shit!

public OnGameModeInit()
{
    new curtick = GetTickCount();
    print("\n--------------------------------------");
	print(" Freeroam Script by Faldi");
	print("--------------------------------------\n");
	
	SetGameModeText("JG:Freeroam");
	
	// Classes
	
	forex(i,300)
	{
	    AddPlayerClass(i,1958.3783,1343.1572,15.3746,269.1425,0,0,0,0,0,0);
	}
	
	// Database loading
	
    Database = mysql_connect("localhost","gta4","gta_freeroam","");
    if(Database)
    {
        print("[error] Failed to connect to database!");
        GameModeExit();
    }
    
	// Timers
	
	serverTimer = SetTimer("ServerTimer",1000,1);
	nitroTimer = SetTimer("NitroReset", 3000, 1);
	
	// Textdraws
	
	Promo = TextDrawCreate(509.000000,2.000000,"We are powered by~n~Citra~y~.~r~net");
	TextDrawUseBox(Promo,1);
	TextDrawBoxColor(Promo,0x0000ff33);
	TextDrawTextSize(Promo,621.000000,0.000000);
	TextDrawAlignment(Promo,0);
	TextDrawBackgroundColor(Promo,0x0000ff33);
	TextDrawFont(Promo,3);
	TextDrawLetterSize(Promo,0.299999,1.200000);
	TextDrawColor(Promo,0xffffffcc);
	TextDrawSetOutline(Promo,1);
	TextDrawSetProportional(Promo,1);
	TextDrawSetShadow(Promo,1);

	Website = TextDrawCreate(454.000000,400.000000,"forum: ''~y~jogjagamers.com/forum~w~''~n~~w~JG-RP: ''~y~202.65.113.140:7777~w~''~n~~w~JG-FR: ''~y~202.65.113.140:7779~w~''");
	TextDrawAlignment(Website,0);
	TextDrawBackgroundColor(Website,0x000000ff);
	TextDrawFont(Website,3);
	TextDrawLetterSize(Website,0.299999,1.000000);
	TextDrawColor(Website,0xffffffff);
	TextDrawSetOutline(Website,1);
	TextDrawSetProportional(Website,1);
	TextDrawSetShadow(Website,1);
	
	Date = TextDrawCreate(78, 465, " ");
	TextDrawFont(Date , 3);
	TextDrawLetterSize(Date , 0.5, 3.5);
	TextDrawColor(Date , 0xFFFFFFFF);
	TextDrawSetOutline(Date , 0);
	TextDrawSetProportional(Date , 1);
	TextDrawSetShadow(Date , 1);
	
	// Finishing
	
	printf("Server needs %d milisecond to load the gamemode!",(GetTickCount()-curtick));
    UsePlayerPedAnims();
	return 1;
}

public NitroReset()
{
	foreach(new i : Player)
	{
	    if(!IsPlayerInInvalidNosVehicle(i,GetPlayerVehicleID(i)))
		{
    		    new vehicle = GetPlayerVehicleID(i);
  				AddVehicleComponent(vehicle, 1010);
		}
	}
	return 1;
}

IsPlayerInInvalidNosVehicle(playerid,vehicleid)
{
    #define MAX_INVALID_NOS_VEHICLES 29

    new InvalidNosVehicles[MAX_INVALID_NOS_VEHICLES] =
    {
	581,523,462,521,463,522,461,448,468,586,
	509,481,510,472,473,493,595,484,430,453,
	452,446,454,590,569,537,538,570,449
    };

    vehicleid = GetPlayerVehicleID(playerid);

    if(IsPlayerInVehicle(playerid,vehicleid))
    {
		for(new i = 0; i < MAX_INVALID_NOS_VEHICLES; i++)
		{
		    if(GetVehicleModel(vehicleid) == InvalidNosVehicles[i])
		    {
		        return true;
		    }
		}
    }
    return false;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)//This is called when a player's interior is changed.
{
    if(IsBeingSpeced[playerid] == 1)//If the player being spectated, changes an interior, then update the interior and virtualword for the spectator.
    {
        foreach(new i : Player)
        {
            if(spectatorid[i] == playerid)
            {
                SetPlayerInterior(i,GetPlayerInterior(playerid));
                SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(playerid));
            }
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)// If the player's state changes to a vehicle state we'll have to spec the vehicle.
    {
        if(IsBeingSpeced[playerid] == 1)//If the player being spectated, enters a vehicle, then let the spectator spectate the vehicle.
        {
            foreach(new i : Player)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));// Letting the spectator, spectate the vehicle of the player being spectated (I hope you understand this xD)
                }
            }
        }
    }
    if(newstate == PLAYER_STATE_ONFOOT)
    {
        if(IsBeingSpeced[playerid] == 1)//If the player being spectated, exists a vehicle, then let the spectator spectate the player.
        {
            foreach(new i : Player)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectatePlayer(i, playerid);// Letting the spectator, spectate the player who exited the vehicle.
                }
            }
        }
    }
    return 1;
}

public OnPlayerText(playerid, text[])
{
 	return 1;
}

public ServerTimer()
{
	gettime(Hour,Minute,Second);
	forex(playerid,MAX_PLAYERS)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        SetPlayerScore(playerid,GetPlayerMoney(playerid));
	    }
	}
	return 1;
}

public AntiSpawnKill(playerid) // You can add this anywhere
{
    SetPlayerHealth(playerid,100.0);
    SendClientMessage(playerid, 0xFF0000AA, "[INFO] Spawn Protection has ended"); // Will send player message when Anti spawn kill protection is ended.
        return 1;
}

public OnGameModeExit()
{
    forex(playerid,MAX_PLAYERS)
	{
		SavePlayerData(playerid);
	}
	KillTimer(serverTimer);
	KillTimer(nitroTimer);
	mysql_close(Database);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1951.5610, 1342.9926, 16.9496);
	SetPlayerCameraLookAt(playerid, 1952.5590, 1343.0342, 16.8146);
	return 1;
}

public OnPlayerConnect(playerid)
{
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
    SendClientMessage(playerid, 0xAA3333AA, " ");
	SendClientMessage(playerid, 0xAA3333AA, "Welcome to the Jogjagamers Freeroam");
	new string[128],name[24];
	GetPlayerName(playerid,name,24);
	strToLower(name);
	format(string,sizeof(string),"SELECT `ID`,`PASSWORD` FROM `USERS` WHERE `NAME`='%s'",name);
	mysql_function_query(Database,string,true,"IsPlayerRegistered","d",playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
	TextDrawShowForPlayer(playerid,Promo);
	TextDrawShowForPlayer(playerid,Website);
	new Year, Month, Day;
	getdate(Year, Month, Day);
	new date[64];
	format(date,sizeof(date),"%02d/%02d/%d",Year, Month, Day);
	TextDrawSetString(Date, date);
	TextDrawShowForAll(Date);
	TogglePlayerClock(playerid,1);
    SetPlayerColor(playerid,RGBAToInt(random(256),random(256),random(256),255));
    SendClientMessage(playerid, 0xFFFFFFAA, "[INFO] You are Anti Spawn Kill protected for 20 seconds!");
    SetPlayerHealth(playerid, 9999);
    SetTimerEx("AntiSpawnKill", 20000, 0, "i", playerid); // When player is spawned then he'll have the Anti Spawn Kill protection
   if(IsSpecing[playerid] == 1)
    {
        SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// Remember earlier we stored the positions in these variables, now we're gonna get them from the variables.
        SetPlayerInterior(playerid,Inter[playerid]);//Setting the player's interior to when they typed '/spec'
        SetPlayerVirtualWorld(playerid,vWorld[playerid]);//Setting the player's virtual world to when they typed '/spec'
        IsSpecing[playerid] = 0;//Just saying you're free to use '/spec' again YAY :D
        IsBeingSpeced[spectatorid[playerid]] = 0;//Just saying that the player who was being spectated, is not free from your stalking >:D
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SavePlayerData(playerid);
    GodMode[playerid] = false;
    VehGodMode[playerid] = false;
    DmMinigames[playerid] = 0;
    DestroyPlayerVehicle(playerid);
    if(IsBeingSpeced[playerid] == 1)
    {
        foreach(new i : Player)
        {
            if(spectatorid[i] == playerid)
            {
                TogglePlayerSpectating(i,false);
            }
        }
    }
    new pname[MAX_PLAYER_NAME], string[39 + MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    switch(reason)
    {
        case 0: format(string, sizeof(string), "{FF0000}%s {FFFFFF}has left the server. (Lost Connection)", pname);
        case 1: format(string, sizeof(string), "{FF0000}%s {FFFFFF}has left the server. (Leaving)", pname);
        case 2: format(string, sizeof(string), "{FF0000}%s {FFFFFF}has left the server. (Kicked)", pname);
    }
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
    SendClientMessageToAll(0xAAAAAAAA, string);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
 	SendDeathMessage(killerid, playerid, reason);
    if(killerid != INVALID_PLAYER_ID)
    {
        GivePlayerMoney(killerid, 10000);
    }
    DmMinigames[playerid] = 0;
    if(IsBeingSpeced[playerid] == 1)//If the player being spectated, dies, then turn off the spec mode for the spectator.
    {
        foreach(new i : Player)
        {
            if(spectatorid[i] == playerid)
            {
                TogglePlayerSpectating(i,false);// This justifies what's above, if it's not off then you'll be either spectating your connect screen, or somewhere in blueberry (I don't know why)
            }
        }
    }
    return 1;
}

public OnPlayerUpdate(playerid)
{
	if(GodMode[playerid]) SetPlayerHealth(playerid,999999);
	RefreshThings(playerid);
	SetPlayerTime(playerid,Hour,Minute);
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid,playerid)
{
	if(VehGodMode[playerid]) RepairVehicle(vehicleid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_REGISTER:
		{
			if(response)
		    {
		        new string[384],name[24];
		        GetPlayerName(playerid,name,24);
				if(!IsNull(inputtext) && (24 >= strlen(inputtext) >= 3))
				{
					new newpassword[129],ip[20];
					GetPlayerIp(playerid,ip,20);
					WP_Hash(newpassword,129,inputtext);
					strToLower(name);
					format(string,sizeof(string),"INSERT INTO `USERS`(`NAME`,`PASSWORD`,`IP`) VALUES('%s','%s','%s')",name,newpassword,ip);
					mysql_function_query(Database,string,false,"RegisterPlayer","d",playerid);
				}
				else
				{
		            format(string,sizeof(string),"{FFFFFF}Welcome "COL_BLUE"%s(%d){FFFFFF} to the server, you're "COL_RED"not{FFFFFF} registered\n\nPlease log in by inputting your password.",name,playerid);
					ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_INPUT, "{FFFFFF}Register System",string,"Register","Leave");
					SendClientMessage(playerid,-1,"Your password length must be from 3 - 24 characters!");
				}
		    }
		    else return Kick(playerid);
		}
		case DIALOG_LOGIN:
		{
		    if(response)
		    {
		        new string[256],name[24];
		        GetPlayerName(playerid,name,sizeof(name));
		        if(IsNull(inputtext))
				{
		            format(string,sizeof(string),"{FFFFFF}Welcome "COL_BLUE"%s(%d){FFFFFF} to the server, you're registered\n\nPlease log in by inputting your password.",name,playerid);
					ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_INPUT, "{FFFFFF}Register System",string, "Login", "Leave");
					SendClientMessage(playerid, -1, ""COL_RED"Wrong{FFFFFF} password, try again!");
				}
				else
				{
					new pass[130];
					GetPVarString(playerid,"TempPass",pass,130);
					WP_Hash(string,129,inputtext);
					if(!strcmp(string,pass))
					{
					    DeletePVar(playerid,"TempPass");
					    PlayerInfo[playerid][ID] = GetPVarInt(playerid,"TempID");
					    DeletePVar(playerid,"TempID");
					    strToLower(name);
					    format(string,sizeof(string),"SELECT * FROM `USERS` WHERE `ID`='%d'",PlayerInfo[playerid][ID]);
					    mysql_function_query(Database,string,true,"LoginPlayer","d",playerid);
					}
				}
		    }
		    else return Kick(playerid);
	    }
		case DIALOG_CARMENU_MAINMENU:
       	{
            if(response) {
                if(listitem == 0) {               // Bikes
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+1, DIALOG_STYLE_LIST, "Bikes", "BF-400\nBike\nBMX\nHPV1000\nFaggio\nFCR-900\nFreeway\nMountain Bike\nNRG-500\nPCJ-600\nPizzaboy\nSanchez\nWayfarer\nQuad\nBack", "Select", "Cancel");
                }
                if(listitem == 1) {               // Cars [A-E]
                    new cMenuString[408];
                    cMenuString = " ";
                    strcat(cMenuString, "Admiral\nAlpha\nAmbulance\nBaggage\nBandito\nBanshee\nBarracks\nBenson\nBerkley's RC Van\nBF Injection\nBlade\nBlista Compact\nBloodring Banger\nBobcat\nBoxville 1\nBoxville 2\nBravura\nBroadway\nBuccaneer\nBuffalo\nBullet\nBurrito\nBus\nCabbie\n");
                    strcat(cMenuString, "Caddy\nCadrona\nCamper\nCement Truck\nCheetah\nClover\nClub\nCoach\nCombine Harvester\nComet\nDFT-30\nDozer\nDumper\nDune(ride)\nElegant\nElegy\nEmperor\nEsperanto\nEuros\nBack");
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+2, DIALOG_STYLE_LIST, "Cars 1 [A-E]", cMenuString, "Select", "Cancel");
                }
                if(listitem == 2) {               // Cars 2 [F-P]
                    new cMenuString[408];
                    cMenuString = " ";
                    strcat(cMenuString, "FBI Rancher\nFBI Truck\nFeltzer\nFiretruck 1\nFiretruck 2\nFlash\nFlatbed\nForklift\nFortune\nGlendale 1\nGlendale 2\nGreenwood\nHermes\nHotdog\nHotknife\nHotring Racer 1\nHotring Racer 2\nHotring Racer 3\nHuntley\nHustler\nInfernus\nIntruder\nJester\nJourney\nKart\nLandstalker\nLinerunner\nMajestic\nManana\nMerit\nMesa\nMonster\nMonster A\nMonster B\nMoonbeam\nMower\nMr Whoopee\nMule\nNebula\n");
                    strcat(cMenuString, "Newsvan\nOceanic\nPacker\nBack");
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+3, DIALOG_STYLE_LIST, "Cars 2 [F-P]", cMenuString, "Select", "Cancel");
                }
                if(listitem == 3) {               // Cars 3 [P-S]
                    new cMenuString[408];
                    cMenuString = " ";
                    strcat(cMenuString, "Patriot\nPerenniel\nPetrol Tanker\nPhoenix\nPicador\nPolice Car (LSPD)\nPolice Car (SFPD)\nPolice Car (LVPD)\nPolice Ranger\nPolice Truck (Enforcer)\nPolice Truck (SWAT)\nPony\nPremier\nPrevion\nPrimo\n");
                    strcat(cMenuString, "Rancher\nRegina\nRemington\nRhino\nRoadtrain\nRomero\nRumpo\nSabre\nSadler 1\nSadler 2\nSandking\nSavanna\nSecuricar\nSentinel\nSlamvan\nSolair\nStafford\nStallion\nStratum\nStretch\nSultan\nSunrise\nBack");
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+4, DIALOG_STYLE_LIST, "Cars 3 [F-P]", cMenuString, "Select", "Cancel");
                }
                if(listitem == 4) {               // Cars 4 [S-Z]
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+5, DIALOG_STYLE_LIST, "Cars 4 [S-Z]", "Super GT\nSweeper\nTahoma\nTampa\nTaxi\nTornado\nTowtruck\nTractor\nTrashmaster\nTug\nTurismo\nUranus\nUtility Van\nVincent\nVirgo\nVoodoo\nWalton\nWashington\nWilliard\nWindsor\nYankee\nYosemite\nZR-350\nBack", "Select", "Cancel");
                }
                if(listitem == 5) {               // Helicopters
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+6, DIALOG_STYLE_LIST, "Helicopters", "Cargobob\nHunter\nLeviathan\nMaverick\nPolice Maverick\nNews Chopper\nRaindance\nSparrow\nSea Sparrow\nBack", "Select", "Cancel");
                }
                if(listitem == 6) {               // Planes
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+7, DIALOG_STYLE_LIST, "Planes", "Andromada\nAT-400\nBeagle\nCropduster\nDodo\nHydra\nNevada\nRustler\nShamal\nSkimmer\nStuntplane\nBack", "Select", "Cancel");
                }
                if(listitem == 7) {               // Boats
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+8, DIALOG_STYLE_LIST, "Boats", "Coastguard\nDinghy\nJetmax\nLaunch\nMarquis\nPredator\nReefer\nSpeeder\nSquallo\nTropic\nBack", "Select", "Cancel");
                }
                if(listitem == 8) {               // Trailers
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+9, DIALOG_STYLE_LIST, "Trailers", "Article Trailer 1\nArticle Trailer 2\nArticle Trailer 3\nBaggage Trailer (A)\nBaggage Trailer (B)\nFarm Trailer\nPetrol Trailer\nTug Stairs Trailer\nUtility Trailer\nBack", "Select", "Cancel");
                }
                if(listitem == 9) {               // RC Vehicles + Vortex
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU+10, DIALOG_STYLE_LIST, "RC Vehicles + Vortex", "RC Bandit\nRC Cam\nRC Tiger\nRC Baron\nRC Goblin\nRC Raider\nVortex\nBack", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_BIKES:
        {
            if(response) {
                if(listitem == 0) {               // BF-400
                    CreatePlayerVehicle(playerid,581, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Bike
                    CreatePlayerVehicle(playerid,509, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               //  BMX
                    CreatePlayerVehicle(playerid,481, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               //  HPV1000
                    CreatePlayerVehicle(playerid,523, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               //  Faggio
                    CreatePlayerVehicle(playerid,462, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // FCR-900
                    CreatePlayerVehicle(playerid,521, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Freeway
                    CreatePlayerVehicle(playerid,463, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Mountain Bike
                    CreatePlayerVehicle(playerid,510, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // NRG-500
                    CreatePlayerVehicle(playerid,522, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // PCJ-600
                    CreatePlayerVehicle(playerid,461, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Pizzaboy
                    CreatePlayerVehicle(playerid,448, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 11) {              // Sanchez
                    CreatePlayerVehicle(playerid,468, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 12) {              // Wayfarer
                    CreatePlayerVehicle(playerid,586, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 13) {              // Quad
                    CreatePlayerVehicle(playerid,471, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 14) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }

            }
        }
        case DIALOG_CARMENU_CARS_A:
        {
            if(response) {
                if(listitem == 0) {               // Admiral
                    CreatePlayerVehicle(playerid,445, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Alpha
                    CreatePlayerVehicle(playerid,602, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Ambulance
                    CreatePlayerVehicle(playerid,416, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Baggage
                    CreatePlayerVehicle(playerid,485, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Bandito
                    CreatePlayerVehicle(playerid,568, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Banshee
                    CreatePlayerVehicle(playerid,429, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Barracks
                    CreatePlayerVehicle(playerid,433, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Benson
                    CreatePlayerVehicle(playerid,499, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Berkley's RC Van
                    CreatePlayerVehicle(playerid,459, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               //BF Injection
                    CreatePlayerVehicle(playerid,424, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Blade
                    CreatePlayerVehicle(playerid,536, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 11) {              // Blista Compact
                    CreatePlayerVehicle(playerid,496, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 12) {              // Bloodring Banger
                    CreatePlayerVehicle(playerid,504, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 13) {              // Bobcat
                    CreatePlayerVehicle(playerid,422, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 14) {              // Boxville 1
                    CreatePlayerVehicle(playerid,609, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 15) {              // Boxville 2
                    CreatePlayerVehicle(playerid,498, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 16) {              // Bravura
                    CreatePlayerVehicle(playerid,401, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 17) {              // Broadway
                    CreatePlayerVehicle(playerid,575, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 18) {              // Buccaneer
                    CreatePlayerVehicle(playerid,518, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 19) {              // Buffalo
                    CreatePlayerVehicle(playerid,402, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 20) {              // Bullet
                    CreatePlayerVehicle(playerid,541, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 21) {              // Burrito
                    CreatePlayerVehicle(playerid,482, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 22) {              // Bus
                    CreatePlayerVehicle(playerid,431, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 23) {              // Cabbie
                    CreatePlayerVehicle(playerid,438, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 24) {              // Caddy
                    CreatePlayerVehicle(playerid,457, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 25) {              // Cadrona
                    CreatePlayerVehicle(playerid,527, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 26) {              // Camper
                    CreatePlayerVehicle(playerid,483, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 27) {              // Cement Truck
                    CreatePlayerVehicle(playerid,524, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 28) {              // Cheetah
                    CreatePlayerVehicle(playerid,415, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 29) {              // Clover
                    CreatePlayerVehicle(playerid,542, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 30) {              // Club
                    CreatePlayerVehicle(playerid,589, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 31) {              // Coach
                    CreatePlayerVehicle(playerid,437, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 32) {              // Combine Harvester
                    CreatePlayerVehicle(playerid,532, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 33) {              // Comet
                    CreatePlayerVehicle(playerid,480, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 34) {              // DFT-30
                    CreatePlayerVehicle(playerid,578, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 35) {              // Dozer
                    CreatePlayerVehicle(playerid,486, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 36) {              // Dumper
                    CreatePlayerVehicle(playerid, 406, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 37) {              // Dune(ride)
                    CreatePlayerVehicle(playerid, 573, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 38) {              // Elegant
                    CreatePlayerVehicle(playerid,507, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 39) {              // Elegy
                    CreatePlayerVehicle(playerid,562, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 40) {              // Emperor
                    CreatePlayerVehicle(playerid,585, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 41) {              // Esperanto
                    CreatePlayerVehicle(playerid,419, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 42) {              // Euros
                    CreatePlayerVehicle(playerid,587, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 43) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_CARS_B:
        {
            if(response) {
                if(listitem == 0) {               // FBI Rancher
                    CreatePlayerVehicle(playerid,490, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // FBI Truck
                    CreatePlayerVehicle(playerid,528, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Feltzer
                    CreatePlayerVehicle(playerid,533, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Firetruck 1
                    CreatePlayerVehicle(playerid,544, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Firetruck 2
                    CreatePlayerVehicle(playerid,407, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Flash
                    CreatePlayerVehicle(playerid,565, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Flatbed
                    CreatePlayerVehicle(playerid,455, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Forklift
                    CreatePlayerVehicle(playerid,530, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Fortune
                    CreatePlayerVehicle(playerid,526, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Glendale 1
                    CreatePlayerVehicle(playerid,466, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Glendale 2
                    CreatePlayerVehicle(playerid,604, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 11) {              // Greenwood
                    CreatePlayerVehicle(playerid,492, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 12) {              // Hermes
                    CreatePlayerVehicle(playerid,474, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 13) {              // Hotdog
                    CreatePlayerVehicle(playerid,588, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 14) {              // Hotknife
                    CreatePlayerVehicle(playerid,434, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 15) {              // Hotring Racer 1
                    CreatePlayerVehicle(playerid,502, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 16) {              // Hotring Racer 2
                    CreatePlayerVehicle(playerid,503, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 17) {              // Hotring Racer 3
                    CreatePlayerVehicle(playerid,494, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 18) {              // Huntley
                    CreatePlayerVehicle(playerid,579, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 19) {              // Hustler
                    CreatePlayerVehicle(playerid,545, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 20) {              // Infernus
                    CreatePlayerVehicle(playerid,411, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 21) {              // Intruder
                    CreatePlayerVehicle(playerid,546, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 22) {              // Jester
                    CreatePlayerVehicle(playerid,559, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 23) {              // Journey
                    CreatePlayerVehicle(playerid,508, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 24) {              // Kart
                    CreatePlayerVehicle(playerid,571, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 25) {              // Landstalker
                    CreatePlayerVehicle(playerid,400, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 26) {              // Linerunner
                    CreatePlayerVehicle(playerid,403, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 27) {              // Majestic
                    CreatePlayerVehicle(playerid,517, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 28) {              // Manana
                    CreatePlayerVehicle(playerid,410, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 29) {              // Merit
                    CreatePlayerVehicle(playerid,551, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 30) {              // Mesa
                    CreatePlayerVehicle(playerid,500, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 31) {              // Monster
                    CreatePlayerVehicle(playerid, 444, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 32) {              // Monster A
                    CreatePlayerVehicle(playerid, 556, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 33) {              // Monster B
                    CreatePlayerVehicle(playerid, 557, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 34) {              // Moonbeam
                    CreatePlayerVehicle(playerid,418, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 35) {              // Mower
                    CreatePlayerVehicle(playerid,572, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 36) {              // Mr Whoopee
                    CreatePlayerVehicle(playerid, 423, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 37) {              // Mule
                    CreatePlayerVehicle(playerid, 414, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 38) {              // Nebula
                    CreatePlayerVehicle(playerid,516, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 39) {              // Newsvan
                    CreatePlayerVehicle(playerid,582, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 40) {              // Oceanic
                    CreatePlayerVehicle(playerid,467, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 41) {              // Packer
                    CreatePlayerVehicle(playerid,443, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 42) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_CARS_C:
        {
            if(response) {
                if(listitem == 0) {               // Patriot
                    CreatePlayerVehicle(playerid,470, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Perenniel
                    CreatePlayerVehicle(playerid,404, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Petrol Tanker
                    CreatePlayerVehicle(playerid,514, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Phoenix
                    CreatePlayerVehicle(playerid,603, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Picador
                    CreatePlayerVehicle(playerid,600, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Police Car LSPD
                    CreatePlayerVehicle(playerid,596, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Police Car SFPD
                    CreatePlayerVehicle(playerid,597, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Police Car LVPD
                    CreatePlayerVehicle(playerid,598, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Police Ranger
                    CreatePlayerVehicle(playerid,599, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Police Truck (Enforcer)
                    CreatePlayerVehicle(playerid,427, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Police Truck (SWAT)
                    CreatePlayerVehicle(playerid,601, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 11) {              // Pony
                    CreatePlayerVehicle(playerid,413, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 12) {              // Premier
                    CreatePlayerVehicle(playerid,426, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 13) {              // Previon
                    CreatePlayerVehicle(playerid,436, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 14) {              // Primo
                    CreatePlayerVehicle(playerid,547, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 15) {              // Rancher
                    CreatePlayerVehicle(playerid,489, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 16) {              // Regina
                    CreatePlayerVehicle(playerid,479, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 17) {              // Remington
                    CreatePlayerVehicle(playerid,534, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 18) {              // Rhino
                    CreatePlayerVehicle(playerid,432, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 19) {              // Roadtrain
                    CreatePlayerVehicle(playerid,515, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 20) {              // Romero
                    CreatePlayerVehicle(playerid,442, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 21) {              // Rumpo
                    CreatePlayerVehicle(playerid,440, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 22) {              // Sabre
                    CreatePlayerVehicle(playerid, 475, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 23) {              // Sadler 1
                    CreatePlayerVehicle(playerid,543, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 24) {              // Sadler 2
                    CreatePlayerVehicle(playerid,605, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 25) {              // Sandking
                    CreatePlayerVehicle(playerid,495, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 26) {              // Savanna
                    CreatePlayerVehicle(playerid,567, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 27) {              // Securicar
                    CreatePlayerVehicle(playerid,428, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 28) {              // Sentinel
                    CreatePlayerVehicle(playerid,405, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 29) {              // Slamvan
                    CreatePlayerVehicle(playerid,535, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 30) {              // Solair
                    CreatePlayerVehicle(playerid,458, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 31) {              // Stafford
                    CreatePlayerVehicle(playerid,580, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 32) {              // Stallion
                    CreatePlayerVehicle(playerid,439, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 33) {              // Stratum
                    CreatePlayerVehicle(playerid,561, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 34) {              // Stretch
                    CreatePlayerVehicle(playerid,409, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 35) {              // Sultan
                    CreatePlayerVehicle(playerid,560, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 36) {              // Sunrise
                    CreatePlayerVehicle(playerid,550, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 37) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_CARS_D:
        {
            if(response) {
                if(listitem == 0) {               // Super GT
                    CreatePlayerVehicle(playerid,506, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Sweeper
                    CreatePlayerVehicle(playerid,574, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Tahoma
                    CreatePlayerVehicle(playerid,566, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Tampa
                    CreatePlayerVehicle(playerid,549, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Taxi
                    CreatePlayerVehicle(playerid,420, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Tornado
                    CreatePlayerVehicle(playerid,576, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Towtruck
                    CreatePlayerVehicle(playerid,525, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Tractor
                    CreatePlayerVehicle(playerid,531, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Trashmaster
                    CreatePlayerVehicle(playerid,408, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Tug
                    CreatePlayerVehicle(playerid,583, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Turismo
                    CreatePlayerVehicle(playerid,451, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 11) {              // Uranus
                    CreatePlayerVehicle(playerid,558, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 12) {              // Utility Van
                    CreatePlayerVehicle(playerid,552, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 13) {              // Vincent
                    CreatePlayerVehicle(playerid,540, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 14) {              // Virgo
                    CreatePlayerVehicle(playerid,491, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 15) {              // Voodoo
                    CreatePlayerVehicle(playerid,412, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 16) {              // Walton
                    CreatePlayerVehicle(playerid,478, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 17) {              // Washington
                    CreatePlayerVehicle(playerid, 421, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 18) {              // Williard
                    CreatePlayerVehicle(playerid,529, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 19) {              // Windsor
                    CreatePlayerVehicle(playerid,555, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 20) {              // Yankee
                    CreatePlayerVehicle(playerid,456, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 21) {              // Yosemite
                    CreatePlayerVehicle(playerid,554, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 22) {              // ZR-350
                    CreatePlayerVehicle(playerid,477, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 23) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_HELI:
        {
            if(response) {
                if(listitem == 0) {               // Cargobob
                    CreatePlayerVehicle(playerid, 548, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Hunter
                    CreatePlayerVehicle(playerid,425, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Leviathan
                    CreatePlayerVehicle(playerid,417, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Maverick
                    CreatePlayerVehicle(playerid,487, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Police Maverick
                    CreatePlayerVehicle(playerid,497, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // News Chopper
                    CreatePlayerVehicle(playerid,488, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Raindance
                    CreatePlayerVehicle(playerid,563, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Sparrow
                    CreatePlayerVehicle(playerid,469, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Sea Sparrow
                    CreatePlayerVehicle(playerid,447, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_PLANE:
        {
            if(response) {
                if(listitem == 0) {               // Andromada
                    CreatePlayerVehicle(playerid,592, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // At-400
                    CreatePlayerVehicle(playerid,577, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Beagle
                    CreatePlayerVehicle(playerid,511, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Cropduster
                    CreatePlayerVehicle(playerid,512, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Dodo
                    CreatePlayerVehicle(playerid,593, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Hydra
                    CreatePlayerVehicle(playerid,520, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Nevada
                    CreatePlayerVehicle(playerid,553, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Rustler
                    CreatePlayerVehicle(playerid,476, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Shamal
                    CreatePlayerVehicle(playerid,519, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Skimmer
                    CreatePlayerVehicle(playerid,460, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Stuntplane
                    CreatePlayerVehicle(playerid,513, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 11) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_BOAT:
        {
            if(response) {
                if(listitem == 0) {               // Coastguard
                    CreatePlayerVehicle(playerid,472, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Dinghy
                    CreatePlayerVehicle(playerid,473, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Jetmax
                    CreatePlayerVehicle(playerid,493, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Launch
                    CreatePlayerVehicle(playerid,595, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Marquis
                    CreatePlayerVehicle(playerid,484, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Predator
                    CreatePlayerVehicle(playerid,430, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Reefer
                    CreatePlayerVehicle(playerid,453, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Speeder
                    CreatePlayerVehicle(playerid,452, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Squallo
                    CreatePlayerVehicle(playerid,446, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Tropic
                    CreatePlayerVehicle(playerid,454, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 10) {              // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_TRAILER:
        {
            if(response) {
                if(listitem == 0) {               // Article Trailer 1
                    CreatePlayerVehicle(playerid,435, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // Article Trailer 2
                    CreatePlayerVehicle(playerid,450, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // Article Trailer 3
                    CreatePlayerVehicle(playerid,591, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // Baggage Trailer (A)
                    CreatePlayerVehicle(playerid,606, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // Baggage Trailer (B)
                    CreatePlayerVehicle(playerid,607, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // Farm Trailer
                    CreatePlayerVehicle(playerid,610, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Petrol Trailer
                    CreatePlayerVehicle(playerid,584, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Tug Stairs Trailer
                    CreatePlayerVehicle(playerid,608, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 8) {               // Utility Trailer
                    CreatePlayerVehicle(playerid,611, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 9) {               // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
            }
        }
        case DIALOG_CARMENU_RC:
        {
            if(response) {
                if(listitem == 0) {               // RC Bandit
                    CreatePlayerVehicle(playerid,441, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 1) {               // RC Cam
                    CreatePlayerVehicle(playerid,594, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 2) {               // RC Tiger
                    CreatePlayerVehicle(playerid,564, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 3) {               // RC Baron
                    CreatePlayerVehicle(playerid,464, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 4) {               // RC Goblin
                    CreatePlayerVehicle(playerid,501, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 5) {               // RC Raider
                    CreatePlayerVehicle(playerid,465, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 6) {               // Vortex
                    CreatePlayerVehicle(playerid,539, GetPlayerVirtualWorld(playerid));
                }
                if(listitem == 7) {               // Back
                    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
                }
			}
        }
    }
    return 1;
}
// Commands

CMD:help(playerid,params[])
{
	SendClientMessage(playerid, 0xAA3333AA, "**HELP** /help /weap /veh /godmode /vehgodmode /skin /fix /playdm /leavedm /resetmyvw **");
	SendClientMessage(playerid, 0xAA3333AA, "**HELP** /afk /back /colorcar **");
	SendClientMessage(playerid, 0xAA3333AA, "**TELEPORT** /gotols /gotosf /gotolv /drift[1-2] /tune[1-3] /gotoplayer **");
	return 1;
}
CMD:gotols(playerid,params[])
{
    SetPlayerPos(playerid, 1529.6,-1691.2,13.3);
    SetVehiclePos(GetPlayerVehicleID(playerid), 1529.6,-1691.2,13.3);
    PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	SendClientMessage(playerid, 0xAA3333AA, "You have been teleported !");
	return 1;
}
CMD:gotosf(playerid,params[])
{
    SetPlayerPos(playerid, -2015.261108, 154.379516, 27.687500);
    SetVehiclePos(GetPlayerVehicleID(playerid), -2015.261108, 154.379516, 27.687500);
    PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	SendClientMessage(playerid, 0xAA3333AA, "You have been teleported !");
	return 1;
}
CMD:gotolv(playerid,params[])
{
    SetPlayerPos(playerid, 1699.2,1435.1, 10.7);
    SetVehiclePos(GetPlayerVehicleID(playerid), 1699.2,1435.1, 10.7);
    PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	SendClientMessage(playerid, 0xAA3333AA, "You have been teleported !");
	return 1;
}

CMD:drift1(playerid,params[])
{
    SetPlayerPos(playerid, -2423.1755,-608.8604,132.3824);
    SetVehiclePos(GetPlayerVehicleID(playerid), -2423.1755,-608.8604,132.3824);
    PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	SendClientMessage(playerid, 0xAA3333AA, "You have been teleported !");
	return 1;
}

CMD:drift2(playerid,params[])
{
    SetPlayerPos(playerid, -300.5935,1523.9900,75.1813);
    SetVehiclePos(GetPlayerVehicleID(playerid), -300.5935,1523.9900,75.1813);
    PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	SendClientMessage(playerid, 0xAA3333AA, "You have been teleported !");
	return 1;
}

CMD:gotoplayer( playerid, params[ ] )
{
   if( isnull( params ) ) return SendClientMessage(playerid, 0xAA3333AA, "/gotoplayer [playerid]"); // No player
   new targetid = strval( params );
   if( !IsPlayerConnected( targetid ) ) return 0; // Targeted player is not connected
   new Float: Pos[ 4 ];
   GetPlayerPos( targetid, Pos[ 0 ], Pos[ 1 ], Pos[ 2 ] );
   GetPlayerFacingAngle( targetid, Pos[ 3 ] );
   SetPlayerPos( playerid, Pos[ 0 ], Pos[ 1 ], Pos[ 2 ] );
   SetVehiclePos( GetPlayerVehicleID(playerid), Pos[ 0 ], Pos[ 1 ], Pos[ 2 ] );
   PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
   SetPlayerFacingAngle( playerid, Pos[ 3 ] );
   return 1;
}

CMD:kill(playerid,params[])
{
    SetPlayerHealth(playerid, 0.0);
    SendClientMessage(playerid, 0xAA3333AA, "You have been killed !");
    return 1;
}
CMD:weap(playerid,params[])
{
    if(DmMinigames[playerid] == 1) return SendClientMessage(playerid, 0xAA3333AA, "You can't use /weap in DM Minigames");
	if(IsNull(params)) return SendClientMessage(playerid, 0xAA3333AA, "/weap [weapon name]");
	new weaponid = GetWeaponIDFromName(params);
	if(weaponid == -1) return SendClientMessage(playerid, 0xAA3333AA, "Invalid weapon!");
	GivePlayerWeapon(playerid,weaponid,500);
	GivePlayerMoney(playerid, -5000);
	return 1;
}
CMD:godmode(playerid,params[])
{
	if(DmMinigames[playerid] == 1) return SendClientMessage(playerid, 0xAA3333AA, "You can't use godmode on DM Minigame");
	if(GodMode[playerid])
	{
	    SendClientMessage(playerid,-1,"GODMODE: OFF");
	    GodMode[playerid] = false;
	    SetPlayerHealth(playerid,100.0);
	}
	else
	{
	    SendClientMessage(playerid,-1,"GODMODE: ON");
	    GodMode[playerid] = true;
	}
	return 1;
}
CMD:vehgodmode(playerid,params[])
{
	if(VehGodMode[playerid])
	{
	    SendClientMessage(playerid,-1,"VEHGODMODE: OFF");
	    VehGodMode[playerid] = false;
	}
	else
	{
	    SendClientMessage(playerid,-1,"VEHGODMODE: ON");
	    VehGodMode[playerid] = true;
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			RepairVehicle(GetPlayerVehicleID(playerid));
		}
	}
	return 1;
}

CMD:skin(playerid, params[])
{
    new skin;
    if(sscanf(params, "i", skin)) return SendClientMessage(playerid, -1, "USAGE: /skin [Skin ID]");
    if(skin > 299 || skin < 0) return SendClientMessage(playerid, -1,"Invalid Skin ID!");
    SetPlayerSkin(playerid, skin);
    return 1;
}

CMD:fix(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "You are not in a vehicle!");
    if(GetPlayerState(playerid) != 2) return SendClientMessage(playerid, -1, "You are not in the driver seat!");
    RepairVehicle(GetPlayerVehicleID(playerid));
    SendClientMessage(playerid, -1, "Your vehicle has been sucessfully repaired!");
    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
    GivePlayerMoney(playerid, -5000);
    return 1;
}

CMD:colorcar(playerid, params[])
{
    new color[2];
    if(GetPlayerState(playerid) != 2) return SendClientMessage(playerid, 0xFF0000FF, "You are not driving a vehicle.");
    if(sscanf(params,"dD",color[0],color[1]))
    {
        return SendClientMessage(playerid, -1, "USAGE: /colorcar [color1] [color2]");
    }
    new
        string[128];
    format(string, sizeof(string), "You have change the vehicle's color 1 to %d and color 2 to %d!",color[0],color[1]);
    SendClientMessage(playerid, -1, string);
    ChangeVehicleColor(GetPlayerVehicleID(playerid),color[0],color[1]);
    return 1;
}

CMD:playdm(playerid, params[])
{
    {
        SetPlayerPos(playerid, 1302.519897,-1.787510,1001.028259);
        SetPlayerInterior(playerid, 18);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerArmour(playerid, 100);
        SetPlayerHealth(playerid, 100);
        GivePlayerWeapon(playerid, 24, 99999);
        GivePlayerWeapon(playerid, 31, 99999);
        GivePlayerWeapon(playerid, 34, 99999);
        GivePlayerWeapon(playerid, 29, 99999);
        DmMinigames[playerid] = 1;
    }
    return 1;
}

CMD:leavedm(playerid, params[])
{
    if(DmMinigames[playerid] == 0)
    {
        SendClientMessage(playerid, 0xAA3333AA, "You are not in Deathmatch Minigames to do that.");
    }
    else
    {
        DmMinigames[playerid] = 0;
        SetPlayerPos(playerid, -1784.4821,576.0916,35.1641);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        ResetPlayerWeapons(playerid);
    }
    return 1;
}

CMD:resetmyvw(playerid, params[])
{
	SetPlayerVirtualWorld(playerid, 0);
	SendClientMessage(playerid, yellow, "Success Reset Virtual World!");
	return 1;
}

CMD:afk(playerid, params[])
{
   SendClientMessage(playerid, yellow, "You are now AFK, type /back to move again!");
   TogglePlayerControllable(playerid,0);
   label[playerid] = Create3DTextLabel("AFK",yellow,30.0,40.0,50.0,40.0,0);
   Attach3DTextLabelToPlayer(label[playerid], playerid, 0.0, 0.0, 0.7);
   new string3[70];
   new name[MAX_PLAYER_NAME];
   GetPlayerName(playerid, name, sizeof(name));

   format(string3, sizeof(string3), "%s is now Away from the keyboard!", name);
   SendClientMessageToAll(yellow, string3);
   return 1;
}

CMD:back(playerid, params[])
{
   SendClientMessage(playerid, yellow, "You are now back!");
   TogglePlayerControllable(playerid,1);
   new string3[70];
   new name[MAX_PLAYER_NAME];
   GetPlayerName(playerid, name, sizeof(name));

   format(string3, sizeof(string3), "%s is now Back!", name);
   SendClientMessageToAll(yellow, string3);
   Delete3DTextLabel(Text3D:label[playerid]);
   return 1;
}

CMD:veh(playerid,params[])
{
	if(DmMinigames[playerid] == 1) return SendClientMessage(playerid, 0xAA3333AA, "You can't spawn car in DM Minigames");
    ShowPlayerDialog(playerid, DIALOG_CARMENU_MAINMENU, DIALOG_STYLE_LIST, "Vehicle Selection Menu","Bikes\nCars 1 [A-E]\nCars 2 [F-P]\nCars 3 [P-S]\nCars 4 [S-Z]\nHelicopters\nPlanes\nBoats\nTrailers\nRC Vehicles + Vortex", "Select", "Cancel");
    return 1;
}

CMD:spec(playerid, params[])
{
    new id;
    if(!IsPlayerAdmin(playerid))return 0;// This checks if the player is logged into RCON, if not it will return 0; (Showing "SERVER: Unknown Command") You can replace it with your own admin check.
    if(sscanf(params, "s[32]", id)) return SendClientMessage(playerid, 0xAA3333AA, "USAGE: /spec (playerid)");
    if(id == playerid)return SendClientMessage(playerid,Grey,"You cannot spec yourself.");// Just making sure.
    if(id == INVALID_PLAYER_ID)return SendClientMessage(playerid, Grey, "Player not found!");// This is to ensure that you don't fill the param with an invalid player id.
    if(IsSpecing[playerid] == 1)return SendClientMessage(playerid,Grey,"You are already specing someone.");// This will make you not automatically spec someone else by mistake.
    GetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// This is getting and saving the player's position in a variable so they'll respawn at the same place they typed '/spec'
    Inter[playerid] = GetPlayerInterior(playerid);// Getting and saving the interior.
    vWorld[playerid] = GetPlayerVirtualWorld(playerid);//Getting and saving the virtual world.
    TogglePlayerSpectating(playerid, true);// Now before we use any of the 3 functions listed above, we need to use this one. It turns the spectating mode on.
    if(IsPlayerInAnyVehicle(id))//Checking if the player is in a vehicle.
    {
        if(GetPlayerInterior(id) > 0)//If the player's interior is more than 0 (the default) then.....
        {
            SetPlayerInterior(playerid,GetPlayerInterior(id));//.....set the spectator's interior to that of the player being spectated.
        }
        if(GetPlayerVirtualWorld(id) > 0)//If the player's virtual world is more than 0 (the default) then.....
        {
            SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));//.....set the spectator's virtual world to that of the player being spectated.
        }
        PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));// Now remember we checked if the player is in a vehicle, well if they're in a vehicle then we'll spec the vehicle.
    }
    else// If they're not in a vehicle, then we'll spec the player.
    {
        if(GetPlayerInterior(id) > 0)
        {
            SetPlayerInterior(playerid,GetPlayerInterior(id));
        }
        if(GetPlayerVirtualWorld(id) > 0)
        {
            SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
        }
        PlayerSpectatePlayer(playerid,id);// Letting the spectator spec the person and not a vehicle.
    }
    new string[128];
    GetPlayerName(id, Name, sizeof(Name));//Getting the name of the player being spectated.
    format(string, sizeof(string),"You have started to spectate %s.",Name);// Formatting a string to send to the spectator.
    SendClientMessage(playerid,0x0080C0FF,string);//Sending the formatted message to the spectator.
    IsSpecing[playerid] = 1;// Just saying that the spectator has begun to spectate someone.
    IsBeingSpeced[id] = 1;// Just saying that a player is being spectated (You'll see where this comes in)
    spectatorid[playerid] = id;// Saving the spectator's id into this variable.
    return 1;// Returning 1 - saying that the command has been sent.
}

CMD:specoff(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))return 0;// This checks if the player is logged into RCON, if not it will return 0; (Showing "SERVER: Unknown Command")
    if(IsSpecing[playerid] == 0)return SendClientMessage(playerid,Grey,"You are not spectating anyone.");
    TogglePlayerSpectating(playerid, 0);//Toggling spectate mode, off. Note: Once this is called, the player will be spawned, there we'll need to reset their positions, virtual world and interior to where they typed '/spec'
    return 1;
}

CMD:tune1(playerid, params[])
{
    SetPlayerPos(playerid, 2645.0479,-2029.2050,13.2063);
    SetVehiclePos(GetPlayerVehicleID(playerid), 2645.0479,-2029.2050,13.2063);
    PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
    return 1;
}

CMD:tune2(playerid, params[])
{
	SetPlayerPos(playerid, -2705.1987,217.7348,3.8386);
	SetVehiclePos(GetPlayerVehicleID(playerid), -2705.1987,217.7348,3.8386);
	PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	return 1;
}

CMD:tune3(playerid, params[])
{
	SetPlayerPos(playerid, 1041.0607,-1039.9507,31.4253);
	SetVehiclePos(GetPlayerVehicleID(playerid), 1041.0607,-1039.9507,31.4253);
	PutPlayerInVehicle(playerid,PlayerVeh[playerid],0);
	return 1;
}
