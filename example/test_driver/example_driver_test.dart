// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('end-to-end test', () {
    FlutterDriver driver;

    setUpAll(() async {
      // Connect to a running Flutter application instance.
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('click on "Imprimir Texto" button', () async {
      // Finds the floating action button (fab) to tap on
      //final fab = find.byValueKey('firstButton');
      final fab = find.text('Imprimir texto');
      // Wait for the floating action button to appear
      await driver.waitFor(fab);      
      // Tap on the fab
      await driver.tap(fab);
      // Wait for text to change to the desired value
      await driver.waitFor(find.text('Error de impresión.'));
    });
  });
}