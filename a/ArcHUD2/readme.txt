ArcHUD 2.0
-------------

This addon adds a combat HUD to your UI, showing player/target/pet hp and mana/rage/whatever as rings centered on your screen. It uses the StatRings code originally made by Iriel but later modified by Antiarc. It also shows a small target frame with textual hp/mana as well as a 3D target model for other players.

It has support for FlightMap destination timers and also have a casting bar with spell text and timer. If the casting bar is enabled it will hide the default Blizzard casting bar.

ArcHud uses MobHealth2/MobInfo-2 for mob health display.

Based on Tivoli's beta Nurfed HUD which used the StatRings modification by Antiarc.

Some of the features implemented in ArcHUD was first implemented in other addons, credits goes out to Moog for his modification of NurfedHUD called Moog_Hud as well as to Repent for creating eCastingBar where I got the FlightMap support code from.

Once installed you can access ArcHUD options by typing /archud or /ah in the chat window.

Written by Saleel/Nenie of Argent Dawn.



Changelog
-----------

06-08-24 - 2.0.8945
* Updated TOC for 1.12
* Added deDE locale
* Fixed remaining fontstrings to not show ...

06-08-18 - 2.0.8359
* Updated locales
* Fixed DruidMana booleans
* Added native support for MobHealth3
* Made target nameplate always be active
* Fixed clickcasting support

06-08-16 - 2.0.8158
* Added PvP indicator to nameplate
* Added PvP/group leader/raid target icons to the target frame
* Added class/creature type/creature family to level display
* Fixed fontstrings not being big enough for the text
* Fixed timer issue with DruidMana

06-08-13 - 2.0.7892
* Reworked the entire addon to use Ace2 instead of Ace. As such, Ace is no longer a dependency as Ace2 is completely embedded in the addon
* Party interface has been removed as it was not the intention of ArcHUD to become a full unitframes-addon
* Locale for zhCN added
* Added options to show/hide Blizzard player/pet/target frames
* Alot of other fixes and stuff I can't remember