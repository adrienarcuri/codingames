import 'dart:io';

/// Debug the game
debug(Object o) => stderr.writeln(o);

/// Player
class Player {
  /// Id of the player
  int id;

  /// The score of the player
  int score;

  /// Remaining number of turns until the radar is available at the QG
  int radarCooldown;

  /// Remaining number of turns until the EMP trap is available at the QG
  int trapCooldown;

  @override
  String toString() {
    final List<String> s = [
      'Player:',
      'id: $id',
      'score: $score',
      'radarCooldown: $radarCooldown',
      'trapCooldown: $trapCooldown'
    ];
    return debug(s.join(' '));
  }
}

/// Game zone
class GameZone {
  static const height = 15;
  static const width = 30;

  /// Represents all cases on the game zone
  ///
  /// Example: cases['2,4'] represents the case at x=2 and y=4
  Map<String, Case> cases;

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

/// Generic Entity
abstract class Entity {
  int id;
  int type;

  /// Horizontal position
  int x;

  /// Vertical position
  int y;
}

/// Robot
class Robot extends Entity with RobotCommands {
  /// Return true if the robot is destroyed
  bool get isDestroyed => x == -1 && y == -1;

  /// Return true if the robot is empty
  bool get isEmpty => item == -1;

  /// Return true if the robot has a radar
  bool get hasRadar => item == 2;

  /// Return true if the robot has a trap
  bool get hasTrap => item == 3;

  /// Return true if the robot has a crystal
  bool get hasCrystal => item == 4;

  /// Object in the robot inventory
  ///
  /// -1 if empty
  ///
  /// 2 if radar
  ///
  /// 3 if EMP trap
  ///
  /// 4 if crystal
  int item;
}

class RobotCommands {
  /// The robot do nothing
  void wait() {
    _printCommand('WAIT');
  }

  /// Move the robot of 4 cases to the case (x,y)
  void move(int x, int y) {
    _printCommand('MOVE $x $y');
  }

  /// The robot dig
  void dig(int x, y) {
    _printCommand('DIG $x $y');
  }

  /// The robot try to get an [item] from the QG
  void request(String item) {
    if (!(item == 'RADAR' || item == 'TRAP')) {
      item = 'RADAR';
    }
    _printCommand('REQUEST $item');
  }

  /// Print a command as string [s]
  static void _printCommand(String s) {
    print(s);
  }
}

/// Position
abstract class Position {
  /// Horizontal position
  int x;

  /// Vertical position
  int y;

  /// Compute the distance between positions ([this.x],[this.y]) and ([x],[y])
  distance(int, int y) {
    (this.x - x).abs() + (this.y - y).abs();
  }
}

/// Case
class Case extends Position {
  /// Cristal quantity on the case (>=0)
  ///
  /// If the case is not detectable, return -1
  int nCristal;

  /// Return true if there is a hole, else return false
  bool hole;
}

/**
 * Deliver more ore to hq (left side of the map) than your opponent. Use radars to find ore but beware of traps!
 **/
void main() {
  List inputs;
  inputs = stdin.readLineSync().split(' ');
  int width = int.parse(inputs[0]);
  int height = int.parse(inputs[1]); // size of the map

  // game loop
  while (true) {
    inputs = stdin.readLineSync().split(' ');
    int myScore = int.parse(inputs[0]); // Amount of ore delivered
    int opponentScore = int.parse(inputs[1]);
    for (int i = 0; i < height; i++) {
      inputs = stdin.readLineSync().split(' ');
      for (int j = 0; j < width; j++) {
        String ore = inputs[2 * j]; // amount of ore or "?" if unknown
        int hole = int.parse(inputs[2 * j + 1]); // 1 if cell has a hole
      }
    }
    inputs = stdin.readLineSync().split(' ');
    int entityCount = int.parse(inputs[0]); // number of entities visible to you
    int radarCooldown =
        int.parse(inputs[1]); // turns left until a new radar can be requested
    int trapCooldown =
        int.parse(inputs[2]); // turns left until a new trap can be requested
    for (int i = 0; i < entityCount; i++) {
      inputs = stdin.readLineSync().split(' ');
      int entityId = int.parse(inputs[0]); // unique id of the entity
      int entityType = int.parse(inputs[
          1]); // 0 for your robot, 1 for other robot, 2 for radar, 3 for trap
      int x = int.parse(inputs[2]);
      int y = int.parse(inputs[3]); // position of the entity
      int item = int.parse(inputs[
          4]); // if this entity is a robot, the item it is carrying (-1 for NONE, 2 for RADAR, 3 for TRAP, 4 for ORE)
    }
    for (int i = 0; i < 5; i++) {
      // Write an action using print()
      // To debug: stderr.writeln('Debug messages...');

      print('WAIT'); // WAIT|MOVE x y|DIG x y|REQUEST item
    }
  }
}
