# Field Guide
An addon for World of Warcraft: Classic.

`/fg` and `/fieldguide` will open the window.
`/fg minimap` and `/fieldguide minimap` will toggle the minimap button on or off.

- Use shift + scroll to scroll horizontally.
- Right click to mark spells as unwanted.
- Shift-right click a spell to mark all ranks of that spell as unwanted.

![Current progress](https://i.imgur.com/CIbDcin.png)

## Features
- Shows you which spells each class learns every level to plan when you need to go back to town (includes Warlock demon spells and Hunter pet skills).
- Shows you which classes can learn which weapon skills (staves, one-handed swords and so on).
- Tells you how much each spell/weapon skill costs to train so you know if you can afford it or not (includes PvP rank and reputation modifiers).
- You can filter out known spells and/or talents.
- You can mark unwanted spells by right clicking on them. Shift-right clicking on a spell will mark all the ranks of that spell.
- You can drag a spell from the addon onto an action bar.
- Clicking on a spell will direct you to the closest class trainer *not taking into account any flight paths/boats etc.* by making a pin on your map/minimap. If TomTom is installed, the addon will show the Crazy Arrow for you as well.
- Similarly, clicking on any weapon skill will show the closest trainer for that skill *not taking into account any flight paths/boats etc.* (also lists where all trainers are when hovering over each skill).

## Features for after launch (a while after launch)
- Spells that are learned through quests are currently just listed normally with a 0c cost. The plan is to direct players to/through these quests somehow.
- Professions – when are Silk Bandages learned? When can Gold be smelt?

## Bugs
- Some spells and ranks might be wrong, as I've gone off private server and Classic Wowhead (please get an API) data, both of which currently aren't very accurate. For example, on a certain private server (rhymes with Blight's Rope), Shadowburn rank 6 cost 2g 20s while it should have cost 11s only (baseline).
