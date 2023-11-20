# Nerd.nu Zombies minigame

Located here is a fork of the NerdNu CommandHelper repo. I've added the required files to this base script to make the zombie minigame. I had to remove some files due to compilation errors from, what I assume, to be missing databases and such.

The added files are located in the LocalPackages/creative-only/minigames directory of this repo.

The ZombieSQL database defined in the code can be generated using the following [SQL file](https://we.tl/t-NdZngLEPZd).

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
| /nerdarena listitems \<arena id> | Lists your items if no player is given if you own the arena or have the permission to see other arena's information. Output is in JSON for now, will be updated later on to simplify the view. | nerdarena.create |
| /nerdarena delitem \<item id> | Deletes the arena's item with the ID specified if it's your arena or you have permission to delete other arena's information. | nerdarena.delete |

## Effect Modification Commands
| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena addeffect \<arena id> \<team> \<effect> \<strength> \<start> \<end> | Adds an effect that will affect all players of the team specified between the two times provided, in seconds. The beginning of the round is 600, end is 0. | nerdarena.create |
| (WIP) /nerdarena listeffects \<arena id> | Lists the effects belonging to an arena if it's your arena or you have permission to delete other arena's information. | nerdarena.list |
| (WIP) /nerdarena deleffect \<effect id> | Deletes an existing effect from an arena if it's your arena or you have permission to delete other arena's information. | nerdarena.delete |

# How to make an arena

## Creating the physical arena
Before anything can be done, an arena must be made that encompasses the play area of the game. To do so, you must select two opposing corners of an arena with your WorldEdit tool. Create a **cuboid** selection and run the command /nerdarena create [name] where [name] is whatever you wish your arena to be called. Doing this requires you to have the nerdarea.create permission.

![image](https://github.com/PPGOME/NerdMinigames/assets/67039523/684e7996-33ac-4b5d-b8b9-83a65d1de352)

Once you get the message confirming that your arena is created, you may move on to the next section.

# Current Roadmap
- [X] Let players define an area for an arena
- [X] Let players add teams to the arenas
- [X] Let players add spawns to the arenas
- [X] Let players add items to the arenas
- [ ] Let players add effects to the arenas
- [X] Build the game queue logic
- [X] Build the game start logic
- [X] Build the game clock for mid-round events and time-keeping
- [X] Add anti-teamkill system
- [X] Build kill logic
- [X] Document commands
- [ ] Document how to make an arena
- [ ] Add armour modifcation to the arena customizer
- [ ] Let players define game plates through commands
- [ ] Add an end-round celebration thing (SRS mentioned this)
- [ ] Add windows that only zombies can walk through
- [ ] Add areas where blocks can be placed
- [ ] Make it so players can't leave the arena
