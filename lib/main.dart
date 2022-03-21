import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Share files')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                child: const Text('Generate file'),
                onPressed: () async {
                  final pdf = pw.Document();
                  pdf.addPage(pw.Page(
                    build: (context) =>
                        pw.Center(child: pw.Text('Hello, World!')),
                  ));

                  final Directory storageDir;

                  try {
                    if (!await Permission.storage.isGranted) {
                      await Permission.storage.request();
                    }

                    if (await Permission.storage.isGranted) {
                      if (Platform.isAndroid) {
                        final externalStorage =
                            await getExternalStorageDirectory();

                        if (externalStorage != null) {
                          storageDir = externalStorage;
                        } else {
                          storageDir = await getApplicationDocumentsDirectory();
                        }
                      } else {
                        storageDir = await getApplicationDocumentsDirectory();
                      }

                      print(
                          'Permission granted: ${await Permission.storage.isGranted}');

                      File file = File('${storageDir.path}/someRandom.pdf');

                      await file.writeAsBytes(await pdf.save());

                      print(file.path);
                      print('File exists: ${await file.exists()}');

                      Share.shareFiles([file.path], subject: 'Shared file');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Permission denied')));
                    }
                  } on PlatformException catch (ex) {
                    print(ex);
                  } catch (ex) {
                    print(ex);
                  }
                },
              ),
            ),
            Center(
              child: TextButton(
                child: const Text('Share file'),
                onPressed: () async {},
              ),
            )
          ],
        ));
  }

  Future _getPermissions() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }
}
