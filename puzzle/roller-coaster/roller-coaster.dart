import 'dart:io';

/// Debug [e] to the console
debug(Object e) => stderr.writeln(e);

/// Cost per person
const int costPerPerson = 1;

/// Carousel
class Carousel {
  Carousel({this.size, this.count});

  /// Number of place in the carousel
  int size;

  /// Number of times by day the carousel can day be used
  int count;

  /// List of groups of persons
  List<int> groups = [];

  /// Add a group to [groups] by indicating the [numberOfpersons] in the group
  void addGroup(int numberOfpersons) {
    groups.add(numberOfpersons);

    /// Calculate the number of money earn at the end of the day
    int earn() {
      // TODO: implement earn
      int earned = 0;

      /// Calculate the number money earned for each turn

      /// Make the sum of earned money at each turn

      return earned;
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/
void main() {
  List inputs;
  inputs = stdin.readLineSync().split(' ');
  // Number of place in the carousel
  int L = int.parse(inputs[0]);
  // Number of times by day the carousel can day be used
  int C = int.parse(inputs[1]);
  // Number of groups
  int N = int.parse(inputs[2]);

  Carousel carousel = Carousel(size: L, count: C);

  for (int i = 0; i < N; i++) {
    // Number of persons in each group
    int Pi = int.parse(stdin.readLineSync());
    carousel.addGroup(Pi);
  }

  // Write an answer using print()
  // To debug: stderr.writeln('Debug messages...');

  print('answer');
}
