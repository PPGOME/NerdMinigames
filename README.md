# Nerd.nu Zombies minigame

Located here is a fork of the NerdNu CommandHelper repo. I've added the required files to this base script to make the zombie minigame. I had to remove some files due to compilation errors from, what I assume, to be missing databases and such.

The added files are located in the LocalPackages/creative-only/minigames directory of this repo.

The ZombieSQL database defined in the code can be generated using the following [SQL file](https://we.tl/t-BhdiK9cFRE).

Below is the documentation on how to use these scripts.

# Commands & Permissions

All commands that modify an arena in any way are restricted to the player who made that arena, unless a user is granted a permission with `.other` added to the end (i.e. nerdarena.create.other). Commands that support this make it clear in their descriptions below.

For commands that need IDs (mostly just the delete commands), use the list command for that category and it will show you the element's ID.

## Arena Modification Commands
| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena create \<name> | Creates a new arena, based on the worldedit selection, named whatever is specified | nerdarena.create |
| /nerdarena list \[player] | Lists your arenas if no player is given. Special permission needed to check other players | nerdarena.list |
| /nerdarena delete \<arena id> | Deletes the arena with the specified ID | nerdarena.delete |

## Team Modification Commands
| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena addteam \<arena id> \<team name>| Creates a new team for the arena specified named whatever is specified | nerdarena.create |
| /nerdarena listteams \<arena id> | Lists the arena specified's teams if you own it or have the permission to see other arena's information | nerdarena.list |
| /nerdarena delteam \<team id> | Deletes the arena's team with the ID specified if it's your arena or you have permission to delete other arena's information | nerdarena.delete |

## Spawn Modification Commands
| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena addspawn \<arena id> \<team name>| Creates a new spawn for the arena and team specified. | nerdarena.create |
| /nerdarena listspawns \<arena id> | Lists the arena specified's spawns if you own it or have the permission to see other arena's information. | nerdarena.list |
| /nerdarena delspawn \<spawn id> | Deletes the arena's spawn with the ID specified if it's your arena or you have permission to delete other arena's information. | nerdarena.delete |

## Item Modification Commands
| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena additem \<arena id> \<team name> | Creates a new item for the arena and team specificed. Note that the item being held is what is saved. All data is saved - name, enchantments, NBT data, the amount of item, etc. Whatever you see in that slot when the command is run is what the arena will have. | nerdarena.create |
| /nerdarena listitems \<arena id> | Lists your items if no player is given if you own the arena or have the permission to see other arena's information. Output is in JSON for now, will be updated later on to simplify the view. | nerdarena.list |
| /nerdarena delitem \<item id> | Deletes the arena's item with the ID specified if it's your arena or you have permission to delete other arena's information. | nerdarena.delete |

## Effect Modification Commands
| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena addeffect \<arena id> \<team> \<effect> \<strength> \<start> \<end> | Adds an effect that will affect all players of the team specified between the two times provided, in seconds. The beginning of the round is 600, end is 0. | nerdarena.create |
| (WIP) /nerdarena listeffects \<arena id> | Lists the effects belonging to an arena if it's your arena or you have permission to delete other arena's information. | nerdarena.list |
| (WIP) /nerdarena deleffect \<effect id> | Deletes an existing effect from an arena if it's your arena or you have permission to delete other arena's information. | nerdarena.delete |

# How to make your own Zombies minigame

## Creating the physical arena
Before anything can be done, an arena must be made that encompasses the play area of the game. To do so, you must select two opposing corners of an arena with your WorldEdit tool. Create a **cuboid** selection and run the command `/nerdarena create [name]` where [name] is whatever you wish your arena to be called. Doing this requires you to have the `nerdarena.create` permission.

![image](https://github.com/PPGOME/NerdMinigames/assets/67039523/684e7996-33ac-4b5d-b8b9-83a65d1de352)

Once you get the message confirming that your arena is created, you may move on to the next section.

## Adding teams

Adding teams is the first step that should be done when creating the arena. Anything following has no particular order.

The zombie minigame requires two specific teams with specific names, those being HUMANS and ZOMBIES. Run the commands below to set them up, but fill the `<arena id>` field with your arena's ID (`/nerdarena list`)

- `/nerdarena addteam <arena id> HUMANS`
- `/nerdarena addteam <arena id> ZOMBIES`

## Adding spawns

Players will need spots in your arena to spawn at throughout the course of the game. Setting up these spawns is dependant on the teams created above, so make sure to do those first.

Each team can have multiple spawns, but both use those spawns differently than the other. Humans will have a spawn randomized at the beginning of the round and only once. The game will spawn the humans all together in that area _once_ for the entire round. Humans never spawn again. Zombies, however, respawn constantly throughout the game and their spawn is randomized each time.

When running the command to add a spawn, the game takes your current coordinates as well as the direction you're looking and saves it. Whatever you see when the command is run is what the players will see when spawning in.

Use the following commands to create a new spawn:
- `/nerdarena addspawn <arena id> HUMANS`
- `/nerdarena addspawn <arena id> ZOMBIES`

## Adding items

Items are easily the most customizable options this minigame has to offer. Literally any aspect of any item is able to be modified and saved, as long as Minecraft allows it.

Let's make a sword for the humans to wield. We'll name an iron sword to fancy it up and give it the sharpness enchantment. The image below is the item I'll be giving out to players:

![image](https://github.com/PPGOME/NerdMinigames/assets/67039523/40a0ef56-d9bd-463e-97f1-aa7c8a86fe97)

The command I'll use to make this will be `/nerdarena additem <arena id> HUMANS 100`. Why is there a 100 at the end? That's the chance option. If you want a team to spawn with an item 100% of the time, set that number to 100. This command means that every human that spawns will have this iron sword.

Next, let's make an item for the zombies. I decided to give them a little snack, pictured below:

![image](https://github.com/PPGOME/NerdMinigames/assets/67039523/21c691b9-f326-4b19-ad06-015e99567ab4)

For this I just renamed potatoes, but you can see that there's 8 of them in that slot. If I run that command to save the item, it also saves the amount of items in that slot. So make sure you hold the amount you want to hand out. The command I would run for this would be `/nerdarena additem <arena id> ZOMBIES 50`.

But wait, that 100 became a 50 in the second command? Yes, that indicates that whenever a zombie respawns, it has a 50% chance of spawning with that item. Make sure to modify that if you want items to have a _possibility_ of spawning in. Otherwise just use 100 to indicate that it always spawns with a player.

## Adding effects

Before adding effects, we have to understand how the game's clock works.

The game clock counts down from 600 to 0. The round is 10 minutes long, which is 600 seconds. Effects use a start and end time as they are effects applied by the game based on areas of time specified. However, how it is currently set up is that the beginning of the round is at 600 seconds and the end is 0 seconds.

Based on that information, we can understand how to apply it to the effects command. Say I wanted to give the humans swiftness 1 from the beginning of the round and end it 4 minutes in. The command I would run would be `/nerdarena addeffect <arena id> HUMANS SPEED 1 600 360`. Notice how the effect name isn't SWIFTNESS? That's because some effect names are different depending on where you look at them. And where the game looks, a few names don't match what you're used to. Below is a table with all of the effect names you're used to and the ones needed for this command.

| Minecraft Name | Minigame Name || Minecraft Name | Minigame Name |
|---------|-------------|-|---------|-------------|
| Slowness | SLOWNESS || Invisibility | INVISIBILITY |
| Slow Falling | SLOW_FALLING || Bad Omen | BAD_OMEN |
| Weakness | WEAKNESS || Dolphin's Grace | DOLPHINS_GRACE |
| Harming | INSTANT_DAMAGE || Mining Fatigue | MINING_FATIGUE |
| Swiftness | SPEED || Withering | WITHER |
| Luck | LUCK || Fire Resistance | FIRE_RESISTANCE |
| Water Breathing | WATER_BREATHING || Glowing | GLOWING |
| Absorption | ABSORPTION || Hunger | HUNGER |
| Bad Luck | BAD_LUCK || Hero of the Village | HERO_OF_THE_VILLAGE |
| Regeneration | REGENERATION || Strength | STRENGTH |
| Blindness | BLINDNESS || Levitation | LEVITATION |
| Conduit Power | CONDUIT_POWER || Jump Boost | JUMP_BOOST |
| Poison | POISON || Nausea | NAUSEA |
| Resistance | RESISTANCE || Regeneration | HEALTH_BOOST |
| Darkness | DARKNESS || Night Vision | NIGHT_VISION |
| Instant Health | INSTANT_HEALTH || Haste | HASTE |
| Saturation | SATURATION ||||

And going back to the beginning regarding the game's handling of time, let's look at the command we made again: `/nerdarena addeffect <arena id> HUMANS SPEED 1 600 360`. At the end, you can see the numbers 600 and 360. 600 indicates that this starts at the beginning of the round. 599 would be 1 second into the round. For the second number, 360, that's 600 minus 240. We do that because 240 seconds is 4 minutes, meaning we want to end this effect 4 minutes into the round.

It can be a bit confusing, but tinkering around with it will help it make more sense, so play around!

# Current Roadmap
- [X] Let players define an area for an arena
- [X] Let players add teams to the arenas
- [X] Let players add spawns to the arenas
- [X] Let players add items to the arenas
- [X] Let players add effects to the arenas
- [X] Build the game queue logic
- [X] Build the game start logic
- [X] Build the game clock for mid-round events and time-keeping
- [X] Add anti-teamkill system
- [X] Build kill logic
- [X] Document commands
- [X] Add a way to end the game if all humans die
- [X] Document how to make an arena
- [ ] Add armour modifcation to the arena customizer
- [ ] Let players define game plates through commands
- [ ] Add an end-round celebration thing (SRS mentioned this)
- [ ] Add windows that only zombies can walk through
- [ ] Add areas where blocks can be placed
- [ ] Make it so players can't leave the arena
