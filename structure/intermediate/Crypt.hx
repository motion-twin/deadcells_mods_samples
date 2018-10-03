var branches : Array<String>;
var keyCrosses : Array<RoomNode>;
function buildMainRooms(){
    Struct.createRoomWithTypeFromGroup("Entrance", "Crypts").setName("start")
            .chain(Struct.createExit("T_TopClockTower").setName("exit"));

    branches = ["exit"];
    branches.push(Struct.createRoomWithType("DualTreasure").addBetween("start", "exit", 0).getName());
    branches.push(Struct.createRoomWithType("DualTreasure").branchBetween("start", "exit", 0).getName());
    branches.push(Struct.createShop().branchBetweenMultipleEnds("start", branches, 0).getName());
    branches.push(Struct.createRoomWithType("BuyableCells").branchBetweenMultipleEnds("start", branches, 0).getName());

    Struct.createRoomWithType("BreakableGroundGate").branchBetween("start", "exit", 0).chain(Struct.createRoomWithType("BuyableCells"));
    Struct.createRoomWithType("WallJumpGate").branchBetween("start", "exit", 0).chain(Struct.createShop());

    //Keys
    var start = Struct.getRoomByName("start");
    var exit = Struct.getRoomByName("exit");
    keyCrosses = [];
    for( i in 0...2 ){
        var dh = new DecisionHelper(Struct.allRooms);
        dh.remove(function(_room) return _room.parent == null || _room.childrenCount == 0 );
        dh.score(function(_room) return _room.calcDistanceToCondition(function(_r) return _r.type == "Entrance" || _r.type == "Exit" || _r.type == "Special", true));
        var room = dh.getBest();
        if( room == null ){
            throw "Cannot place key " + (i + 1);
        }

        var cross = Struct.createRoomWithType("Corridor").addBefore(room.getName());
        var keyRoom = Struct.createRoomWithTypeFromGroup("Special", "CryptKey").setName("key" + (i + 1));
        branches.push(keyRoom.getName());
        cross.addChild(keyRoom);
        keyCrosses.push(keyRoom.searchParent(function(_room) return _room.isParentOf(exit)));
    }

    //End door
    Struct.createSpecificRoom("CryptEndDoor").addBefore("exit");
}

function buildSecondaryRooms(){
    var exit = Struct.getRoomByName("exit");

    //Combat with loots
    if( Random.isBelow(0.5) ){
        Struct.createAndAddRoomsBetween("Combat", "NeedStomp", 1, "start", branches, 0);
    }
    else{
        Struct.createAndAddRoomsBetween("Combat", "NeedWallJump", 1, "start", branches, 0);
    }

    //Traps
    Struct.createAndAddRoomsBetween("Trap_2", "CommonTraps", 2, "start", branches, 0);

    Struct.createRoomWithType("Combat").addBefore("key1");
    Struct.createRoomWithType("Combat").addBefore("key2");

    //Branch combats
    var branchRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room != exit && !_room.isParentOf(exit));
    for( i in 0...1 ){
        Struct.createRoomWithType("Combat").addBefore(Random.arrayPick(branchRooms).getName());
    }

    //Main combats
    Struct.createAndAddRoomsBetween("Combat", "Crypts", 2, "start", ["exit"], 0);

    //Minor secrets
    Struct.createAndAddRoomsBetween("Combat", "MinorSecret", 1, "start", ["exit"], 0);
    if( Random.isBelow(0.1) ){
        Struct.createAndAddRoomsBetween("Combat", "MinorSecret", 1, "start", ["exit"], 0);
    }

    //Z doors
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.spawnDistance > 2 && _room.parent != null );
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("CursedTreasure"), 1, 0, rooms);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("DualTreasure"), 2, 0, rooms);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("CursedTreasure"), 3, 1, rooms);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("DualTreasure"), 4, 1, rooms);

    //Secret Courtyard key converter
    var secretRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.spawnDistance >= 4);
    Struct.createSpecificRoom("RoseKeyConverter").addBefore(Random.arrayPick(secretRooms).getName());
}

function buildTimedDoors(){
    var dh = new DecisionHelper(Struct.allRooms);
    dh.remove(function(_room) return !_room.isMainLevel() || _room.parent == null);
    dh.score(function(_room) return _room.spawnDistance <= 1 ? 10 : _room.spawnDistance <= 3 ? 5 : 0);
    dh.score(function(_room) return -_room.spawnDistance * 0.5);
    dh.score(function(_room) return Random.irange(0, 2));

    Struct.createTimedBranchBefore(dh.getBest());
}

function finalize(){
    //Add extra teleport gates
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.childrenCount > 0 && _room.type != "TimedDoor" && !_room.hasParentType("TimedDoor"));
    for( i in 0...5 ){
        if( rooms.length == 0 ){
            break;
        }
        Struct.createRoomWithType("TeleportGate").addBefore(Random.arraySplice(rooms).getName());
    }

    //Mid door
    keyCrosses.sort(function(a, b) return compare(a.spawnDistance, b.spawnDistance));
    var room = Struct.getRoomByName("exit").searchParent(
        function(_room)
        { 
            return _room.parent == keyCrosses[0];
        });
    var door = Struct.createSpecificRoom("CryptMidDoor").addBefore(room.getName());

    //Boss
    var exit = Struct.getRoomByName("exit");
    var cross = exit.parent.childrenCount == 1 && (exit.parent.type == "Corridor" || exit.parent.type == "Teleport") ? exit.parent : Struct.createRoomWithType("Corridor").addBefore("exit");
    var boss = Struct.createSpecificRoom("CryptBoss");
    cross.addChild(boss);
    Struct.createTeleportAfter(boss);
}

function addTeleports(){
    //Dead ends
    for( room in Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.childrenCount == 0) ){
        if( room.calcTypeDistance("Teleport", false) > 1 ){
            Struct.createTeleportBefore(room);
        }
    }

    //Turn Crosses into teleports
    for( room in Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.type == "Corridor")){
        if( room.calcTypeDistance("Teleport", false) > 1 ){
            room.setType("Teleport");
        }
    }

    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel());
    rooms.sort(function(a, b) return compare(a.spwanDistance, b.spawnDistance));
    for( room in rooms ){
        if( room.calcTypeDistance("Teleport", true) <= 2 ){
            continue;
        }
        Struct.createTeleportBefore(room);
    }
}		


function setLevelProps(_levelProps){
    setLevelPropsFrom("Crypt", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("Crypt", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("Crypt", _mobList);
}