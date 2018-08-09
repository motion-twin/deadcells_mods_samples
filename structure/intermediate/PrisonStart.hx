function buildMainRooms(){
    //The flask room is a special room that cannot be used in script as an entrance as there
    //is no door in it. So we just create a random entrance
    Struct.createRoomWithType("Entrance").setName("start")
        .chain(Struct.createCross("exitCross"))
        .chain(Struct.createSpecificExit("T_Courtyard", "PrisonStartExit").setName("eCourt"));

    Struct.getRoomByName("exitCross")
        .chain(Struct.createRoomWithType("LadderGate").setName("gSewer"))
        .chain(Struct.createExit("T_SewerShort").setName("eSewer"));

    Struct.createRoomWithType("Treasure").branchOrAddBetween("start", ["eCourt", "gSewer"], 2);
    Struct.createRoomWithType("Shop").branchOrAddBetween("exitCross", ["eCourt"], 0);  

    if( Random.isBelow(0.7) ){
        Struct.createRoomWithType("BuyableTreasure").branchOrAddBetween("exitCross", ["eCourt"], 0);
    }  

    if( Random.isBelow(0.2) ){
        Struct.createRoomWithType("BuyableTreasure").branchOrAddBetween("start", ["eCourt"], 0);
    }

    if( Random.isBelow(0.05) ){
        Struct.createRoomWithType("Treasure").branchOrAddBetween("start", ["eCourt", "eSewer"], 3);
    }

    if( Random.isBelow(0.35) ){
        Struct.createRoomWithType("BuyableTreasure").branchOrAddBetween("start", ["eCourt", "eSewer"], 3);
    }

    if( Meta.isItemUnlocked("PokebombUnlock") ){
        Struct.createSpecificRoom("Pokeball").branchBetweenMultipleEnds("start", ["eCourt", "eSewer"], 1);
    }
}

function buildSecondaryRooms(){
    Struct.createAndAddRoomsBetween("Combat", "Prison", 1, "start", ["exitCross"], 0);
    if( Random.isBelow(0.4) ){
        Struct.createAndAddRoomsBetween("Combat", "NeedTeleport", 1, "exitCross", ["eCourt", "gSewer"], 0);
    }
    else{
        Struct.createAndAddRoomsBetween("Combat", "Prison", 1, "start", ["exitCross"], 0);
    }
    
    Struct.createAndAddRoomsBetween("Combat", "Prison", 1, "start", ["eCourt"], 0);

    if( Random.isBelow(0.6) ){
        Struct.createAndAddRoomsBetween("Combat", "NeedLadder", 1, "exitCross", ["eCourt", "gSewer"], 0);
    }

    Struct.createAndAddRoomsBetween("Combat", "Prison", 1, "exitCross", ["eCourt"], 0);
    Struct.createAndAddRoomsBetween("Combat", "Prison", 1, "exitCross", ["eCourt", "gSewer"], 0);
    Struct.createRoomWithTypeFromGroup("Combat", "Prison").addBefore("eSewer");
}

function buildTriggeredDoors(_allCombatRooms : Array){
    if( _allCombatRooms.length > 0 && Random.isBelow(1.1) ){
        Random.arrayPick(_allCombatRooms).setGroup("TriggeredDoor");
    }
}

function addTeleports(){
    callDefaultAddTeleport();

    var targets = Struct.allRooms.filter(function(_room) return _room.parent != null && _room.isMainLevel());
    for( room in targets ){
        if( room.calcTypeDistance("Teleport", true) > 1 ){
            Struct.createTeleportBefore(room);
        }
    }
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("PrisonStart", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("PrisonStart", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("PrisonStart", _mobList);
}