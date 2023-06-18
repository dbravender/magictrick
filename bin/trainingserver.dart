import 'package:dartmcts/trainingserver.dart';
import 'package:magictrick/src/magictrick_net.dart';

void main() {
  serve(() => MagicTrickNNInterface());
}
