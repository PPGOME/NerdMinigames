// MAIN LOGIC FOR THE ZOMBIE MINIGAME

// There are a lot of repeat SQL queries here that could have been in a procedure, but trying to return an array from a query through a procedure always resulted
// in an empty array. Not sure why, but just doing it like normal, messy code is the only way I could get this delivered somewhat on time.

// A lot of the code is messy, repetitive, and could probably be broken down into more procedures, but I'll do that once I get confirmation that the functionality is okay due to
// the reasons mentioned above.

// Handles the closing of the game.
proc _gameCloser(int @GameID, int @clock) {
    @updatestatus = query('ZombieSQL', 'UPDATE `gameinstances` SET GameStatus = ? WHERE GameID = ?', 'done', @GameID)
    @wipeplayers = query('ZombieSQL', 'DELETE FROM `gameplayers` WHERE GameID = ?', @GameID)
    remove_bar(@GameID)
    clear_task(@clock)
}

// Handles the minigame's clock. Most things that happen unprovoked in-game happen here.
proc _gameClock(int @GameID, int @ArenaID) {
    @time = array(600);
    @effectsandplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` JOIN `gameinstances` ON `gameplayers`.GameID = `gameinstances`.GameID JOIN `arenaeffects`
    ON `gameinstances`.ArenaID = `arenaeffects`.ArenaID WHERE `gameplayers`.GameID = ?', @GameID)

    // Runs a loop that executes everything inside once per second
    @clock = set_interval(1000, closure() {
        // For every effect the arena has
        foreach(@event in @effectsandplayers) {
            // If the team that the effect is tied to matches the player's team
            if(@event['Team'] == @event['EffectTeam']) {
                // Check if the current time matches the start time of the effect. If so, start effect.
                if(@event['StartTime'] == @time[0]) {
                    set_peffect(@event['PlayerUUID'], @event['Effect'], @event['Potency'] - 1, 99999, true, false)
                // If not the start time, check if it matches the end time. If so, remove effect.
                } else if(@event['EndTime'] == @time[0]) {
                    set_peffect(@event['PlayerUUID'], @event['Effect'], @event['Potency'] - 1, 0, true, false)
                }
            }
        }
        // Display the clock. If adds the 0 for seconds in the event it's a 1-digit number. Else, display as normal.
        if(ceil(@time[0]%60) < 10) {
            update_bar(@GameID, array('title': 'Time Left - '.floor(@time[0]/60).':0'.ceil(@time[0]%60), 'percent': @time[0]/600))
        } else {
            update_bar(@GameID, array('title': 'Time Left - '.floor(@time[0]/60).':'.ceil(@time[0]%60), 'percent': @time[0]/600))
        }
        // Once 10 minutes passes, stop the loop and move over to the end game procedure.
        if(@time[0] == 0) {
            clear_task();
            _gameCloser(@GameID)
        }
        @time[0]--
    });

    console('Clock ID for game shutdown: '.@clock)

}

// The logic for giving items to a user. Checks for player's team, item's team, then assigns based on chance.
proc _giveItems(string @UUID, int @ArenaID, int @GameID) {
    @items = query('ZombieSQL', 'SELECT * FROM `arenaitems` WHERE ArenaID = ?', @ArenaID)
    @getplayer = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ?', @UUID)

    // Takes all items and compares them to the player's team. If a match is found, roll the chance and give the player the item if chance wins.
    if(@getplayer[0]['Team'] == 'HUMANS') {
        foreach(@item in @items) {
                if(@item['team'] == 'HUMANS') {
                    @chance = rand(1, 100)
                    msg(@chance)
                if(@chance <= @item['Chance']) {
                    pgive_item(@UUID, json_decode(@item['Item']))
                }
            } 
        }
    } else if(@getplayer[0]['Team'] == 'ZOMBIES') {
        foreach(@item in @items) {
            if(@item['team'] == 'ZOMBIES') {
                    @chance = rand(1, 100)
                    msg(@chance)
                if(@chance <= @item['Chance']) {
                    pgive_item(@UUID, json_decode(@item['Item']))
                }
            } 
        }
    }
}

// The logic for starting a round. Splits players across teams, hands out items, and spawns them.
proc _startRound(int @GameID) {
    @updatestatus = query('ZombieSQL', 'UPDATE `gameinstances` SET GameStatus = ? WHERE GameID = ?', 'in progress', @GameID)
    @getplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE GameID = ?', @GameID)

    // Finds the best divide of players based on the amount. Favours humans.
    @Humans = ceil(array_size(@getplayers)/2)
    @Zombies = array_size(@getplayers)-@Humans

    @teams = query('ZombieSQL', 'SELECT * FROM `gameinstances` JOIN `arenateams` ON `gameinstances`.ArenaID = `arenateams`.ArenaID WHERE GameID = ?', @GameID)
    @spawns = query('ZombieSQL', 'SELECT * FROM `arenaspawns` JOIN `gameinstances` ON `arenaspawns`.ArenaID = `gameinstances`.ArenaID WHERE GameID = ?', @GameID)
    @teamsarray = array()
    @humanspawns = array()
    @zombiespawns = array()
    @tospawnathuman = ''
    @tospawnatzombie = ''

    // Fills the teamsarray array with HUMANS and ZOMBIES
    for(@x = 0, @x < @Humans, @x++) {
        array_push(@teamsarray, 'HUMANS')
    }

    for(@x = 0, @x < @Zombies, @x++) {
        array_push(@teamsarray, 'ZOMBIES')
    }

    // Randomizes the order of teams in the array
    array_rand(@teamsarray, array_size(@teamsarray), false)

    // Grabs all spawns defined by the arena and saves them into specific arrays (Could make this a 2D array?)
    foreach(@spawn in @spawns) {
        if(@spawn['team'] == 'HUMANS') {
            array_push(@humanspawns, @spawn)
        } else if(@spawn['team'] == 'ZOMBIES') {
            array_push(@zombiespawns, @spawn)
        }
    }

    // Determines, from the list of human spawns, which is used for the round. As all humans only spawn once and all together, only one is needed.
    @tospawnathuman = array_rand(@humanspawns, 1, false)

    // Create a bossbar for time keeping.
    create_bar(@GameID, array('title': 'Time Left - 10:00', 'color': 'PURPLE', 'style': 'SEGMENTED_10'))

    // For every player, dependant on team, teleport them to their spawn, give them their items, and send them a beginning-of-round message (Will be customizable eventually).
    foreach(@player in @getplayers) {
        @addteamsql = query('ZombieSQL', 'UPDATE `gameplayers` SET Team = ? WHERE PlayerUUID = ?', @teamsarray[0], @player['PlayerUUID'])

        if(@teamsarray[0] == 'HUMANS') {
            set_ploc(@player['PlayerUUID'], array(@tospawnathuman[0]['X'], @tospawnathuman[0]['Y'], @tospawnathuman[0]['Z'],
            @tospawnathuman[0]['world'], @tospawnathuman[0]['pitch'], @tospawnathuman[0]['yaw']))
            _giveItems(@player['PlayerUUID'], @teams[0]['ArenaID'], @GameID)
            tmsg(@player['PlayerUUID'], colorize('&3'.player(@player['PlayerUUID']).' do you copy? We received your distress sign&kal&r&3. Near the town o&kf hfafusuifauif a&r&3nd will arrive in 10 minutes. Try to hol&kd out&r&3 until then.'))
        } else if(@teamsarray[0] == 'ZOMBIES') {
            @tospawnatzombie = array_rand(@zombiespawns, 1, false)
            set_ploc(@player['PlayerUUID'], array(@tospawnatzombie[0]['X'], @tospawnatzombie[0]['Y'], @tospawnatzombie[0]['Z'],
            @tospawnatzombie[0]['world'], @tospawnatzombie[0]['pitch'], @tospawnatzombie[0]['yaw']))
            _giveItems(@player['PlayerUUID'], @teams[0]['ArenaID'], @GameID)
            tmsg(@player['PlayerUUID'], colorize('&aYou are a zombie. Your goal is to kill any humans that have escaped the grasps of the virus thus far. You have 10 minutes...'))
        }

        bar_add_player(@GameID, @player['PlayerUUID'])
        array_remove(@teamsarray, 0)
    }

    _gameClock(@GameID, @teams[0]['ArenaID'])

    @teams = query('ZombieSQL', 'SELECT * FROM `gameinstances` JOIN `arenateams` ON `gameinstances`.ArenaID = `arenateams`.ArenaID WHERE GameID = ?', @GameID)
}


// Procedure for adding a player to the queue.
proc _addPlayerQueue(string @uuid) {
    @opengame = ''

    @getopengame = query('ZombieSQL', 'SELECT * from `gameinstances` WHERE `GameStatus` = ?', 'open')

    @playerexists = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ?', @uuid)
    // Checks if the player is already queued up for or is in a game.
    if(array_size(@playerexists) == 0) {
        // If there are no games waiting for players, make a new one.
        if(array_size(@getopengame) == 0) {
            _mgMessage('There were no open games. Creating a new one...')
            @newgame = query('ZombieSQL', 'INSERT INTO `gameinstances` (ArenaID, GameStatus) VALUES (?, ?)', 10, 'open')
        }
        // Add player to game, then wait for more players to connect. Once the playercount is reached, call the procedure to start the game.
        @getopengame = query('ZombieSQL', 'SELECT * from `gameinstances` WHERE `GameStatus` = ?', 'open')
        console(@getopengame[0])
            @addplayer = query('ZombieSQL', 'INSERT INTO `gameplayers` (GameID, PlayerUUID) VALUES (?, ?)', @getopengame[0]['GameID'], @uuid)
            console('Player '.@uuid.' has joined the queue for Zombies.')
            @getplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE GameID = ?', @getopengame[0]['GameID'])
            if(array_size(@getplayers) == 2) { // CHANGE TO THE MAX PLAYERS
                _startRound(@getopengame[0]['GameID'])
        }
    }
}

// TO BE REWRITTEN
// Pressure plates will currently act as the way to join a game. Plates can be defined with /nerdarena addplate [arena id] and,
// upon stepping on one, will have the player join the queue for that arena
bind(pressure_plate_activated, null, null, @event) {
    if((@event['location']['x'] == -67) && (@event['location']['y'] == 90) &&
    (@event['location']['z'] == 41) && (@event['location']['world'] == 'world') ) {
        _addPlayerQueue(puuid(@event['player']))
    }
}

// If the player leaves, remove them from the game 
// Need to add a rejoin event to physically warp them out on rejoin
bind(player_quit, null, null, @event) {
    if(array_size(query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ?', puuid(@event['player']))) >= 1) {
        @removeplayer = query('ZombieSQL', 'DELETE FROM `gameplayers` WHERE PlayerUUID = ?', puuid(@event['player']))
        console('Removed '.@event['player'].' from Zombies queue due to leaving')
    }
}

// Checks for inter-team combat and stops it
bind(entity_damage_player, null, null, @event) {
    @getplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ? OR PlayerUUID = ?', @event['id'], puuid(@event['player']))
    if(array_size(@getplayers) == 2) {
        if(@getplayers[0]['Team'] == @getplayers[1]['Team']) {
            cancel(true)
            return()
        }
    }
}

bind(player_spawn, null, null, @event) {
    @playerexists = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ?', puuid(@event['player']))
    @zombiespawns = query('ZombieSQL', 'SELECT * FROM `arenaspawns` JOIN `gameinstances` ON `arenaspawns`.ArenaID = `gameinstances`.ArenaID WHERE GameID = ?
    AND Team = ZOMBIES', @GameID)
// LOOK OVER, TEST, I DID THIS WITHOUT TESTING
    if(array_size(@playerexists) == 1) {
        @updateteam = query('ZombieSQL', 'UPDATE `gameplayers` SET Team = ZOMBIES WHERE PlayerUUID = ?', puuid(@event['player']))
        @tospawnatzombie = array_rand(@zombiespawns, 1, false)
        modify_event('location', @tospawnatzombie[0])
    }
}

