/*
================================================================
    FERZDEVZ - MODERN RUNNER (Legacy)
    ------------------------------------------------------------
    Script      : LockSystem / Maintenance Mode
    Author      : FERZDEVZ
    Base        : FerzGamemodeZero
    Version     : 2.5 (Ultimate Patch)
    
    Youtube     : Ferzsampp
    Instagram   : ferzchills
    Discord     : ferzdevz
================================================================
*/

#define FILTERSCRIPT
#include <a_samp>

// --- Dialog IDs ---
#define DIALOG_LOCK_MAIN    9998
#define DIALOG_LOCK_REASON  9997
#define DIALOG_LOCK_TIME    9996
#define DIALOG_LOCK_CONFIRM 9995

// --- Localization ---
#define LANG_ID // Change to LANG_EN for English

#if defined LANG_ID
    #define MSG_LOCKED_ADMIN "{FF0000}[LOCK]{FFFFFF} Admin %s telah mengunci server. Alasan: %s"
    #define MSG_LOCKED_TIMER "{FF0000}[LOCK]{FFFFFF} Server terkunci selama %d menit. Alasan: %s"
    #define MSG_UNLOCKED "{00FF00}[LOCK]{FFFFFF} Server sekarang terbuka untuk umum."
    #define MSG_STATUS "[STATUS] %s {FFFFFF}| Alasan: %s"
    #define MSG_LOG_FORMAT "[%s] Admin %s: %s (Alasan: %s, Waktu: %d min)\n"
    #define MSG_KICK_NOTIF "SERVER LOCKED: Server ini sedang dalam mode maintenance."
    #define MSG_DIALOG_BODY "MAINTENANCE\n\n%s\n\nSilakan coba lagi nanti."
    #define MSG_AUTO_UNLOCK "[LOCK] Waktu maintenance habis. Server otomatis dibuka."
#else
    #define MSG_LOCKED_ADMIN "{FF0000}[LOCK]{FFFFFF} Admin %s has locked the server. Reason: %s"
    #define MSG_LOCKED_TIMER "{FF0000}[LOCK]{FFFFFF} Server locked for %d minutes. Reason: %s"
    #define MSG_UNLOCKED "{00FF00}[LOCK]{FFFFFF} Server is now open to the public."
    #define MSG_STATUS "[STATUS] %s {FFFFFF}| Reason: %s"
    #define MSG_LOG_FORMAT "[%s] Admin %s: %s (Reason: %s, Time: %d min)\n"
    #define MSG_KICK_NOTIF "SERVER LOCKED: This server is in maintenance mode."
    #define MSG_DIALOG_BODY "MAINTENANCE\n\n%s\n\nPlease try again later."
    #define MSG_AUTO_UNLOCK "[LOCK] Maintenance time is up. Server automatically unlocked."
#endif

// --- Configuration ---
static bool:gServerLocked = false;
static gLockReason[128] = "Server is under maintenance.";
static gHostName[64];
static gUnlockTimer = -1;
static const gDiscordWebhook[] = ""; // Add your Discord Webhook URL here

// Menu Temp Data
static gMenuReason[128][MAX_PLAYERS];

static const gIPWhitelist[][] = {
    "127.0.0.1"
};

// --- Logic ---

public OnFilterScriptInit()
{
    // Note: SA-MP doesn't easily expose hostname to FS via native,
    // you might need to set gHostName manually here if redirection fails.
    format(gHostName, sizeof(gHostName), "My Awesome Server"); 
    
    print("\n--------------------------------------");
    print(" [LOCK] Universal Lock (Legacy SA-MP) Loaded");
    print(" Commands: /lockserver, /unlockserver");
    print("--------------------------------------\n");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_LOCK_MAIN)
    {
        if(!response) return 1;
        if(listitem == 0) // Lock Server
        {
            if(gServerLocked) return SendClientMessage(playerid, 0xFF0000FF, "SERVER: Already locked.");
            #if defined LANG_ID
                ShowPlayerDialog(playerid, DIALOG_LOCK_REASON, DIALOG_STYLE_LIST, "Pilih Alasan", "Update Server\nPerbaikan Bug\nPersiapan Event\nCustom...", "Pilih", "Batal");
            #else
                ShowPlayerDialog(playerid, DIALOG_LOCK_REASON, DIALOG_STYLE_LIST, "Select Reason", "Server Update\nBug Fixes\nEvent Preparation\nCustom...", "Select", "Cancel");
            #endif
        }
        else if(listitem == 1) // Unlock Server
        {
            if(!gServerLocked) return SendClientMessage(playerid, 0xFF0000FF, "SERVER: Not locked.");
            UnlockServer();
            LogAction(playerid, "Manual Unlock", "N/A", 0);
        }
        else if(listitem == 2) // Check Status
        {
            new str[128];
            format(str, sizeof(str), MSG_STATUS, gServerLocked ? ("{FF0000}LOCKED") : ("{00FF00}OPEN"), gLockReason);
            SendClientMessage(playerid, -1, str);
        }
        return 1;
    }
    
    if(dialogid == DIALOG_LOCK_REASON)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: format(gMenuReason[playerid], 128, "Server Update");
            case 1: format(gMenuReason[playerid], 128, "Bug Fixes");
            case 2: format(gMenuReason[playerid], 128, "Event Preparation");
            case 3: 
            {
                #if defined LANG_ID
                    ShowPlayerDialog(playerid, DIALOG_LOCK_CONFIRM, DIALOG_STYLE_INPUT, "Alasan Custom", "Masukkan alasan maintenance:", "OK", "Batal");
                #else
                    ShowPlayerDialog(playerid, DIALOG_LOCK_CONFIRM, DIALOG_STYLE_INPUT, "Custom Reason", "Enter maintenance reason:", "OK", "Cancel");
                #endif
                return 1;
            }
        }
        #if defined LANG_ID
            ShowPlayerDialog(playerid, DIALOG_LOCK_TIME, DIALOG_STYLE_LIST, "Pilih Durasi", "Tanpa Batas\n15 Menit\n30 Menit\n60 Menit", "Pilih", "Batal");
        #else
            ShowPlayerDialog(playerid, DIALOG_LOCK_TIME, DIALOG_STYLE_LIST, "Select Duration", "No Limit\n15 Minutes\n30 Minutes\n60 Minutes", "Select", "Cancel");
        #endif
        return 1;
    }

    if(dialogid == DIALOG_LOCK_CONFIRM)
    {
        if(!response || !strlen(inputtext)) return 1;
        format(gMenuReason[playerid], 128, "%s", inputtext);
        #if defined LANG_ID
            ShowPlayerDialog(playerid, DIALOG_LOCK_TIME, DIALOG_STYLE_LIST, "Pilih Durasi", "Tanpa Batas\n15 Menit\n30 Menit\n60 Menit", "Pilih", "Batal");
        #else
            ShowPlayerDialog(playerid, DIALOG_LOCK_TIME, DIALOG_STYLE_LIST, "Select Duration", "No Limit\n15 Minutes\n30 Minutes\n60 Minutes", "Select", "Cancel");
        #endif
        return 1;
    }

    if(dialogid == DIALOG_LOCK_TIME)
    {
        if(!response) return 1;
        new minutes = 0;
        switch(listitem)
        {
            case 1: minutes = 15;
            case 2: minutes = 30;
            case 3: minutes = 60;
        }
        ExecuteLock(playerid, gMenuReason[playerid], minutes);
        return 1;
    }

    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(gServerLocked && !IsPlayerAllowed(playerid))
    {
        // Simple message for legacy clients
        SendClientMessage(playerid, 0xFF0000FF, MSG_KICK_NOTIF);
        
        new str[256];
        format(str, sizeof(str), MSG_DIALOG_BODY, gLockReason);
        ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "Server Locked", str, "Quit", "");
        
        SetTimerEx("LockKickPlayer", 1000, false, "i", playerid);
        return 0;
    }
    return 1;
}

stock bool:IsPlayerAllowed(playerid)
{
    if(IsPlayerAdmin(playerid)) return true;
    
    new ip[16];
    GetPlayerIp(playerid, ip, sizeof(ip));
    
    for(new i = 0; i < sizeof(gIPWhitelist); i++)
    {
        if(!strcmp(ip, gIPWhitelist[i])) return true;
    }
    return false;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[32], params[128], idx;
    
    // Legacy compatible parsing
    while ((idx < strlen(cmdtext)) && (cmdtext[idx] <= ' ')) idx++;
    new offset = idx;
    while ((idx < strlen(cmdtext)) && (cmdtext[idx] > ' ') && ((idx - offset) < (sizeof(cmd) - 1)))
    {
        cmd[idx - offset] = cmdtext[idx];
        idx++;
    }
    cmd[idx - offset] = '\0';
    while ((idx < strlen(cmdtext)) && (cmdtext[idx] <= ' ')) idx++;
    strmid(params, cmdtext, idx, strlen(cmdtext));

    if(!strcmp(cmd, "/lockmenu", true))
    {
        if(!IsPlayerAdmin(playerid)) return 0;
        
        #if defined LANG_ID
            ShowPlayerDialog(playerid, DIALOG_LOCK_MAIN, DIALOG_STYLE_LIST, "LockSystem Menu", "Kunci Server\nBuka Server\nCek Status", "Pilih", "Tutup");
        #else
            ShowPlayerDialog(playerid, DIALOG_LOCK_MAIN, DIALOG_STYLE_LIST, "LockSystem Menu", "Lock Server\nUnlock Server\nCheck Status", "Select", "Close");
        #endif
        return 1;
    }

    if(!strcmp(cmd, "/lockserver", true))
    {
        if(!IsPlayerAdmin(playerid)) return 0;

        new reason[128], time_str[16];
        new minutes = 0;
        
        // Advanced Parsing: /lockserver [reason] [minutes]
        strmid(reason, params, 0, strlen(params));
        
        new last_space = -1;
        for(new i = 0; i < strlen(params); i++) if(params[i] == ' ') last_space = i;
        
        if(last_space != -1)
        {
            strmid(time_str, params, last_space + 1, strlen(params));
            minutes = strval(time_str);
            if(minutes > 0) strmid(reason, params, 0, last_space);
            else minutes = 0;
        }

        ExecuteLock(playerid, reason, minutes);
        return 1;
    }

    if(!strcmp(cmd, "/unlockserver", true))
    {
        if(!IsPlayerAdmin(playerid)) return 0;

        UnlockServer();
        return 1;
    }

    if(!strcmp(cmd, "/lockstatus", true))
    {
        if(!IsPlayerAdmin(playerid)) return 0;

        new str[128];
        format(str, sizeof(str), MSG_STATUS, gServerLocked ? ("{FF0000}LOCKED") : ("{00FF00}OPEN"), gLockReason);
        SendClientMessage(playerid, -1, str);
        return 1;
    }

    return 0;
}

forward LockKickPlayer(playerid);
public LockKickPlayer(playerid)
{
    if(IsPlayerConnected(playerid)) Kick(playerid);
}

forward AutoUnlock();
public AutoUnlock()
{
    UnlockServer();
    SendClientMessageToAll(0x00FF00FF, MSG_AUTO_UNLOCK);
}

stock ExecuteLock(playerid, const reason[], minutes)
{
    if(strlen(reason) > 0) format(gLockReason, sizeof(gLockReason), "%s", reason);
    else format(gLockReason, sizeof(gLockReason), "Server is under maintenance.");

    gServerLocked = true;
    
    new rcon[128], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    
    format(rcon, sizeof(rcon), "hostname [LOCKED] %s", gHostName);
    SendRconCommand(rcon);
    
    new str[144];
    if(minutes > 0)
    {
        format(str, sizeof(str), MSG_LOCKED_TIMER, minutes, gLockReason);
        if(gUnlockTimer != -1) KillTimer(gUnlockTimer);
        gUnlockTimer = SetTimerEx("AutoUnlock", minutes * 60000, false, "");
    }
    else
    {
        format(str, sizeof(str), MSG_LOCKED_ADMIN, name, gLockReason);
    }
    
    SendClientMessageToAll(0xFF0000FF, str);
    SendDiscordNotification(str);
    LogAction(playerid, "Lock", gLockReason, minutes);
    return 1;
}

stock UnlockServer()
{
    gServerLocked = false;
    if(gUnlockTimer != -1) KillTimer(gUnlockTimer);
    gUnlockTimer = -1;
    
    new rcon[128];
    format(rcon, sizeof(rcon), "hostname %s", gHostName);
    SendRconCommand(rcon);
    
    SendClientMessageToAll(0x00FF00FF, MSG_UNLOCKED);
    SendDiscordNotification("Server has been unlocked.");
    print("[LOCK] Maintenance mode disabled.");
}

stock LogAction(playerid, const type[], const reason[], minutes)
{
    new File:f = fopen("scriptlogs/locksystem.log", io_append); 
    if(f)
    {
        new name[MAX_PLAYER_NAME], date[32], str[256];
        GetPlayerName(playerid, name, sizeof(name));
        
        new yr, mn, dy, hr, mi, se;
        getdate(yr, mn, dy);
        gettime(hr, mi, se);
        format(date, sizeof(date), "%02d/%02d/%04d %02d:%02d:%02d", dy, mn, yr, hr, mi, se);
        
        format(str, sizeof(str), MSG_LOG_FORMAT, date, name, type, reason, minutes);
        fwrite(f, str);
        fclose(f);
    }
}

stock SendDiscordNotification(const message[])
{
    if(strlen(gDiscordWebhook) < 10) return;
    
    // Placeholder for actual HTTP request
    printf("[DISCORD] %s", message);
}
