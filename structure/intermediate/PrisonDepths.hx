var branches : Array<String>;
var bonusExists : Bool;
function buildMainRooms(){
    Struct.createSpecificRoom("PrisonDepthsEntrance").setName("start")
            .chain(Struct.createRoomWithType("Combat").setName("first"))
            .chain(Struct.createExit("T_OssuaryAfterPrison").setName("exit"));

    branches = ["exit"];

    Struct.createShopWithType(MerchantType.Weapons).setName("shop1").branchBetweenMultipleEnds("first", branches, 0);
    Struct.createRoomWithType("WallJumpGate").addBefore("shop1");

    branches.push(Struct.createRoomWithType("DualTreasure").branchBetweenMultipleEnds("first", branches, 0).getName());
    branches.push(Struct.createShopWithType(MerchantType.Actives).setName("shop2").branchBetweenMultipleEnds("first", branches).getName());

    if( Random.isBelow(0.5) ){
        Struct.createRoomWithType("CursedTreasure").branchBetweenMultipleEnds("start", branches, 1);
    }

    bonusExists = false;
    if( Random.isBelow(0.5) ){
        Struct.createRooomWithType("WallJumpGate").branchBetweenMultipleEnds("first", branches, 0)
            .chain(Struct.createRoomWithType("BuyableCells").setName("bonus"));
        bonusExists = true;
    }

    Struct.createRoomWithType("BuyableCells").addBetweenMultipleEnds("first", branches, 0);
}

function buildSecondaryRooms(){
    //Main combats
    Struct.createAndAddRoomsBetween("Combat", "", 2, "first", ["exit"], 0);

    //branch combats
    var exit = Struct.getRoomByName("exit");
    var rooms = Struct.allRooms.filter(function(_room) return _room != exit && !_room.isParentOf(exit) );
    for( i in 0...2 ){
        Struct.createRoomWithType("Combat").addBefore(Random.arrayPick(rooms).getName());
    }

    //Misc Combats
    if( bonusExists ){
        Struct.createRoomWithType("Combat").addBefore("bonus");
    }
    Struct.createAndAddRoomsBetween("Combat", "NeedWallJump", 1, "first", ["exit"], 0);
    Struct.createAndAddRoomsBetween("Combat", "NeedStomp", 1, "first", ["exit"], 0);

    //Traps
    Struct.createAndAddRoomsBetween("Trap_1", "CommonTraps", 1, "first", branches, 0);
    Struct.createAndAddRoomsBetween("Trap_2", "CommonTraps", 2, "first", branches, 0);

    //Minor secrets
    Struct.createAndAddRoomsBetween("Combat", "MinorSecret", 1, "first", ["exit"], 0);

    //Z doors
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.spawnDistance > 2 && _room.parent != null);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("Treasure"), 2, 1, rooms);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("CursedTreasure"), 3, 0, rooms);

}

function buildTriggeredDoors(_allCombatRooms : Array){
    if( _allCombatRooms.length > 0 ){
        Random.arrayPick(_allCombatRooms).setGroup("TriggeredDoor");
    }
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("PrisonDepths", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("PrisonDepths", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("PrisonDepths", _mobList);
}