proc _sheepRespawn(string @message) {
    //spawn_entity('SHEEP', 1, array(x: 97, y: 103, z: 131, world: 'world'))
    run('/summon sheep 97 103 131 {Color:15,CustomName:''[{"text":"PUCK","bold":true,"color":"black"}]'',Health:1024,PersistenceRequired:1b,Silent:1b,Tags:["isPuck"],Attributes:[{Name:"generic.movement_speed",Base:0f},{Name:"generic.max_health",Base:20000f}]}')
    _mgMessage(@message)
    @puck = entities_in_radius(array(97, 103, 131,'world'), 10, 'SHEEP')
}