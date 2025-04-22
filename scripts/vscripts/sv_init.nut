// script created by Rip Rip Rip (https://www.youtube.com/@Rip-Rip-Rip)
// version 1.10

::health <- null
function Precache()
{
    printl("[FALL DAMAGE] Precaching required assets...")
    PrecacheModel("models/items/healthkit.mdl")
    PrecacheSoundScript("HealthKit.Touch")
}

function Init()
{
    ::Dev <- Dev()
    Dev.msg("Initialising script...")

    ::SCOPE <- Storage.CreateScope("RipRipRip_FallDamage_V1_10")

    local interval = Entities.CreateByClassname("logic_timer")
    interval.__KeyValueFromString("targetname", "fd_interval")
    interval.__KeyValueFromFloat("RefireTime", 0.01)
    interval.ConnectOutput("OnTimer", "Interval")
    EntFire("fd_interval", "Enable")

    local auto = Entities.CreateByClassname("logic_auto")
    auto.ConnectOutput("OnLoadGame", "Init_LoadFromSave")
}
function Init_PlayerSetup()
{
    Dev.msg("Setting up player...")

    player = GetPlayer()

    local maxhealth = SCOPE.GetInt("player_maxhealth")
    if(maxhealth == 0) {  // presume first time script setup
        Dev.msg("Performing first time setup...")
        SCOPE.SetInt("player_maxhealth", player.GetMaxHealth())
        SCOPE.SetInt("player_health", player.GetMaxHealth())
        SCOPE.SetInt("player_regenenabled", 0)
        SCOPE.SetInt("player_health_persistenceenabled", 0)
        SCOPE.SetInt("hud_size", 2)
        SCOPE.SetInt("medkit_heal", 20)
        SCOPE.SetInt("medkit_enabled", 1)

        ::regenenabled <- 0
        ::healthpersistence <- 0
        ::hudsize <- 2
        ::medkit_heal <- 20
        ::medkit_enabled <- 1
    } else {
        Dev.msg("Grabbing previous values...")
        player.SetMaxHealth(SCOPE.GetInt("player_maxhealth"))
        ::regenenabled <- SCOPE.GetInt("player_regenenabled")
        ::healthpersistence <- SCOPE.GetInt("player_health_persistenceenabled")
        ::hudsize <- SCOPE.GetInt("hud_size")
        ::medkit_heal <- SCOPE.GetInt("medkit_heal")
        ::medkit_enabled <- SCOPE.GetInt("medkit_enabled")
        if(healthpersistence == 1) player.SetHealth(SCOPE.GetInt("player_health"))
        else SCOPE.SetInt("player_health", player.GetMaxHealth())
    }

    health = player.GetMaxHealth()
    playerHUDUpdate()

    local proxy = Entities.CreateByClassname("logic_playerproxy")   // required to remove boots from player
    proxy.__KeyValueFromString("targetname", "fd_proxy")
    EntFire("fd_proxy", "RemoveBoots")

    if(medkit_enabled == 1) medkitSpawn()

    Init_MapSpecific()
}
function Init_MapSpecific()
{
    local map = GetMapName()
    if(map == "sp_a4_laser_platform") {
        for(local trigger = null; trigger = Entities.FindByClassnameWithin(trigger, "trigger_multiple", Vector(2432,-584,-1944), 4);) {
            trigger.__KeyValueFromString("OnStartTouch", "fd_proxy,GiveBoots")
            trigger.__KeyValueFromString("OnStartTouch", "fd_proxy,RemoveBoots,,1")
            trigger.__KeyValueFromString("OnStartTouch", "fd_proxy,Kill,,1.01")
        }
    } else EntFire("fd_proxy", "Kill", "", FrameTime())
}
function Init_LoadFromSave()
{
    ::SCOPE <- Storage.CreateScope("RipRipRip_FallDamage_V1_10")
    SCOPE.SetInt("player_health", health)
    regenenabled = SCOPE.GetInt("player_regenenabled")
    healthpersistence = SCOPE.GetInt("player_health_persistenceenabled")
    hudsize = SCOPE.GetInt("hud_size")
    medkit_heal = SCOPE.GetInt("medkit_heal")
    medkit_enabled = SCOPE.GetInt("medkit_enabled")
    playerHUDUpdate()
}
function playerDetectHealthChange()
{
    if(regenenabled == 1) {
        local health_difference = abs(health - player.GetHealth())
        if(health_difference > 0) {
            health = player.GetHealth()
            SCOPE.SetInt("player_health", health)
            SendToPanorama("Drawer_NavigateToTab", health.tostring())
        }
    } else {
        local health_difference = player.GetMaxHealth() - player.GetHealth()
        if(health_difference > 0) {
            health -= health_difference
            SCOPE.SetInt("player_health", health)
            player.SetHealth(player.GetMaxHealth())
            if(health <= 0) {
                local hurt = Entities.CreateByClassname("point_hurt")
                hurt.__KeyValueFromString("targetname", "fd_hurt")
                hurt.__KeyValueFromString("DamageTarget", "!player")
                hurt.__KeyValueFromInt("Damage", 99999)
                hurt.__KeyValueFromInt("DamageType", 32)

                EntFire("fd_hurt", "TurnOn")
                EntFire("fd_hurt", "Hurt", "", FrameTime())
                EntFire("fd_hurt", "TurnOff", "", FrameTime() * 2)
                EntFire("fd_interval", "Kill")
                health = 0
                SCOPE.SetInt("player_health", player.GetMaxHealth())
            }
            SendToPanorama("Drawer_NavigateToTab", health.tostring())
        }
    }
}
function playerHealFromMedkit()
{
    health += medkit_heal
    if(health > player.GetMaxHealth()) health = player.GetMaxHealth()
    SCOPE.SetInt("player_health", health)
    playerHUDUpdate()
}
function playerHUDUpdate()
{
    // use these to get around event-definition.ts not being reloaded when "panorama_reload" is ran
    SendToPanorama("Drawer_NavigateToTab", health.tostring())   // health
    SendToPanorama("Drawer_ExtendAndNavigateToTab", player.GetMaxHealth().tostring())   // max health
    SendToPanorama("Drawer_UpdateLobbyButton", hudsize.tostring())    // hud size
}

function medkitSpawn()
{
    Dev.msg("Attempting to spawn medkits...")
    local point_ents = [
        "npc_security_camera",
        "prop_floor_button",
        "prop_button",
        "prop_tractor_beam",
        "prop_wall_projector",
        "prop_under_button",
        "prop_under_floor_button",
        "env_portal_laser",
        "prop_laser_catcher",
        "prop_laser_relay",
        "prop_weighted_cube",
        "npc_portal_turret_floor"
    ]
    local count = 0
    foreach(val in point_ents) {
        for(local point = null; point = Entities.FindByClassname(point, val);) {
            count++
            if(count % 2 == 0) continue // only spawn a medkit every other time

            Dev.msg_developer("Located medkit spawnpoint! (" + point + ")")
            local object = CreateEntityByName("item_healthkit", {targetname = "fd_medkit"})
            local origin = point.GetOrigin()
            object.SetOrigin(Vector(origin.x, origin.y, origin.z + 64))
            object.SetModel("models/items/healthkit.mdl")
            object.SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            object.Spawn()
        }
    }
}

::setup_hasfired <- false
::player <- null
function Interval()
{
    if(player != null) {   // wait for player to exist before doing anything
        if(setup_hasfired == false) {
            Init_PlayerSetup()
            setup_hasfired = true
        }
    } else return
    
    playerDetectHealthChange()
    if(GetDeveloperLevel() > 0) Dev.DisplayOnscreenInfo()

    if(medkit_enabled == 1) if(health < player.GetMaxHealth()) {
        for(local medkit = null; medkit = Entities.FindByClassnameWithin(medkit, "item_healthkit", player.GetOrigin(), 72);) {
            Dev.msg_developer("Located medkit close to player! (" + medkit + "), healing...")
            medkit.EmitSound("HealthKit.Touch")
            playerHealFromMedkit()
            EntFireByHandle(medkit, "Kill", "", 0.0, null, null)
        }
    }
}

// script commands
function SetHudSize(val)
{
    if(typeof(val) != "integer") {
        Dev.msg_error("Invalid input type! Only integer values are accepted.")
        return
    } else if(val <= 0 || val > 4) {
        Dev.msg_error("Invalid input size! Size must be 1, 2, 3 or 4!")
        return
    }

    hudsize = val

    SCOPE.SetInt("hud_size", hudsize)
    playerHUDUpdate()

    Dev.msg("Set HUD size to " + val + "!")
}
function SetMaxPlayerHealth(val)
{
    if(typeof(val) != "integer") {
        Dev.msg_error("Invalid input type! Only integer values are accepted.")
        return
    } else if(val <= 0) {
        Dev.msg_error("Invalid input size! Health must be >= 0!")
        return
    }
    
    player.SetMaxHealth(val)
    player.SetHealth(val)
    health = player.GetMaxHealth()

    SCOPE.SetInt("player_maxhealth", health)
    SCOPE.SetInt("player_health", health)
    playerHUDUpdate()

    Dev.msg("Set player's maximum health to " + val + "!")
}
function SetMedkitHealAmount(val)
{
    if(typeof(val) != "integer") {
        Dev.msg_error("Invalid input type! Only integer values are accepted.")
        return
    } else if(val <= 0) {
        Dev.msg_error("Invalid input size! Amount must be >= 0!")
        return
    }

    medkit_heal = val
    SCOPE.SetInt("medkit_heal", medkit_heal)

    Dev.msg("Set medkit heal amount to " + val + "!")
}
function DoSpawnMedkits(val)
{
    if(typeof(val) != "bool") {
        Dev.msg_error("Invalid input type! Only boolean values ('true'/'false') are accepted.")
        return
    }
    if(val == true) {
        Dev.msg("Enabled medkit spawning!")
        val = 1
    } else if(val == false) {
        Dev.msg("Disabled medkit spawning!")
        val = 0
    }
    
    medkit_enabled = val
    SCOPE.SetInt("medkit_enabled", medkit_enabled)
}
function DoHealthRegeneration(val)
{
    if(typeof(val) != "bool") {
        Dev.msg_error("Invalid input type! Only boolean values ('true'/'false') are accepted.")
        return
    }
    if(val == true) {
        Dev.msg("Enabled health regeneration!")
        val = 1
    } else if(val == false) {
        Dev.msg("Disabled health regeneration!")
        val = 0
    } 
    
    regenenabled = val
    SCOPE.SetInt("player_regenenabled", regenenabled)
    health = player.GetMaxHealth()
    player.SetHealth(health)
    SCOPE.SetInt("player_health", health)
    Dev.msg(SCOPE.GetInt("player_health"))
    SendToPanorama("Drawer_NavigateToTab", health.tostring())
}
function DoHealthPersistence(val)
{
    if(typeof(val) != "bool") {
        Dev.msg_error("Invalid input type! Only boolean values ('true'/'false') are accepted.")
        return
    }
    if(val == true) {
        Dev.msg("Enabled health persistence!")
        SCOPE.SetInt("player_health", health)
        val = 1
    } else if(val == false) {
        Dev.msg("Disabled health persistence!")
        val = 0
    } 
    healthpersistence = val
    SCOPE.SetInt("player_health_persistenceenabled", healthpersistence)
}
function ResetScript()
{
    SCOPE.ClearAll()
    Dev.msg("Reset script storage! Please restart the map to avoid any errors...")
}

// class containing useful dev functions
class Dev{
    function msg(msg) {
        printl("[FALL DAMAGE] " + msg)
    }
    function msg_error(msg) {
        printl("[FALL DAMAGE - ERROR] " + msg)
    }
    function msg_developer(msg) {
        if(GetDeveloperLevel() > 0) printl("[FALL DAMAGE - DEV] " + msg)
    }
    function DisplayOnscreenInfo() {
        DebugDrawScreenText(0.01, 0.535, "=== DEV:", 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.55, "ACTUAL HEALTH: " + player.GetHealth(), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.565, "INTERNAL HEALTH: " + health, 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.58, "INTERNAL HEALTH (SCOPED): " + SCOPE.GetInt("player_health"), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.595, "IS REGEN ENABLED: " + regenenabled, 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.61, "IS REGEN ENABLED (SCOPED): " + SCOPE.GetInt("player_regenenabled"), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.625, "MAX HEALTH: " + player.GetMaxHealth(), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.64, "MAX HEALTH (SCOPED): " + SCOPE.GetInt("player_maxhealth"), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.655, "IS HEALTH PERSISTENCE ENABLED: " + healthpersistence, 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.67, "IS HEALTH PERSISTENCE ENABLED (SCOPED): " + SCOPE.GetInt("player_health_persistenceenabled"), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.685, "HUD SIZE: " + hudsize, 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.7, "HUD SIZE (SCOPED): " + SCOPE.GetInt("hud_size"), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.715, "MEDKIT HEAL AMOUNT: " + medkit_heal, 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.73, "MEDKIT HEAL AMOUNT (SCOPED): " + SCOPE.GetInt("medkit_heal"), 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.745, "IS MEDKIT SPAWNING ENABLED: " + medkit_enabled, 255, 150, 255, 255, 0.05)
        DebugDrawScreenText(0.01, 0.76, "IS MEDKIT SPAWNING ENABLED (SCOPED): " + SCOPE.GetInt("medkit_enabled"), 255, 150, 255, 255, 0.05)
    }
    function DrawBox(pos, colour, time) {
        DebugDrawBox(pos, Vector(-2, -2, -2), Vector(2, 2, 2), colour.x, colour.y, colour.z, 75, time)
    }
}

Init()