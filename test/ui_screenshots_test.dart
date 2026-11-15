import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musca/l10n/app_localizations.dart';
import 'package:musca/models/calculation.dart';
import 'package:musca/models/cartridge_model.dart';
import 'package:musca/models/gun_model.dart';
import 'package:musca/models/scope_model.dart';
import 'package:musca/screens/home/widgets/trajectory_table_dialog.dart';
import 'package:musca/screens/profile/screens/cartridge/screens/cartridge_settings_screen.dart';

// El mismo tema que MuscaApp, con Roboto cargada desde test/fonts (ver
// flutter_test_config.dart) para que las goldens rendericen texto real.
ThemeData _testTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 96, 25, 163),
    ),
    fontFamily: 'Roboto',
  );
}

Widget _wrap(Widget child, {Locale locale = const Locale('es')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: _testTheme(),
    home: child,
  );
}

void _useSurface(WidgetTester tester, Size logicalSize) {
  tester.view.physicalSize = logicalSize * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

// Bombea la animación del diálogo sin pumpAndSettle: el cursor del campo de
// búsqueda (autofocus) mantiene un timer de parpadeo que nunca se asienta.
Future<void> _pumpDialog(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('Selector de cartucho (modal)', () {
    testWidgets('campo vacío por defecto y modal con lista completa',
        (tester) async {
      _useSurface(tester, const Size(390, 844));
      await tester.pumpWidget(_wrap(const Scaffold(
        body: CartridgeSettingsScreen(),
      )));
      await tester.pumpAndSettle();

      // El campo de nombre no tiene nada por defecto.
      final nameField = find.byType(TextField).first;
      expect(tester.widget<TextField>(nameField).controller!.text, isEmpty);

      // Al pulsar se abre el modal con la lista completa de calibres.
      await tester.tap(nameField);
      await _pumpDialog(tester);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Elige un cartucho'), findsOneWidget);
      expect(find.text('.308 Winchester 168 gr'), findsWidgets);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/cartridge_preset_modal.png'),
      );
    });

    testWidgets('escribir filtra la lista y al elegir se autorrellena',
        (tester) async {
      _useSurface(tester, const Size(390, 844));
      await tester.pumpWidget(_wrap(const Scaffold(
        body: CartridgeSettingsScreen(),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField).first);
      await _pumpDialog(tester);

      await tester.enterText(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(TextField),
        ),
        '308',
      );
      await tester.pump();
      expect(find.text('.308 Winchester 168 gr'), findsOneWidget);
      expect(find.text('.223 Remington 55 gr FMJ'), findsNothing);

      await tester.tap(find.text('.308 Winchester 168 gr'));
      await tester.pumpAndSettle();

      // Nombre y datos del cartucho autorrellenados.
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '.308 Winchester 168 gr',
      );
      expect(find.text('0.782'), findsOneWidget); // diámetro
      expect(find.text('168.0'), findsOneWidget); // peso
    });

    testWidgets('permite usar un nombre libre que no está en la lista',
        (tester) async {
      _useSurface(tester, const Size(390, 844));
      await tester.pumpWidget(_wrap(const Scaffold(
        body: CartridgeSettingsScreen(),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField).first);
      await _pumpDialog(tester);

      await tester.enterText(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(TextField),
        ),
        'Mi carga especial',
      );
      await tester.pump();
      expect(find.text('Ningún cartucho coincide con la búsqueda'),
          findsOneWidget);

      await tester.tap(find.text('Usar "Mi carga especial" como nombre'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Mi carga especial',
      );
    });
  });

  group('Tabla de correcciones', () {
    testWidgets('se ve completa en horizontal', (tester) async {
      _useSurface(tester, const Size(844, 390));
      final calculation = Calculation(
        distance: 500,
        angle: 5,
        windSpeed: 4,
        windDirection: 90,
      );
      final gun = Gun(
        id: 'g1',
        name: 'Tikka T3x',
        twistRate: 11.0,
        twistDirection: 1,
        muzzleVelocity: 800.0,
        zeroRange: 100.0,
      );
      final cartridge = Cartridge(
        id: 'c1',
        name: '.308 Winchester 168 gr',
        diameter: '0.782',
        bulletWeight: 168.0,
        bulletLength: 3.55,
        ballisticCoefficient: 0.45,
        bcModelType: 0,
        muzzleVelocity: 800.0,
      );
      final scope = Scope(
        id: 's1',
        name: 'Vortex Viper',
        sightHeight: 5.0,
        units: 1,
      );

      await tester.pumpWidget(_wrap(Scaffold(
        body: Center(
          child: TrajectoryTableDialog(
            calculation: calculation,
            selectedGun: gun,
            selectedCartridge: cartridge,
            selectedScope: scope,
          ),
        ),
      )));
      await tester.pumpAndSettle();

      // Sin overflow en horizontal y con cabecera, controles y tabla visibles.
      expect(tester.takeException(), isNull);
      expect(find.text('Tabla de Correcciones'), findsOneWidget);
      expect(find.text('Distancia\n(m)'), findsOneWidget);
      expect(find.byType(Table), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/trajectory_table_landscape.png'),
      );
    });
  });
}
