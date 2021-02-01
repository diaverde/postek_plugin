// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

/* ----------Paquete para comunicación con servidor Postek------------
Contiene los métodos que se utilizan para recibir los diferentes
datos consultados
*/

import 'dart:convert';
// Para HTTP
import 'package:http/http.dart' as http;

/// Clase para el plugin Postek
class PostekPlugin {
  /// Constructor
  PostekPlugin(this.client);

  /// Cliente HTTP
  final http.Client client;

  /// Complemento para la URL
  static const urlExtra = '/postek/print';

  // Valores de configuración
  /// Dirección de impresión - B o T
  static const printDirection = 'B';

  /// Velocidad de impresión - 1 a 10
  static const printSpeed = '4';

  /// Contraste de impresión - 0 a 20
  static const printDarkness = '15';

  /// Desplazamiento del gap
  static const gapOffset = '0';

  /// Indica si se debe usar el valor de desplazamiento del gap
  static const gapOffsetFlag = 'false';

  /// Rotación de la impresión
  static const rotation = '0';

  /// Tipo de fuente interna
  static const internalFont = '3';

  /// Tamaño horizontal de fuente
  static const pHorizontal = '1';

  /// Tamaño vertical de fuente
  static const pVertical = '1';

  /// Impresión normal o colores invertidos
  static const pText = 'N';

  /// Indica si se envía alguna variable como parámetro
  static const includesVariable = '0';

  /// Tipo de código de barras
  static const barcodeType = '1';

  /// Ancho de la barra más estrecha
  static const barNarrow = '2';

  /// Ancho de la barra más ancha
  static const barWidth = '2';

  /// Altura de las barras
  static const barHeigth = '60';

  /// Texto y barras
  static const barText = 'B';

  /// Posición de lectura/escritura RFID
  static const rfidPos = '0';

  /// Reintentos al escribir RFID
  static const rfidRetry = '1';

  /// Modo de operación RFID
  static const rfidMode = '1';

  /// Formato de escritura RFID - 0:hex, 1:ascii
  static const rfidFormat = '0';

  /// Bloque de inicio de escritura RFID
  static const startBlock = '2';

  /// Tamaño de datos RFID en bytes
  static const dataNum = '4';

  /// Bloque de memoria para escritura RFID
  static const memBlock = '1';

  /// Función para obtener impresoras
  Future<List> fetchPrinter(String serverUrl) async {
    // Armar dirección completa
    final fullServerUrl = serverUrl + urlExtra;
    // Armar datos
    final data = {'printname': '', 'reqParam': '0', 'lang': 'en'};
    // Armar la solicitud POST
    dynamic response;
    try {
      response = await client
          .post(fullServerUrl, body: data)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Error del Servidor');
      });
    } on Exception catch (e) {
      throw Exception('Error del Servidor: $e');
    }
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic fetchedPrinters = json.decode(response.body.toString());
        if (fetchedPrinters is List) {
          return fetchedPrinters;
        } else {
          return <String>[];
        }
      } on Exception {
        return <String>[];
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }

  /// Función para imprimir texto
  Future<bool> printText(String serverUrl, String printer, String width,
      String height, String gap, String data2print) async {
    const numberLabels = '1';
    const numberCopies = '1';
    final dataLength = data2print.length;
    var xStart = (int.parse(width) / 2 - dataLength * 13).round().toString();
    if (int.parse(xStart) < 10) {
      xStart = '10';
    }
    //print(xStart);
    var yStart = (int.parse(height) / 2).round().toString();
    if (int.parse(yStart) < 10) {
      yStart = '10';
    }
    //print(yStart);

    // Armar dirección completa
    final fullServerUrl = serverUrl + urlExtra;

    // Armar datos
    final printParams = '[{"OpenPort":"$printer"},'
        '{"PTK_ClearBuffer":""},'
        '{"PTK_SetDirection":"$printDirection"},'
        '{"PTK_SetPrintSpeed":"$printSpeed"},'
        '{"PTK_SetDarkness":"$printDarkness"},'
        '{"PTK_SetLabelHeight":"$height,$gap,$gapOffset,$gapOffsetFlag"},'
        '{"PTK_SetLabelWidth":"$width"},'
        '{"PTK_DrawTextEx":'
        '"$xStart,$yStart,$rotation,$internalFont,$pHorizontal,'
        '$pVertical,$pText,$data2print,$includesVariable"},'
        '{"PTK_PrintLabel":"$numberLabels,$numberCopies"},'
        '{"ClosePort":""}]';
    final data = {
      'printname': printer,
      'reqParam': '2',
      'lang': 'en',
      'printparams': printParams
    };
    // Armar la solicitud POST
    final response = await client.post(fullServerUrl, body: data);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic result = json.decode(response.body);
        if (result['retval'] == '0') {
          return true;
        } else {
          return false;
        }
      } on Exception {
        return false;
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }

  /// Función para imprimir código de barras
  Future<bool> printBarcode(String serverUrl, String printer, String width,
      String height, String gap, String data2print) async {
    const numberLabels = '1';
    const numberCopies = '1';
    final dataLength = data2print.length;
    var xStart = (int.parse(width) / 2 - dataLength * 20).round().toString();
    if (int.parse(xStart) < 10) {
      xStart = '10';
    }
    var yStart =
        (int.parse(height) / 2 - int.parse(barHeigth)).round().toString();
    if (int.parse(yStart) < 10) {
      yStart = '10';
    }

    // Armar dirección completa
    final fullServerUrl = serverUrl + urlExtra;

    // Armar datos
    final printParams = '[{"OpenPort":"$printer"},'
        '{"PTK_ClearBuffer":""},'
        '{"PTK_SetDirection":"$printDirection"},'
        '{"PTK_SetPrintSpeed":"$printSpeed"},'
        '{"PTK_SetDarkness":"$printDarkness"},'
        '{"PTK_SetLabelHeight":"$height,$gap,$gapOffset,$gapOffsetFlag"},'
        '{"PTK_SetLabelWidth":"$width"},'
        '{"PTK_DrawBarcode":"$xStart,$yStart,$rotation,$barcodeType,$barNarrow,'
        '$barWidth,$barHeigth,$barText,$data2print"},'
        '{"PTK_PrintLabel":"$numberLabels,$numberCopies"},'
        '{"ClosePort":""}]';
    final data = {
      'printname': printer,
      'reqParam': '2',
      'lang': 'en',
      'printparams': printParams
    };
    // Armar la solicitud POST
    final response = await client.post(fullServerUrl, body: data);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic result = json.decode(response.body);
        if (result['retval'] == '0') {
          return true;
        } else {
          return false;
        }
      } on Exception {
        return false;
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }

  /// Función para escribir RFID
  Future<bool> writeRFID(String serverUrl, String printer, String width,
      String height, String gap, String data2save) async {
    const numberLabels = '1';
    const numberCopies = '1';

    // Armar dirección completa
    final fullServerUrl = serverUrl + urlExtra;

    // Armar datos
    final printParams = '[{"OpenPort":"$printer"},'
        '{"PTK_ClearBuffer":""},'
        '{"PTK_SetDirection":"$printDirection"},'
        '{"PTK_SetPrintSpeed":"$printSpeed"},'
        '{"PTK_SetDarkness":"$printDarkness"},'
        '{"PTK_SetLabelHeight":"$height,$gap,$gapOffset,$gapOffsetFlag"},'
        '{"PTK_SetLabelWidth":"$width"},'
        '{"PTK_SetRFID":"0,$rfidPos,0,$rfidRetry,0"},'
        '{"PTK_RWRFIDLabel":"$rfidMode,$rfidFormat,$startBlock,$dataNum,'
        '$memBlock,$data2save"},'
        '{"PTK_PrintLabel":"$numberLabels,$numberCopies"},'
        '{"ClosePort":""}]';
    final data = {
      'printname': printer,
      'reqParam': '2',
      'lang': 'en',
      'printparams': printParams
    };
    // Armar la solicitud POST
    final response = await client.post(fullServerUrl, body: data);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic result = json.decode(response.body);
        if (result['retval'] == '0') {
          return true;
        } else {
          return false;
        }
      } on Exception {
        return false;
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }

  /// Función para escribir RFID y código de barras
  Future<bool> writeRFIDBarcode(String serverUrl, String printer, String width,
      String height, String gap, String data2print, String data2save) async {
    const numberLabels = '1';
    const numberCopies = '1';
    final dataLength = data2print.length;
    var xStart = (int.parse(width) / 2 - dataLength * 20).round().toString();
    if (int.parse(xStart) < 10) {
      xStart = '10';
    }
    var yStart =
        (int.parse(height) / 2 - int.parse(barHeigth)).round().toString();
    if (int.parse(yStart) < 10) {
      yStart = '10';
    }

    // Armar dirección completa
    final fullServerUrl = serverUrl + urlExtra;

    // Armar datos
    final printParams = '[{"OpenPort":"$printer"},'
        '{"PTK_ClearBuffer":""},'
        '{"PTK_SetDirection":"$printDirection"},'
        '{"PTK_SetPrintSpeed":"$printSpeed"},'
        '{"PTK_SetDarkness":"$printDarkness"},'
        '{"PTK_SetLabelHeight":"$height,$gap,$gapOffset,$gapOffsetFlag"},'
        '{"PTK_SetLabelWidth":"$width"},'
        '{"PTK_SetRFID":"0,$rfidPos,0,$rfidRetry,0"},'
        '{"PTK_RWRFIDLabel":"$rfidMode,$rfidFormat,$startBlock,$dataNum,'
        '$memBlock,$data2save"},'
        '{"PTK_DrawBarcode":"$xStart,$yStart,$rotation,$barcodeType,$barNarrow,'
        '$barWidth,$barHeigth,$barText,$data2print"},'
        '{"PTK_PrintLabel":"$numberLabels,$numberCopies"},'
        '{"ClosePort":""}]';
    final data = {
      'printname': printer,
      'reqParam': '2',
      'lang': 'en',
      'printparams': printParams
    };
    // Armar la solicitud POST
    final response = await client.post(fullServerUrl, body: data);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      try {
        final dynamic result = json.decode(response.body);
        if (result['retval'] == '0') {
          return true;
        } else {
          return false;
        }
      } on Exception {
        return false;
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Error del Servidor');
    }
  }
}
