import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Carga Roboto real y los iconos Material para que las golden screenshots
// rendericen texto legible (flutter_test usa Ahem, que dibuja cajas). El
// peso/estilo se conserva del propio TTF, así que FontWeight.bold y
// FontStyle.italic resuelven bien.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Roboto');
  for (final name in ['Regular', 'Medium', 'Bold', 'Italic']) {
    final bytes = await File('test/fonts/Roboto-$name.ttf').readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  final iconsLoader = FontLoader('MaterialIcons');
  final iconsBytes =
      await File('test/fonts/MaterialIcons-Regular.otf').readAsBytes();
  iconsLoader.addFont(Future.value(ByteData.sublistView(iconsBytes)));
  await iconsLoader.load();
  await testMain();
}
