var importants : Array<String>;
var crosses : Array<RoomNode>;

function buildMainRooms(){
    crosses = [];
    importants = [];

    Struct.createSpecificRoom("ClockTowerEntrance").setName("start")
            .chain(Struct.createSpecificExit("T_TopClockTower", "ClockTowerExit").setName("exit"));

    for( i in 0...3 ){
        crosses.push(Struct.createRoomWithType("Corridor").addBefore("exit"));
    }

    importants.push(addInBranch(Struct.createShop()));
    importants.push(addInBranch(Struct.createShop()));
    importants.push(addInBranch(Struct.createRoomWithType("Treasure")));
    importants.push(addInBranch(Struct.createRoomWithType("CellTreasure")));
    importants.push(addInBranch(Struct.createRoomWithType("CursedTreasure")));

    //Tower Key
    var exit = Struct.getRoomByName("exit");
    var deadEnds = Struct.allRooms.filter(function(_room) return _room.childrenCount == 0 && _room != exit);
    Struct.createSpecificRoom("CT_Key").addAfter(Random.arrayPick(deadEnds).getName());
}

function addInBranch(_roomToAdd : RoomNode) : RoomNode{
    var exit = Struct.getRoomByName("exit");
    var dh = new DecisionHelper(crosses);
    dh.score(function(_room) return Random.range(0, 2));
    dh.score(function(_room) return -_room.countChildren(function(_r) return !_r.isParentOf(exit)));
    var cross = dh.getBest();
    if( cross.childrenCount <= 1 ){
        cross.addChild(_roomToAdd);
    }
    else{
        var i = 0;
        while( i < cross.childrenCount ){
            var room = cross.getChild(i);
            if( room != exit && !room.isParentOf(exit) ){
                if( Random.isBelow(0.34) ){
                    _roomToAdd.addBefore(room.getName());
                }
                else{
                    _roomToAdd.addAfter(room.getName());
                }
                break;
            }
            i++;
        }
    }
    return _roomToAdd;
}

function buildSecondaryRooms(){
    var exit = Struct.getRoomByName("exit");
    var branchRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && !_room.isParentOf(exit));

    //Random elevators
    for( i in 0...2 ){
        var all = Struct.allRooms.filter(function(_room) return _room.parent != null && _room.isMainLevel() && _room.calcDistanceToCondition(function(_r) _r.isSpecificRoom("CT_VSpacer"), true) > 3);
        if( all.length > 0 ){
            Struct.createSpecificRoom("CT_VSpacer").addBefore(Random.arrayPick(all).getName());
        }
    }

    //Bell treasure
    var targets = Struct.allRooms.filter(function(_room) return _room.parent != null && _room.isMainLevel() && _room.spawnDistance >= 3);
    Struct.createSpecificRoom("CT_BellTreasure").addBefore(Random.arrayPick(targets).getName());

    //Main path Combat
    Struct.createAndAddRoomsBetween("Combat", "ClockTower", 3, "start", ["exit"], 0);

    //Force & combat before eacht important room
    for( room in importants ){
        Struct.createRoomWithTypeFromGroup("Combat", "ClockTower").addBefore(room.getName());
    }

    // + doors at the beginning of some branches
    var branchFirstRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room != exit && _room.parent != null && !_room.isParentOf(exit) && _room.parent.isParentOf(exit));
    for( i in 0...2 ){
        var room = Random.arraySplice(branchFirstRooms);
        var teleport = Struct.createSpecificRoom("CT_TeleportDoor").addBefore(room.getName());
        //Force 1 combat after each 
        Struct.createRoomWithTypeFromGroup("Combat", "ClockTower").addAfter(teleport.getName());
    }

    //Z doors
    var rooms = Struct.allRooms.filter(function(_room) _room.isMainLevel() && _room.spawnDistance > 2 && _room.type == "Combat" && _room.parent.type == "Combat");
    Struct.createRunicZDoor(Struct.createShop(), 1, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("CellTreasure"), 2, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("Treasure"), 3, rooms);
}

function buildTimedDoors(){
}

function finalize(){
    var exit = Struct.getRoomByName("exit");

    //Link s
    var s = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.type == "SubTeleport");
    for( room in s ){
        var targets = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.type == "Combat" && _room.isChildOf(room));
        var dh = new DecisionHelper(targets);
        dh.score(function(_room) return Random.range(0, 1));
        dh.score(function(_room)
                {
                    var distance = _room.spawnDistance - room.spawnDistance;
                    return distance >= 3 ? -10 : distance >= 2 ? 0 : 10;
                });
        room.setSubTeleport(dh.getBest());
    }

    //Add tower constraints
    for( room in Struct.allRooms ){
        if( room.childrenCount == 1 && room.parent != null ){
            room.firstChild.setConstraint(LinkConstraint.UpOnly);
        }
    }

    var corsses = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.childrenCount > 1);

    //One cross will force exit branch horizontalyOnly
    var room = Random.arraySplice(crosses);
    var upDone = false;
    { //Change scope so we don't have var i declared in the main scope
        var i = 0;
        while( i < room.childrenCount ){
            var child = room.getChild(i);
            if( child == exit || child.isParentOf(exit) ){
                child.setConstraint(LinkConstraint.HorizontalOnly);
            }
            else if( upDone ){
                child.setConstraint(LinkConstraint.HorizontalOnly);
            }
            else{
                child.setConstraint(LinkConstraint.UpOnly);
                upDone = true;
            }
            i++;
        }
    }

    //All other crosses have exit branch upOnly
    for( room in crosses ){
        var i = 0;
        while( i < room.childrenCount ){
            var child = room.getChild(i);
            if( child == exit || child.isParentOf(exit)) {
                child.setConstraint(LinkConstraint.UpOnly);
            }
            else{
                child.setConstraint(LinkConstraint.HorizontalOnly);
            }
            i++;
        }
    }

    var towerRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel());
    for( room in towerRooms.copy() ){
        //Add horizontal spacer corridors
        if( room.constraint == LinkConstraint.HorizontalOnly ){
            Struct.createRoomWithTypeFromGroup("Teleport", "ClockTowerSpacer").setConstraint(LinkConstraint.HorizontalOnly).addBefore(room.getName());
        }

        //Generation priority
        if( room.isParentOf(exit) ){
            room.setChildPriority(1);
        }

        //Teleporters
        if( room.childrenCount == 0 && room != exit ){
            Struct.createTeleportAfter(room);
        }

        if( room.parent != null && room.calcTypeDistance("Teleport", true) > 2 ){
            Struct.createTeleportBefore(room).setConstraint(LinkConstraint.UpOnly);
        }
    }

    //Start elevator
    Struct.createSpecificRoom("CT_VSpacer").addAfter("start");
}

function addTeleports(){
    // s are added at the end of finalize()
}		


function setLevelProps(_levelProps){
    setLevelPropsFrom("ClockTower", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("ClockTower", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("ClockTower", _mobList);
}