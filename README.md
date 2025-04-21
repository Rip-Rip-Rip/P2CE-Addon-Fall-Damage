# Portal 2 with Fall Damage (P2:CE Addon)
 
Content source for the "Portal 2 with Fall Damage" Portal 2: Community Edition workshop addon.

Workshop page: https://steamcommunity.com/sharedfiles/filedetails/?id=3467618114

NOTE: This addon has a custom panorama health display. When on the main menu after enabling this addon, run the command "panorama_reload". This will reload panorama and enable the custom health display. If the game complains about any errors, just press ignore.

-----

Have you ever wondered what Portal 2 would be like if Chell didn't have her Long Fall Boots™?
Well, wonder no more! :D

In this addon, fall damage is enabled and health regeneration is disabled. On the load of every map, Chell regains her health (unless health persistence is enabled).

-----

This mod has some settings you can adjust:

`SetHudSize(val)` // Sets the size of the onscreen health display. Has 4 sizes. Set value persists across maps. Takes integers 1, 2, 3 or 4 as a parameter, corresponding to different size levels.

`SetMaxPlayerHealth(val)` // Sets the player's maximum health and heals the player to full health. Set value persists across maps. Takes an integer > 0 as a parameter.

`DoHealthRegeneration(val)` // Enables/Disables player health regeneration. Set value persists across maps. Takes a boolean value ('true'/'false') as a parameter.

`DoHealthPersistence(val)` // Enables/Disables player health persistence (whether the player's health in one level is transfered into future levels). Takes a boolean value ('true'/'false') as a parameter.

In order to change these settings, open the console whilst inside a map and run the command: script [function]
(e.g. `script SetMaxPlayerHealth(150)`).

---

DEVELOPER:

`ResetScript()` // Used to reset the script back to default, only run this if something breaks.

-----

Credits:

sirenstorm - Partially creating the panorama health display.  
Beckeroo - Playtesting + feedback.

-----

If you experience any issues, please either:
- Make an issue on this repository.
- Create a pull request if you're experienced with VScripting.
- Leave a comment on the workshop page linked above.
- Drop me a DM on Discord. Handle: @ripriprip

Enjoy! <3
