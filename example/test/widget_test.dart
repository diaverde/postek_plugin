// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

import 'package:flutter_test/flutter_test.dart';
//import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Importar el plugin
//import 'package:postek_plugin/postek_plugin.dart';

import 'package:example/main.dart';


// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {

  final client = MockClient();
  //final postek = PostekPlugin(client);

  testWidgets('Start screen', (tester) async {      
    const testUrl = 'http://127.0.0.1:888/postek/print';
    // Usar datos pasados realmente
    final data = {'printname':'','reqParam':'0','lang':'en'};

    // Use Mockito to return a successful response when it calls the
    // provided http.Client.
    when(client.post(testUrl, body: data))
      .thenAnswer((_) async => http.Response('[{"title": "Test"}]', 200));

    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(const MyApp());    

    expect(find.text('Impresión de datos'), findsOneWidget);
    expect(find.text('Imprimir texto'), findsOneWidget);
    expect(find.text('Dato RFID a guardar:'), findsOneWidget);    

  });
  
}