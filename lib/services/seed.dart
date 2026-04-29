import 'firebase_service.dart';

Future<void> runSeed() async {
  await FirebaseService.instance.seedDemoData();
}
