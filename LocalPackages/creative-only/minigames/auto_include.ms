proc _mgMessage(string @message) {
    msg(color('Gray')."[".color('Blue')."Minigames".color('Gray')."]".color('Gold')." ".@message)
}

proc _giveItems(string @UUID, int @ArenaID) {
    @items = query('ZombieSQL', 'SELECT * FROM `arenaitems` WHERE ArenaID = ?', @ArenaID)
}

proc _startRound(int @GameID) {
// Divvy up teams
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

    foreach(@player in @getplayers) {
        @addteamsql = query('ZombieSQL', 'UPDATE `gameplayers` SET Team = ? WHERE PlayerUUID = ?', @teamsarray[0], @player['PlayerUUID'])

        if(@teamsarray[0] == 'HUMANS') {
            set_ploc(@player['PlayerUUID'], array(@tospawnathuman[0]['X'], @tospawnathuman[0]['Y'], @tospawnathuman[0]['Z'],
            @tospawnathuman[0]['world'], @tospawnathuman[0]['pitch'], @tospawnathuman[0]['yaw']))
            msg(colorize('&3'.player(@player['PlayerUUID']).' do you copy? We received your distress sign&kal&r&3. Near the town o&kf hfafusuifauif a&r&3nd will arrive in 10 minutes. Try to hol&kd out&r&3 until then.'))
        } else if(@teamsarray[0] == 'ZOMBIES') {
            @tospawnatzombie = array_rand(@zombiespawns, 1, false)
            set_ploc(@player['PlayerUUID'], array(@tospawnatzombie[0]['X'], @tospawnatzombie[0]['Y'], @tospawnatzombie[0]['Z'],
            @tospawnatzombie[0]['world'], @tospawnatzombie[0]['pitch'], @tospawnatzombie[0]['yaw']))
        }

        array_remove(@teamsarray, 0)
    }

    @teams = query('ZombieSQL', 'SELECT * FROM `gameinstances` JOIN `arenateams` ON `gameinstances`.ArenaID = `arenateams`.ArenaID WHERE GameID = ?', @GameID)
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
            if(array_size(@getplayers) == 1) { // CHANGE TO THE MAX PLAYERS
                @updatestatus = query('ZombieSQL', 'UPDATE `gameinstances` SET GameStatus = ? WHERE GameID = ?', 'in progress', @getopengame[0]['GameID'])
                _startRound(@getopengame[0]['GameID'])
        }
    }
}

proc _getPlayers() {
    
}

bind(pressure_plate_activated, null, null, @event) {
    if((@event['location']['x'] == -67) && (@event['location']['y'] == 90) &&
    (@event['location']['z'] == 41) && (@event['location']['world'] == 'world') ) {
        _addPlayerQueue(puuid(@event['player']))
    }
}

bind(player_quit, null, null, @event) {
    @removeplayer = query('ZombieSQL', 'DELETE FROM `gameplayers` WHERE PlayerUUID = ?', puuid(@event['player']))
    console('Removed '.@event['player'].' from Zombies queue due to leaving')
}