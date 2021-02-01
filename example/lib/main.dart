// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/services.dart';

// Para HTTP
import 'package:http/http.dart' as http;

// Importar el plugin
import 'package:postek_plugin/postek_plugin.dart';

void main() {
  // Enable integration testing with the Flutter Driver extension.
  //enableFlutterDriverExtension();
  runApp(const MyApp());
}

/// Clase principal
class MyApp extends StatelessWidget {
  ///  Class Key
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Demo Postek';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: const PrintPage(),
      ),
    );
  }
}

/// Opciones de impresión
class PrintPage extends StatefulWidget {
  ///  Class Key
  const PrintPage({Key key}) : super(key: key);
  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  // Dirección del servidor de impresión
  String serverUrl;

  PostekPlugin postek;
  final _client = http.Client();

  // Listas de selección
  List<String> impresoras;
  // Valores iniciales de cada campo de selección
  String _currentPrinter;

  // Crear controlador de texto para procesar entrada de los TextField.
  final _controllerServer = TextEditingController();
  final _controllerWidth = TextEditingController();
  final _controllerHeight = TextEditingController();
  final _controllerGap = TextEditingController();
  final _controllerTextData = TextEditingController();
  final _controllerRFIDData = TextEditingController();

  // Método para inicializar
  @override
  void initState() {
    super.initState();
    postek = PostekPlugin(_client);
    impresoras = [];
  }

  // Método para limpiar
  @override
  void dispose() {
    _controllerServer.dispose();
    _controllerWidth.dispose();
    _controllerHeight.dispose();
    _controllerGap.dispose();
    _controllerTextData.dispose();
    _controllerRFIDData.dispose();
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(children: [
        // Título 1
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text('Configuración de impresora',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        // Texto de url
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            const Text('URL del servidor\nde impresión:'),
            SizedBox(
              width: 200,
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  labelText: 'URL (Ej: https://dir.com)',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[\n\t\r]'))
                ],
                controller: _controllerServer,
                onChanged: (value) {
                  if (value.length < 2) {
                    setState(() {});
                  }
                },
              ),
            ),
          ]),
        ),
        // Impresora asociada
        Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de conectar al servidor
                  RaisedButton(
                    color: _controllerServer.text.isNotEmpty
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () {
                      if (_controllerServer.text.isNotEmpty) {
                        if ((_controllerServer.text.startsWith('https://') &&
                                _controllerServer.text.length > 8) ||
                            (_controllerServer.text.startsWith('http://') &&
                                _controllerServer.text.length > 7)) {
                          serverUrl = _controllerServer.text;
                          _getPrinters();
                        } else {
                          _showToast('Ingrese una dirección válida', context);
                        }
                      }
                    },
                    child: const Text('Obtener\nimpresoras',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white)),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Impresora:'),
                        SizedBox(
                            width: 150,
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: DropdownButton<String>(
                                  value: _currentPrinter,
                                  icon: const Icon(Icons.arrow_downward,
                                      color: Colors.blueAccent),
                                  elevation: 16,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.brown),
                                  onChanged: (newValue) async {
                                    setState(() {
                                      _currentPrinter = newValue;
                                    });
                                  },
                                  items: impresoras
                                      .map<DropdownMenuItem<String>>(
                                          (value) => DropdownMenuItem<String>(
                                                value: value,
                                                child: SizedBox(
                                                    width: 120,
                                                    child: Text(value)),
                                              ))
                                      .toList(),
                                ))),
                      ])
                ])),
        // Título 2
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text('Configuración de etiquetas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        // Configuración de tags
        Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              const TableRow(children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Ancho',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Alto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Espacio entre etiquetas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          labelText: 'Dots'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                      ],
                      controller: _controllerWidth,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          labelText: 'Dots'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                      ],
                      controller: _controllerHeight,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          labelText: 'Dots'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                      ],
                      controller: _controllerGap,
                    ),
                  ),
                )
              ]),
            ]),
        // Separador
        Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: const Divider(thickness: 2)),
        // Título 3
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text('Impresión de datos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        // Texto a imprimir
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            const Text('Texto a imprimir:'),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    labelText: 'Texto'),
                controller: _controllerTextData,
              ),
            ),
          ]),
        ),
        // Botón de imprimir texto
        Container(
            alignment: Alignment.center,
            child: RaisedButton(
              key: const Key('firstButton'),
              color: Colors.blueAccent,
              onPressed: () async {
                if (_currentPrinter != null) {
                  final result = await postek.printText(
                      serverUrl,
                      _currentPrinter,
                      _controllerWidth.text,
                      _controllerHeight.text,
                      _controllerGap.text,
                      _controllerTextData.text);
                  if (!result) {
                    _showToast('Error de impresión.', context);
                  }
                } else {
                  _showToast('No hay impresora asociada.', context);
                }
              },
              child: const Text('Imprimir texto',
                  style: TextStyle(color: Colors.white)),
            )),
        // Otras opciones de impresión
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          alignment: Alignment.center,
          child: RaisedButton(
            color: Colors.blueAccent,
            onPressed: () async {
              final result = await postek.printBarcode(
                  serverUrl,
                  _currentPrinter,
                  _controllerWidth.text,
                  _controllerHeight.text,
                  _controllerGap.text,
                  _controllerTextData.text);
              if (!result) {
                _showToast('Error de impresión.', context);
              }
            },
            child: const Text('Imprimir código de barras',
                style: TextStyle(color: Colors.white)),
          ),
        ),
        // Título 4
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text('Escritura RFID',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        // Dato RFID
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            const Text('Dato RFID a guardar:'),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    labelText: 'Dato'),
                controller: _controllerRFIDData,
              ),
            ),
          ]),
        ),
        // Botón de escribir RFID
        Container(
            alignment: Alignment.center,
            child: RaisedButton(
              color: Colors.blueAccent,
              onPressed: () async {
                final result = await postek.writeRFID(
                    serverUrl,
                    _currentPrinter,
                    _controllerWidth.text,
                    _controllerHeight.text,
                    _controllerGap.text,
                    _controllerRFIDData.text);
                if (!result) {
                  _showToast('Error de escritura RFID.', context);
                }
              },
              child: const Text('Escribir RFID',
                  style: TextStyle(color: Colors.white)),
            )),
        // Título 5
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text('Impresión de datos + RFID',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        // Botón de imprimir + escribir RFID
        Container(
            alignment: Alignment.center,
            child: RaisedButton(
              color: Colors.blueAccent,
              onPressed: () async {
                final result = await postek.writeRFIDBarcode(
                    serverUrl,
                    _currentPrinter,
                    _controllerWidth.text,
                    _controllerHeight.text,
                    _controllerGap.text,
                    _controllerTextData.text,
                    _controllerRFIDData.text);
                if (!result) {
                  _showToast('Error de escritura RFID / Impresión de código.',
                      context);
                }
              },
              child: const Text('Impresión combinada',
                  style: TextStyle(color: Colors.white)),
            )),
      ]);

  // Inicializar impresoras
  Future<void> _getPrinters() async {
    try {
      final printers = await postek.fetchPrinter(serverUrl);
      if (printers != null && printers.isNotEmpty) {
        for (var i = 0; i < printers.length; i++) {
          impresoras.add(printers[i]['printName'].toString());
        }
        setState(() {});
      } else {
        _showToast('No hay impresoras disponibles', context);
      }
    } on Exception {
      _showToast('Fallo en conexión a servidor', context);
    }
  }

  // Método para mostrar mensajes al usuario
  static void _showToast(String toShow, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toShow)));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('serverUrl', serverUrl))
      ..add(IterableProperty<String>('impresoras', impresoras))
      ..add(DiagnosticsProperty<PostekPlugin>('postek', postek));
  }
}
