import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

const String fileName = "TestFile.txt";
const String uploadedAudioFileName = "TestRecording.aac";
const String downloadedAudioFileName = "TestRecording.aac";
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
  FlutterSound flutterSound;
  bool recording = false;
  bool uploading = false;
  bool downloading = false;
  bool uploadingRecording = false;
  bool downloadingRecording = false;

  String audioFilePath = "";

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();
  }

  @override
  void dispose() {
    flutterSound.stopRecorder();
    flutterSound.stopPlayer();
    super.dispose();
  }

  Future<void> _uploadTextFile() async {
    print("Uploading...");
    setState(() {
      uploading = true;
    });

    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File('${systemTempDir.path}/$fileName').create();
    await file.writeAsString(testString);
    assert(await file.readAsString() == testString);

    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask uploadTask = storageRef.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    StorageTaskSnapshot uploadTaskSnap = await uploadTask.onComplete;
    String url = await uploadTaskSnap.ref.getDownloadURL();
    print("Complete! $url");
    setState(() {
      uploading = false;
    });
  }

  Future<void> _downloadTextFile() async {
    print("Downloading...");
    setState(() {
      downloading = true;
    });

    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/$fileName');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    assert(await tempFile.readAsString() == "");

    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(fileName);
    final StorageFileDownloadTask downloadTask =
        storageRef.writeToFile(tempFile);

    final int byteCount = (await downloadTask.future).totalByteCount;
    final String tempFileContents = await tempFile.readAsString();
    assert(tempFileContents == testString);
    assert(byteCount == testString.length);

    print("Complete! $byteCount bytes");
    setState(() {
      downloading = false;
    });
  }

  void _recordPressed() {
    if (recording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    print("Recording...");
    setState(() {
      recording = true;
    });
    audioFilePath = await flutterSound.startRecorder(
      "sound.aac",
      codec: t_CODEC.CODEC_AAC,
    );
    print("Path: $audioFilePath");
  }

  Future<void> _stopRecording() async {
    print("Recording Stopped.");
    setState(() {
      recording = false;
    });

    String result = await flutterSound.stopRecorder();
    print("Result: $result");
  }

  Future<void> _uploadRecording() async {
    assert(audioFilePath != null);
    print("Uploading Recordng...");
    setState(() {
      uploadingRecording = true;
    });

    final File file = File(audioFilePath);
    assert(await file.exists());

    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(uploadedAudioFileName);
    final StorageUploadTask uploadTask = storageRef.putFile(file);
    StorageTaskSnapshot uploadTaskSnap = await uploadTask.onComplete;
    String url = await uploadTaskSnap.ref.getDownloadURL();
    print("Complete! $url");
    setState(() {
      uploadingRecording = false;
    });
  }

  Future<void> _downloadRecording() async {
    print("Downloading Recording...");
    setState(() {
      downloadingRecording = true;
    });

    final Directory systemTempDir = Directory.systemTemp;
    final File audioFile =
        File('${systemTempDir.path}/$downloadedAudioFileName');
    if (audioFile.existsSync()) {
      await audioFile.delete();
    }
    await audioFile.create();
    assert(await audioFile.readAsString() == "");

    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(uploadedAudioFileName);
    final StorageFileDownloadTask downloadTask =
        storageRef.writeToFile(audioFile);

    final int byteCount = (await downloadTask.future).totalByteCount;

    print("Complete! $byteCount bytes");
    setState(() {
      downloadingRecording = false;
    });
  }

  Future<void> _playAudio() async {
    print("Playing Audio.");
    final Directory systemTempDir = Directory.systemTemp;
    final String downloadedAudioFileUri =
        '${systemTempDir.path}/$downloadedAudioFileName';
    assert(await File(downloadedAudioFileUri).exists());
    String result = await flutterSound.startPlayer(downloadedAudioFileUri);
    print("Result: $result");
    String volumeResult = await flutterSound.setVolume(1.0);
    print("Volume Set Result: $volumeResult");
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
            // TODO: start here and implement the following actions
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _recordPressed,
                child:
                    recording ? Text('Stop Recording') : Text('Record Audio'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _uploadRecording,
                child: uploadingRecording
                    ? LinearProgressIndicator()
                    : Text('Upload Recording'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _downloadRecording,
                child: downloadingRecording
                    ? LinearProgressIndicator()
                    : Text('Download Audio'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _playAudio,
                child: Text('Play Audio'),
              ),
            ),
            SizedBox(height: 50),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _uploadTextFile,
                child: uploading
                    ? LinearProgressIndicator()
                    : Text('Upload Text File'),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                onPressed: _downloadTextFile,
                child: downloading
                    ? LinearProgressIndicator()
                    : Text('Download Text File'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
