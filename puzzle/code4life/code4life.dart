/// TODO
// [ ] Better allocate SAMPLES rank
// [ ] Store files in the cloud if we cannot produce it
import 'dart:io';

import 'dart:math';

/// ENUMS
enum MoleculeType { A, B, C, D, E }

enum ModuleType { DIAGNOSIS, MOLECULES, LABORATORY, SAMPLES, CENTER }

/// Represents the immutable state of the Robot:
///
/// MOVING : the robot is moving from one Module to another
///
/// CHOOSE: the robot is Choosing a file at the SAMPLES Module
///
/// ANALYSE: the robot is Analysing file at the DIAGNOSIS Module
///
/// COLLECT: the robot is Collecting molecules at the MOLECULES Module
///
/// PRODUCE: the robot is Producing medecines at the LABORATOEY Module
///
/// STORE: the robot is storing files on the cloud (because he cannot handle them)
enum StateType {
  MOVING,
  CHOOSE,
  ANALYSE,
  COLLECT,
  PRODUCE,
  STORE,
  UNDEFINED,
}

/// DEBUG
void debug(e) => stderr.writeln(e);

/// UTILS
class Util {
  static File chooseFile(List<File> files) {
    var _files = [...files];

    // Retains only files in the cloud
    _files.retainWhere((element) => element.carriedBy == 0);
    // Sort files by gain
    _files.sort((f1, f2) => f1.ratio.compareTo(f2.ratio));
    // Choose the file with the maximal gain

    return _files.last;
  }

  static List<File> playerCarriedFiles(List<File> files, [int playerId = 0]) {
    var _files = [...files];
    _files.retainWhere((element) => element.carriedBy == playerId);
    return _files;
  }

  static toShortString(dynamic T) {
    return T.toString().split('.').last;
  }

  static ModuleType toModuleType(String s) {
    if (s == Util.toShortString(ModuleType.DIAGNOSIS)) {
      return ModuleType.DIAGNOSIS;
    }
    if (s == Util.toShortString(ModuleType.LABORATORY)) {
      return ModuleType.LABORATORY;
    }
    if (s == Util.toShortString(ModuleType.MOLECULES)) {
      return ModuleType.MOLECULES;
    }
    if (s == Util.toShortString(ModuleType.SAMPLES)) {
      return ModuleType.SAMPLES;
    }
    throw (Exception(
        'The module $s is not a valid module type. Should be one of: ${ModuleType.values.map(Util.toShortString)}'));
  }

  static MoleculeType toMoleculeType(String s) {
    if (s == Util.toShortString(MoleculeType.A)) {
      return MoleculeType.A;
    }
    if (s == Util.toShortString(MoleculeType.B)) {
      return MoleculeType.B;
    }
    if (s == Util.toShortString(MoleculeType.C)) {
      return MoleculeType.C;
    }
    if (s == Util.toShortString(MoleculeType.D)) {
      return MoleculeType.D;
    }
    if (s == Util.toShortString(MoleculeType.E)) {
      return MoleculeType.E;
    }
    if (s == '0') {
      return MoleculeType.A;
    }
    throw (Exception(
        'The molecule $s is not a valid molecule type. Should be one of: ${MoleculeType.values.map(Util.toShortString)}'));
  }

  static String displayMap(Map<MoleculeType, int> map) {
    var map2 = {};
    map.entries.forEach((entry) {
      map2[Util.toShortString(entry.key)] = entry.value;
    });
    return map2.toString();
  }
}

/// PLAYER
class Player {
  Player({
    this.id,
    this.score,
    this.robot,
    this.expertises,
  });

  /// Player id, 0 = me, 1 = ennemy
  int id;

  /// Score of the player
  int score;

  /// Expertise of the player for each molecule type
  /// Example : expertises[A]=2
  Map<MoleculeType, int> expertises;

  /// Robot of the player
  Robot robot;

  /// Return the sum of all expertises
  int getTotalExpertise() {
    int total = expertises.values.reduce((a, b) => a + b);

    return total;
  }

  /// Return true if each expertise type is greater than [min]
  bool isEachExpertiseGreaterOrEqualThan(int min) {
    return expertises.values.every((e) => e >= min);
  }

  /// Choose a file by which we will collect molecules for
  File chooseAfileToCollect() {
    var _files = [...robot.files];
    _files.retainWhere(_willBeAbleToCollectAllMoleculesForAFile);

    if (_files.isEmpty) {
      return null;
    }

    final file = _getFileWithTheMoreHelpfulExpertise(_files);
    return file;
  }

  /// Get the file which have the gain that will help to produce other molecules fastly
  File _getFileWithTheMoreHelpfulExpertise(List<File> files) {
    File helpfulFile;
    int needExp = -1;

    if (files.isEmpty) {
      throw Exception('files must not be empty.');
    }

    if (files.length == 1) {
      return files.first;
    }

    // For each carried file F, check how many other files need expertise from F to reduce the production time
    files.forEach((file) {
      List<File> _files = [...files];

      _files.retainWhere((f) => f != file);

      // needExp represents the number of files (out of two) which can profit from the expertise of [file]
      int newNeedExp = _files.where((f) {
        var moleculeType = file.gain;
        return f.costs[moleculeType] > max(0, expertises[moleculeType]);
      }).length;

      if (newNeedExp > needExp) {
        needExp = newNeedExp;
        helpfulFile = file;
      }
    });

    return helpfulFile;
  }

  /// Return true if the player will be able to collect the needed molecules for all diagnosed files
  bool isEnoughtMoleculesAvailableForAtLeastOneDiagFile() {
    return robot.getDiagFiles().any(_willBeAbleToCollectAllMoleculesForAFile);
  }

  /// Return true if the robot will be able to produce the file [f] in the current context
  /// depending if there is enought molecules  and expertise available. If it is
  /// impossible to produce, return false
  bool _willBeAbleToCollectAllMoleculesForAFile(File f) {
    final able = MoleculeType.values.every((moleculeType) {
      final cost = f.costs[moleculeType];
      final expertise = expertises[moleculeType];
      final available = Game.availables[moleculeType];
      final storage = robot.storages[moleculeType];
      // If the cost in molecules of the file is higher than the available molecules and the molecule expertise of the player
      if (available + expertise + storage >= cost) {
        return true;
      }
      return false;
    });
    return able;
  }

  @override
  String toString() {
    String s = 'PLAYER:';
    String props = [
      'id: $id',
      'score: $score',
      'expertises:${Util.displayMap(expertises)}',
      'robot: $robot'
    ].join(' ');
    s += props;
    return s;
  }
}

/// PROJECT
class Project {
  Project(
    this.expertises,
  );

  /// Number of scientific projects
  static int count;

  /// The required expertise for each molecule type
  /// Example : expertises[A] = 2
  Map<MoleculeType, int> expertises;

  @override
  String toString() {
    var s = '';
    var props = [
      '${Util.displayMap(expertises)}',
    ].join(' ');
    s += props;
    return s;
  }
}

/// ROBOT
class Robot {
  static const int maxFiles = 3;
  static const int maxMolecules = 10;

  Robot({
    this.target,
    this.eta,
    this.files,
    this.storages,
  });

  /// Module where the robot is
  ModuleType target;

  /// Number of turns before the robot reach the module (O if on the module)
  int eta;

  /// Files carried by the robot
  List<File> files;

  /// Number of molecules carried by the robot
  Map<MoleculeType, int> storages;

  bool get hasCarriedFile => files.isNotEmpty;

  /// Return true if all files carried by the robot are diagnosed, else return false
  bool get isAllDiagFiles {
    if (files.isEmpty) {
      return false;
    }

    if (files.where((file) => file.isDiagnosed).length == files.length) {
      return true;
    } else {
      return false;
    }
  }

  /// Return the number of file which have rank [r]
  int getRankCount(int r) {
    return files.where((file) => file.isRank(r)).length;
  }

  /// Get the list of diagnosed files
  List<File> getDiagFiles() => files.where((file) => file.isDiagnosed).toList();

  /// Get the list of non-diagnosed files
  List<File> getNonDiagFiles() =>
      files.where((file) => !file.isDiagnosed).toList();

  /// Sort files by ascendant ratio
  void _sortFilesByRatio() {
    files.sort((a, b) => a.ratio.compareTo(b.ratio));
  }

  /// Return the file with the maximum ratio
  File getFileWithMaxRatio() {
    if (files.isEmpty) {
      return null;
    }
    _sortFilesByRatio();
    return files.last;
  }

  /// Return the first file the robot can produce, else return null
  File canProduceAFile(Player p) {
    for (var f in files) {
      if (_canProduce(f, p)) {
        return f;
      }
    }
    return null;
  }

  /// Return true if the robot has enough molecules to produce the file [f]
  bool _canProduce(File f, Player p) {
    if (f == null) {
      return false;
    }

    // If the costs are not available (not diagnosed), return false
    if (f.costs.values.any((v) => v == -1)) {
      return false;
    }

    // If there storage there is enough ressources to produce every molecule type
    final bool canProduce = MoleculeType.values.every((moleculeType) {
      int storage = storages[moleculeType];
      int cost = f.costs[moleculeType];
      int expertise = p.expertises[moleculeType];

      if (storage + expertise >= cost) {
        return true;
      }
      return false;
    });

    return canProduce;
  }

  /// Return the molecule the robot must collect to complete the file [f], orElse return null
  MoleculeType whichMoleculeToCollect(File f, Player p) {
    for (var moleculeType in MoleculeType.values) {
      int storage = storages[moleculeType];
      int cost = f.costs[moleculeType];
      int expertise = p.expertises[moleculeType];
      int available = Game.availables[moleculeType];

      // If ressources are less than cost and if molecule is available
      if (storage + expertise < cost && available > 0) {
        return moleculeType;
      }
    }

    // If no molecule are available to complete the file, return null
    return null;
  }

  @override
  String toString() {
    String s = 'ROBOT:';
    String props = [
      'target:${Util.toShortString(target)} ',
      'eta:$eta',
      'storages: ${Util.displayMap(storages)}',
      'files: $files',
    ].join(' ');
    s += props;
    return s;
  }
}

// FILE
class File {
  File({
    this.id,
    this.carriedBy,
    this.health,
    this.rank,
    this.gain,
    this.costs,
  });

  /// id of the file
  int id;

  /// indicates if the file is carried by a player (not carried:-1, player0: 0, player1: 1)
  int carriedBy;

  /// health of the file
  int health;

  /// Rank of the file
  int rank;

  /// Expertise gain of the file in A, B, C, D E
  MoleculeType gain;

  /// The cost to spends in each molecule type for this file
  Map<MoleculeType, int> costs;

  /// Return the total cost in molecule
  int get totalCost => costs.values.reduce((a, b) => a + b);

  /// Return the ratio of earned health by total cost in molecule
  double get ratio => health / totalCost;

  /// Return true is the file is diagnosed, else return false
  bool get isDiagnosed => health != -1;

  /// Return true if rank equals [r]
  bool isRank(int r) {
    return rank == r;
  }

  @override
  String toString() {
    var s = 'FILE:';
    var props = [
      'id:$id',
      'carriedBy:$carriedBy',
      'health:$health',
      'rank:$rank',
      'gain:${Util.toShortString(gain)}',
      'costs:${Util.displayMap(costs)}',
    ].join(' ');
    s += props;
    return s;
  }
}

/// COMMANDS
class Commands {
  ///  Make the robot do nothing (or keep the robot moving)
  static void wait() {
    print('WAIT ' * 2);
  }

  static void move() {
    print('MOVE');
  }

  ///  Make the robot go the specific module [moduleType]
  static void goTo(ModuleType moduleType) {
    String moduleName = Util.toShortString(moduleType);
    print('GOTO $moduleName ' * 2);
  }

  /// Make the robot get a sample file of a specific [rank]
  static void connectSamples(int rank) {
    _connect(rank.toString());
  }

  /// Make the robot connect to the Diagnosis Module to diagnose the file [fileId]
  ///
  /// The robot must care the file of id [fileId]
  static void connectDiagnosis(String fileId) {
    _connect(fileId);
  }

  /// Make the robot connect the Molecules Module to create a molecule of type [moleculeType]
  static void connectMolecules(MoleculeType moleculeType) {
    String moleculeName = Util.toShortString(moleculeType);
    _connect(moleculeName);
  }

  /// Make the robot connect to the Laboratory Module to create medecines for the file [fileId]
  ///
  /// The robot should care the file of id [fileId]
  static void connectLaboratory(String fileId) {
    _connect(fileId);
  }

  static void _connect(String e) {
    print('CONNECT $e ' * 2);
  }
}

/// STATE MACHINE
class State {
  StateType _state;

  bool hasAllSamples = false;
  bool isAllDiagFiles = false;
  bool canProduceAFile = false;
  bool canCollectMoleculeForAtLeastOneDiagFile = false;

  StateType get state => _state;

  evalState() {
    // OBSERVE VARIABLES
    if (Game.player0.robot.files.length == 3) {
      hasAllSamples = true;
    }
    if (Game.player0.robot.isAllDiagFiles) {
      isAllDiagFiles = true;
    }
    if (Game.player0.robot.canProduceAFile(Game.player0) != null) {
      canProduceAFile = true;
    }
    if (Game.player0.isEnoughtMoleculesAvailableForAtLeastOneDiagFile()) {
      canCollectMoleculeForAtLeastOneDiagFile = true;
    }

    // EVAL STATE
    // If the robot is moving Moving, the state is MOVING
    if (Game.player0.robot.eta > 0) {
      _state = StateType.MOVING;
    } else if (!hasAllSamples &&
        !canProduceAFile &&
        !canCollectMoleculeForAtLeastOneDiagFile) {
      _state = StateType.CHOOSE;
    } else if (hasAllSamples && !isAllDiagFiles) {
      _state = StateType.ANALYSE;
    } else if (isAllDiagFiles &&
        canCollectMoleculeForAtLeastOneDiagFile &&
        !canProduceAFile) {
      _state = StateType.COLLECT;
    } else if (isAllDiagFiles && canProduceAFile) {
      _state = StateType.PRODUCE;
    } else if (!canCollectMoleculeForAtLeastOneDiagFile) {
      _state = StateType.STORE;
    } else {
      _state = StateType.UNDEFINED;
    }
  }

  actions() {
    switch (_state) {
      case StateType.MOVING:
        Commands.move();

        break;
      case StateType.CHOOSE:
        // If Robot is not in DIAGNOSIS Module, go there
        if (ModuleType.SAMPLES != Game.player0.robot.target) {
          Commands.goTo(ModuleType.SAMPLES);
        }
        // Else choose a file
        else {
          var rank = 1;
          // If expertise is greater or equal than 3 and number of files with rank 2 is less than 2, take a file of rank 2
          if (Game.player0.getTotalExpertise() +
                  Game.player0.robot.files.length >=
              5) {
            rank = 2;
          }
          if (Game.player0.getTotalExpertise() +
                  Game.player0.robot.files.length >=
              8) {
            rank = 3;
          }
          Commands.connectSamples(rank);
        }
        break;
      case StateType.ANALYSE:
        // If Robot is not in DIAGNOSIS Module, go there
        if (ModuleType.DIAGNOSIS != Game.player0.robot.target) {
          Commands.goTo(ModuleType.DIAGNOSIS);
        }
        // Else choose a file
        else {
          var nonDiagFile = Game.player0.robot.getNonDiagFiles().first;
          Commands.connectDiagnosis(nonDiagFile.id.toString());
        }
        break;
      case StateType.COLLECT:
        // If Robot is not in MOLECULES Module, go there
        if (ModuleType.MOLECULES != Game.player0.robot.target) {
          Commands.goTo(ModuleType.MOLECULES);
        }
        // Else collect molecules
        else {
          var file = Game.player0.chooseAfileToCollect();
          var moleculeType =
              Game.player0.robot.whichMoleculeToCollect(file, Game.player0);
          // If we cannot collect molecule, wait
          if (moleculeType == null) {
            Commands.wait();
          } else {
            Commands.connectMolecules(moleculeType);
          }
        }
        break;
      case StateType.PRODUCE:
        // If Robot is not in LABORATORY Module, go there
        if (ModuleType.LABORATORY != Game.player0.robot.target) {
          Commands.goTo(ModuleType.LABORATORY);
        }
        // Else produce
        else {
          File file = Game.player0.robot.canProduceAFile(Game.player0);

          Commands.connectLaboratory(file.id.toString());
        }
        break;
      case StateType.STORE:
        // If Robot is not in DIAGNOSIS Module, go there
        if (ModuleType.DIAGNOSIS != Game.player0.robot.target) {
          Commands.goTo(ModuleType.DIAGNOSIS);
        }
        // Else choose a file to store in the cloud
        else {
          var fileToStore = Game.player0.robot.files.first;
          Commands.connectDiagnosis(fileToStore.id.toString());
        }
        break;
      case StateType.UNDEFINED:
        Commands.wait();
        break;
      default:
        Commands.wait();
    }
  }

  @override
  String toString() {
    var s = 'STATE: ';
    var props = [
      'state:${Util.toShortString(state)}',
      'hasAllSamples:$hasAllSamples',
      'isAllDiagFiles:$isAllDiagFiles',
      'canProduceAFile:$canProduceAFile',
      'canCollectMoleculeForAtLeastOneDiagFile:$canCollectMoleculeForAtLeastOneDiagFile'
    ].join(' ');
    s += props;
    return s;
  }
}

/// The GAME
class Game {
  /// List of scientific projects
  static List<Project> projects = [];

  /// List of files
  static List<File> files = [];

  /// The players
  static Player player0;
  static Player player1;

  /// Available molecules for each molecule type
  ///
  /// Example: availables[MoleculeType.A] = 2
  static Map<MoleculeType, int> availables;

  /// Get the number of scientific projects
  int get projectCount => projects.length;

  /// Get the number of files
  int get filesCount => files.length;

  /// Update all the files with [newfiles] (also update for players)
  static updateFiles(List<File> newfiles) {
    if (newfiles == null) {
      files = [];
    } else {
      files = newfiles;
    }
    Game._updateCariedFilesForAllPlayers();
  }

  /// Update the carried files for all players
  static _updateCariedFilesForAllPlayers() {
    player0.robot.files = _getPlayerCarriedFiles(0);
    player1.robot.files = _getPlayerCarriedFiles(1);
  }

  /// Get the files carried by [playerId]
  static List<File> _getPlayerCarriedFiles(playerId) {
    if (files.isEmpty) {
      return [];
    }
    var _files = [...files];
    _files.retainWhere((element) => element.carriedBy == playerId);
    return _files;
  }

  static void show() {
    String s = 'GAME:' '\n ';

    var props = [
      'availables: ${Util.displayMap(availables)}',
      'projects: ${projects.join(' ')}',
      'files: \n${files.join('\n')}',
      'player0:$player0',
      'player1:$player1',
    ].join('\n ');
    s += props;
    debug(s);
  }
}

/**
 * Bring data on patient samples from the diagnosis machine to the laboratory with enough molecules to produce medicine!
 **/
void main() {
  List inputs;
  int projectCount = int.parse(stdin.readLineSync());
  // PROVIDE PROJECTS
  for (int i = 0; i < projectCount; i++) {
    inputs = stdin.readLineSync().split(' ');
    int a = int.parse(inputs[0]);
    int b = int.parse(inputs[1]);
    int c = int.parse(inputs[2]);
    int d = int.parse(inputs[3]);
    int e = int.parse(inputs[4]);

    Game.projects.add(Project({
      MoleculeType.A: a,
      MoleculeType.B: b,
      MoleculeType.C: c,
      MoleculeType.D: d,
      MoleculeType.E: e,
    }));
  }

  bool isFirstTurn = true;

  // GAME LOOP
  while (true) {
    /// PROVIDE PLAYERS, ROBOTS
    for (int i = 0; i < 2; i++) {
      inputs = stdin.readLineSync().split(' ');
      String target = inputs[0];
      int eta = int.parse(inputs[1]);
      int score = int.parse(inputs[2]);
      int storageA = int.parse(inputs[3]);
      int storageB = int.parse(inputs[4]);
      int storageC = int.parse(inputs[5]);
      int storageD = int.parse(inputs[6]);
      int storageE = int.parse(inputs[7]);
      int expertiseA = int.parse(inputs[8]);
      int expertiseB = int.parse(inputs[9]);
      int expertiseC = int.parse(inputs[10]);
      int expertiseD = int.parse(inputs[11]);
      int expertiseE = int.parse(inputs[12]);

      var robot = Robot(
        target: isFirstTurn ? ModuleType.CENTER : Util.toModuleType(target),
        eta: eta,
        storages: {
          MoleculeType.A: storageA,
          MoleculeType.B: storageB,
          MoleculeType.C: storageC,
          MoleculeType.D: storageD,
          MoleculeType.E: storageE,
        },
      );

      var player = Player(
        id: i,
        robot: robot,
        score: score,
        expertises: {
          MoleculeType.A: expertiseA,
          MoleculeType.B: expertiseB,
          MoleculeType.C: expertiseC,
          MoleculeType.D: expertiseD,
          MoleculeType.E: expertiseE,
        },
      );

      if (i == 0) {
        Game.player0 = player;
      } else if (i == 1) {
        Game.player1 = player;
      }
    }

    isFirstTurn ? isFirstTurn = false : '';

    inputs = stdin.readLineSync().split(' ');
    int availableA = int.parse(inputs[0]);
    int availableB = int.parse(inputs[1]);
    int availableC = int.parse(inputs[2]);
    int availableD = int.parse(inputs[3]);
    int availableE = int.parse(inputs[4]);

    Game.availables = {
      MoleculeType.A: availableA,
      MoleculeType.B: availableB,
      MoleculeType.C: availableC,
      MoleculeType.D: availableD,
      MoleculeType.E: availableE,
    };

    int sampleCount = int.parse(stdin.readLineSync());

    /// PROVIDE FILES
    List<File> newfiles = [];
    for (int i = 0; i < sampleCount; i++) {
      inputs = stdin.readLineSync().split(' ');
      int sampleId = int.parse(inputs[0]);
      int carriedBy = int.parse(inputs[1]);
      int rank = int.parse(inputs[2]);
      String expertiseGain = inputs[3];
      int health = int.parse(inputs[4]);
      int costA = int.parse(inputs[5]);
      int costB = int.parse(inputs[6]);
      int costC = int.parse(inputs[7]);
      int costD = int.parse(inputs[8]);
      int costE = int.parse(inputs[9]);

      var file = File(
          id: sampleId,
          carriedBy: carriedBy,
          health: health,
          gain: Util.toMoleculeType(expertiseGain),
          rank: rank,
          costs: {
            MoleculeType.A: costA,
            MoleculeType.B: costB,
            MoleculeType.C: costC,
            MoleculeType.D: costD,
            MoleculeType.E: costE,
          });

      newfiles.add(file);
    }

    Game.updateFiles(newfiles);

    /**
     * GAME LOGIC
     */

    //Game.show();
    State state = State();

    state.evalState();
    debug(state);

    state.actions();
  }
}
