var numHallway : Int;
var branches : Array<String>;
var zDoors : Array<RoomNode>;
var zBosses : Array<RoomNode>;
var hallwayBiome : Array<String>;

function buildMainRooms(){
    zDoors = [];
    zBosses = [];

    Struct.createSpecificRoom("CastleEntrance").setName("start").forceBiome("Castle")
            .chain( Struct.createSpecificExit("T_Throne", "CastleExit").setName("end"));
    
    hallwayBiome = ["CastleVegan", "CastleTorture", "CastleAlchemy"];
    numHallway = hallwayBiome.length;
    shuffleArray(hallwayBiome);

    branches = ["end"];

    Struct.createRoomWithType("BuyableCells").addBetweenMultipleEnds("start", branches, 0);
    var types = [MerchantType.Actives, MerchantType.Weapons, MerchantType.Talismans];
    Struct.createShop(Random.arraySplice(types)).addBetweenMultipleEnds("start", branches, 0);
    var room = Struct.createShop(Random.arraySplice(types)).branchBetweenMultipleEnds("start", branches, 0);
    branches.push(room.getName());

    room = Struct.createRoomWithType("Treasure").branchBetweenMultipleEnds("start", branches, 0);
    branches.push(room.getName());
    Struct.createRoomWithType("WallJumpGate").addBefore(room.getName());

    room = Struct.createRoomWithType("Treasure").branchBetweenMultipleEnds("start", branches, 0);
    branches.push(room.getName());
    Struct.createRoomWithType("BreakableGroundGate").addBefore(room.getName());

    //create z-hallways
    var targets = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && !_room.hasParentMetaGate(false));
    for( i in 0...numHallway ){
        //Z entrance
        var to = Random.arraySplice(targets);
        var startRoom = Struct.createSpecificRoom("CastleZDoorRoom").setName("entrance" + i);
        zDoors.push(startRoom);
        if( Random.isBelow(0.66) ){
            startRoom.addBefore(to.getName());
        }
        else{
            var corridor = Struct.createRoomWithType("Corridor").addBefore(to.getName());
            corridor.addChild(startRoom);
        }

        //Z exit
        to = Random.arraySplice(targets);
        var endRoom = Struct.createSpecificRoom("CastleZDoorRoom").setName("exit" + i);
        zDoors.push(endRoom);
        if( Random.isBelow(0.66) ){
            endRoom.addBefore(to.getName());
        }
        else{
            var corridor = Struct.createRoomWithType("Corridor").addBefore(to.getName());
            corridor.addChild(endRoom);
        }

        //Z content
        if( Random.isBelow(0.5) ){
            createHallway(startRoom, endRoom);
        }
        else{
            createHallway(endRoom, startRoom);
        }
    }
}

function createHallway(_entrance : RoomNode, _exit : RoomNode){
    //Add base structure
    var start = Struct.createSpecificRoom("CastleZDoorRoom");
    start.setAsZRoot();
    var end = Struct.createSpecificRoom("CastleZDoorRoom");
    end.addAfter(start.getName());
    _entrance.addZChild(start);
    _exit.addZLink(end.getName());

    //pick biome
    var biome = hallwayBiome.shift();
    hallwayBiome.push(biome);
    start.forceCastleBiome(biome);

    //add mini boss
    switch( biome ){
        case "CastleVegan":
            var room = Struct.createSpecificRoom("CastleLandmarkVegan").addBetween(start.getName(), end.getName());
            zBosses.push(room);
        case "CastleTorture":
            var room = Struct.createSpecificRoom("CastleLandmarkTorture").addBetween(start.getName(), end.getName());
            zBosses.push(room);
        case "CastleAlchemy":
            var room = Struct.createSpecificRoom("CastleLandmarkAlchemy").addBetween(start.getName(), end.getName());
            zBosses.push(room);
    }

    Struct.createTeleportAfter(start);
    Struct.createTeleportBefore(end);
}

function buildSecondaryRooms(){
    //Main comabts between each zDoors
    for( room in zDoors){
        Struct.createRoomWithTypeFromGroup("Combat", "Castle").addBefore(room.getName());
    }

    //Combats in hallways
    for( room in zBosses ){
        Struct.createRoomWithTypeFromGroup("Combat", "Castle").addBefore(room.getName());
        if( Random.isBelow(0.75) ){
            Struct.createRoomWithTypeFromGroup("Combat", "Castle").addAfter(room.getName());
        }
        else{
            Struct.createRoomWithTypeFromGroup("Combat", "Castle").addBefore(room.getName());
        }
    }
}

function buildTimedDoors(){
}

function finalize(){
    //Secret reward for courtyard keys quest
    var targets = Struct.allRooms.filter(function(_room) return _room.parent != null && _room.isMainLevel() && _room.spawnDistance >= 4);
    Struct.createSpecificRoom("RoseKeyReward").addBefore(Random.arrayPick(targets).getName());
    Struct.createSpecificRoom("CastleExitLoot").addAfter("end");
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("Castle", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("Castle", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("Castle", _mobList);
}