import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

const String fileName = "TestFile.txt";
const String testString = 'Hello files!';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tech Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Tech Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool uploading = false;
  bool downloading = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _uploadTextFile() async {
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File('${systemTempDir.path}/$fileName').create();
    await file.writeAsString(testString);
    assert(await file.readAsString() == testString);

    final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask uploadTask = storageRef.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    print("Uploading...");
    setState(() {
      uploading = true;
    });
    StorageTaskSnapshot uploadTaskSnap = await uploadTask.onComplete;
    String url = await uploadTaskSnap.ref.getDownloadURL();
    print("Complete! $url");
    setState(() {
      uploading = false;
    });
  }

  Future<void> _downloadTextFile() async {
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/$fileName');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    assert(await tempFile.readAsString() == "");

    final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);
    final StorageFileDownloadTask downloadTask = storageRef.writeToFile(tempFile);

    print("Downloading...");
    setState(() {
      downloading = true;
    });

    final int byteCount = (await downloadTask.future).totalByteCount;
    final String tempFileContents = await tempFile.readAsString();
    assert(tempFileContents == testString);
    assert(byteCount == testString.length);

    print("Complete! $byteCount bytes");
    setState(() {
      downloading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _uploadTextFile,
                child: uploading ? LinearProgressIndicator(): Text('Upload Text File'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _downloadTextFile,
                child: downloading ? LinearProgressIndicator(): Text('Download Text File'),
              ),
            ),
            SizedBox(height: 30,),
            // TODO: start here and implement the following actions
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: () => print('Recording not implemented yet...'),
                child: Text('Record Audio'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: () => print('Uploading not implemented yet...'),
                child: Text('Upload Recording'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: () => print('Downloading not implemented yet...'),
                child: Text('Download Audio'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: () => print('Playing Audio not implemented yet...'),
                child: Text('Play Audio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
