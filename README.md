# Nerd.nu Zombies minigame

Located here is a fork of the NerdNu CommandHelper repo. I've added the required files to this base script to make the zombie minigame. I had to remove some files due to compilation errors from, what I assume, to be missing databases and such.

The added files are located in the LocalPackages/creative-only/minigames directory of this repo.

Below is the documentation on how to use these scripts.

| Command | Explanation | Permission |
|---------|-------------|------------|
| /nerdarena create \<name> | Creates a new arena, based on the worldedit selection, named whatever is specified | nerdarena.create |
| /nerdarena delete \<id> | Deletes the arena with the specified ID | nerdarena.delete (nerdarena.delete.other to delete arenas you don't own) |
| /nerdarena list \[player] | Lists your arenas if no player is given. Special permission needed to check other players | nerdarena.create (nerdarena.list.other to list arenas you don't own) |
| /nerdarena addeffect \<arenaid> \<team> \<effect> \<strength> \<start> \<end> | Adds an effect that will affect all players of the team specified between the two times provided, in seconds. The beginning of the round is 600, end is 0 | nerdarena.effect.add |
| (WIP) /nerdarena listeffects \<arenaid> | Lists the effects belonging to an arena. Special permission needed for arenas not owned by you | nerdarena.effect.list (nerdarena.effect.list to list effects for arenas you don't own) |
| /nerdarena create \<name> | Creates a new arena, based on the worldedit selection, named whatever is specified | nerdarena.create |
| /nerdarena create \<name> | Creates a new arena, based on the worldedit selection, named whatever is specified | nerdarena.create |
| /nerdarena create \<name> | Creates a new arena, based on the worldedit selection, named whatever is specified | nerdarena.create |
