// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// This is a basic Flutter test.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Importar el plugin
import 'package:postek_plugin/postek_plugin.dart';


// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {

  group('PostekPlugin()', () {

    final client = MockClient();
    final postek = PostekPlugin(client);

    test('returns error when connection fails', () async {      
      const testUrl = '127.0.0.8';
      // Usar datos pasados realmente
      final data = {'printname':'','reqParam':'0','lang':'en'};

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post(testUrl, body: data))
        .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(postek.fetchPrinter(testUrl), throwsException);
    });

    test('returns a list of printers using the right address', () async {      
      const testUrl = 'http://127.0.0.1:888/postek/print';
      // Usar datos pasados realmente
      final data = {'printname':'','reqParam':'0','lang':'en'};

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post(testUrl, body: data))
        .thenAnswer((_) async => http.Response('[{"title": "Test"}]', 200));

      expect(postek.fetchPrinter(testUrl), isA<Future<List>>() );
    });

    test('printText', () async {      
      const testUrl = 'http://127.0.0.1:888/postek/print';
      // Usar datos pasados realmente      
      const printParams = '[{"OpenPort":"printer"},'
        '{"PTK_ClearBuffer":""},'
        '{"PTK_SetPrintSpeed":"4"},'
        '{"PTK_SetDarkness":"10"},'
        '{"PTK_SetLabelHeight":"height,gap,0,false"},'
        '{"PTK_SetLabelWidth":"width"},'
        '{"PTK_DrawTextEx":"90,50,0,3,1,1,N,data2print,0"},'
        '{"PTK_PrintLabel":"1,1"},'
        '{"ClosePort":""}]';  
      final data = {'printname':'printer','reqParam':'2',
        'lang':'en', 'printparams':printParams};

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post(testUrl, body: data))
        .thenAnswer((_) async => http.Response('[{"title": "Test"}]', 200));

      expect(postek.fetchPrinter(testUrl), isA<Future<List>>() );
    });

  });
  
}