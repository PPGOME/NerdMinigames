proc _gameCloser(int @GameID, int @clock) {
    @updatestatus = query('ZombieSQL', 'UPDATE `gameinstances` SET GameStatus = ? WHERE GameID = ?', 'done', @GameID)
    @wipeplayers = query('ZombieSQL', 'DELETE FROM `gameplayers` WHERE GameID = ?', @GameID)
    remove_bar(@GameID)
    clear_task(@clock)
}

// Handles the minigame's clock
proc _gameClock(int @GameID, int @ArenaID) {
    @time = array(600);
    @effectsandplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` JOIN `gameinstances` ON `gameplayers`.GameID = `gameinstances`.GameID JOIN `arenaeffects`
    ON `gameinstances`.ArenaID = `arenaeffects`.ArenaID WHERE `gameplayers`.GameID = ?', @GameID)

    msg(@effectsandplayers)

    @clock = set_interval(1000, closure() {
        foreach(@event in @effectsandplayers) {
            msg(@time[0])
            if(@event['Team'] == @event['EffectTeam']) {
                if(@event['StartTime'] == @time[0]) {
                    msg('START')
                    set_peffect(@event['PlayerUUID'], @event['Effect'], @event['Potency'] - 1, 99999, true, false)
                } else if(@event['EndTime'] == @time[0]) {
                    msg('END')
                    set_peffect(@event['PlayerUUID'], @event['Effect'], @event['Potency'] - 1, 0, true, false)
                }
            }
        }
        if(ceil(@time[0]%60) < 10) {
            update_bar(@GameID, array('title': 'Time Left - '.floor(@time[0]/60).':0'.ceil(@time[0]%60), 'percent': @time[0]/600))
        } else {
            update_bar(@GameID, array('title': 'Time Left - '.floor(@time[0]/60).':'.ceil(@time[0]%60), 'percent': @time[0]/600))
        }
        if(@time[0] == 0) {
            clear_task();
            remove_bar(@GameID)
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
    console('aa')
    @getplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE GameID = ?', @GameID)
    @Humans = ceil(array_size(@getplayers)/2)
    @Zombies = array_size(@getplayers)-@Humans
    @teams = query('ZombieSQL', 'SELECT * FROM `gameinstances` JOIN `arenateams` ON `gameinstances`.ArenaID = `arenateams`.ArenaID WHERE GameID = ?', @GameID)
    @spawns = query('ZombieSQL', 'SELECT * FROM `arenaspawns` JOIN `gameinstances` ON `arenaspawns`.ArenaID = `gameinstances`.ArenaID WHERE GameID = ?', @GameID)
    @teamsarray = array()
    @humanspawns = array()
    @zombiespawns = array()
    @tospawnathuman = ''
    @tospawnatzombie = ''

    for(@x = 0, @x < @Humans, @x++) {
        array_push(@teamsarray, 'HUMANS')
    }

    for(@x = 0, @x < @Zombies, @x++) {
        array_push(@teamsarray, 'ZOMBIES')
    }

    array_rand(@teamsarray, array_size(@teamsarray), false)

    foreach(@spawn in @spawns) {
        if(@spawn['team'] == 'HUMANS') {
            array_push(@humanspawns, @spawn)
        } else if(@spawn['team'] == 'ZOMBIES') {
            array_push(@zombiespawns, @spawn)
        }
    }

    @tospawnathuman = array_rand(@humanspawns, 1, false)

    msg(@spawns)
    msg(@humanspawns)

    create_bar(@GameID, array('title': 'Time Left - 10:00', 'color': 'PURPLE', 'style': 'SEGMENTED_10'))

    foreach(@player in @getplayers) {
        @addteamsql = query('ZombieSQL', 'UPDATE `gameplayers` SET Team = ? WHERE PlayerUUID = ?', @teamsarray[0], @player['PlayerUUID'])

        if(@teamsarray[0] == 'HUMANS') {
            set_ploc(@player['PlayerUUID'], array(@tospawnathuman[0]['X'], @tospawnathuman[0]['Y'], @tospawnathuman[0]['Z'],
            @tospawnathuman[0]['world'], @tospawnathuman[0]['pitch'], @tospawnathuman[0]['yaw']))
            _giveItems(@player['PlayerUUID'], @teams[0]['ArenaID'], @GameID)
            msg(colorize('&3'.player(@player['PlayerUUID']).' do you copy? We received your distress sign&kal&r&3. Near the town o&kf hfafusuifauif a&r&3nd will arrive in 10 minutes. Try to hol&kd out&r&3 until then.'))
        } else if(@teamsarray[0] == 'ZOMBIES') {
            @tospawnatzombie = array_rand(@zombiespawns, 1, false)
            set_ploc(@player['PlayerUUID'], array(@tospawnatzombie[0]['X'], @tospawnatzombie[0]['Y'], @tospawnatzombie[0]['Z'],
            @tospawnatzombie[0]['world'], @tospawnatzombie[0]['pitch'], @tospawnatzombie[0]['yaw']))
            _giveItems(@player['PlayerUUID'], @teams[0]['ArenaID'], @GameID)
        }

        bar_add_player(@GameID, @player['PlayerUUID'])
        array_remove(@teamsarray, 0)
    }

    _gameClock(@GameID, @teams[0]['ArenaID'])

    @teams = query('ZombieSQL', 'SELECT * FROM `gameinstances` JOIN `arenateams` ON `gameinstances`.ArenaID = `arenateams`.ArenaID WHERE GameID = ?', @GameID)
}

proc _initiateStart(int @GameID) {
    @updatestatus = query('ZombieSQL', 'UPDATE `gameinstances` SET GameStatus = ? WHERE GameID = ?', 'in progress', @GameID)
    _startRound(@GameID)
}


// Procedure for adding a player to the queue
proc _addPlayerQueue(string @uuid) {
    @opengame = ''

    @getopengame = query('ZombieSQL', 'SELECT * from `gameinstances` WHERE `GameStatus` = ?', 'open')

    @playerexists = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ?', @uuid)
    if(array_size(@playerexists) == 0) {
        if(array_size(@getopengame) == 0) {
            _mgMessage('There were no open games. Creating a new one...')
            @newgame = query('ZombieSQL', 'INSERT INTO `gameinstances` (ArenaID, GameStatus) VALUES (?, ?)', 10, 'open')
        }
        @getopengame = query('ZombieSQL', 'SELECT * from `gameinstances` WHERE `GameStatus` = ?', 'open')
        console(@getopengame[0])
            @addplayer = query('ZombieSQL', 'INSERT INTO `gameplayers` (GameID, PlayerUUID) VALUES (?, ?)', @getopengame[0]['GameID'], @uuid)
            console('Player '.@uuid.' has joined the queue for Zombies.')
            @getplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE GameID = ?', @getopengame[0]['GameID'])
            if(array_size(@getplayers) == 2) { // CHANGE TO THE MAX PLAYERS
                _initiateStart(@getopengame[0]['GameID'])
        }
    }
}

bind(pressure_plate_activated, null, null, @event) {
    if((@event['location']['x'] == -67) && (@event['location']['y'] == 90) &&
    (@event['location']['z'] == 41) && (@event['location']['world'] == 'world') ) {
        _addPlayerQueue(puuid(@event['player']))
    }
}

bind(player_quit, null, null, @event) {
    if(array_size(query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ?', puuid(@event['player']))) >= 1) {
        @removeplayer = query('ZombieSQL', 'DELETE FROM `gameplayers` WHERE PlayerUUID = ?', puuid(@event['player']))
        console('Removed '.@event['player'].' from Zombies queue due to leaving')
    }
}

bind(player_death, null, null, @event) {
    msg('ded lol')
}

bind(entity_damage_player, null, null, @event) {
    msg(@event['damager'].', '.@event['id'].', '.puuid(@event['player']))
    @getplayers = query('ZombieSQL', 'SELECT * FROM `gameplayers` WHERE PlayerUUID = ? OR PlayerUUID = ?', @event['id'], puuid(@event['player']))
    if(array_size(@getplayers) == 2) {
        if(@getplayers[0]['Team'] == @getplayers[1]['Team']) {
            cancel(true)
            return()
        }
    }
}

