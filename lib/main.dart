import 'package:flutter/material.dart';
import "./speak.component.dart";
import 'package:flutter_tts/flutter_tts.dart';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retrieve Text Input',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  List lines;
  int wordIndex;

  FlutterTts flutterTts;

  // speak
  final SpeechToText speech = SpeechToText();
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = null;
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  // speak
  
  var answerIsCorrect;
  bool displayChecking;


  @override
  void initState() {

    super.initState();

    lines = [];
    wordIndex = 0;

    flutterTts = FlutterTts();

    answerIsCorrect = null;
    displayChecking = false;

  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  // speak
  Future<void> initSpeechState() async {

    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      // _localeNames = await speech.locales();

      // var systemLocale = await speech.systemLocale();
      // _currentLocaleId = systemLocale.localeId;
      _currentLocaleId = "en_US";
    }

    // print("HAS SPEECH!!");
    // print(_hasSpeech);
    // else {
    //   print("no speech");
    // }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });

  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 100),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: false);
    setState(() {});
  }

  void stopListening() {

    print("STOP!!!");
    
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {


    if (result.finalResult) {

      print("line to compare ");
      print(lines[wordIndex].toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),''));

      print("recognized");
      print(result.recognizedWords.toLowerCase());

      if (result.recognizedWords.toLowerCase().replaceAll(new RegExp(r"\s+"), "") == lines[wordIndex].toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),'').replaceAll(new RegExp(r"\s+"), "")) {
        // print("CORRECT!");

        setState(() {
          // lastWords = "${result.recognizedWords} - ${result.finalResult}";
          lastWords = "${result.recognizedWords}";
          answerIsCorrect = false;
          displayChecking = true;
        });

        print(lastWords);
        

        correctSpeak(true);

      }
      else {
        // print("wrong!");

        setState(() {
          // lastWords = "${result.recognizedWords} - ${result.finalResult}";
          lastWords = "${result.recognizedWords}";
          answerIsCorrect = true;
          displayChecking = true;
        });

        correctSpeak(false);

      }
      

    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    //print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {

    print(
        "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }

  // speak
  correctSpeak(correct) {

    if (correct){

      if (wordIndex < (lines.length -1) )
        
        setState(() {
          wordIndex += 1;
        });

        // start listening again
        startListening();
      
    }

    else {

      setState(() {
        answerIsCorrect = false;
      });

      _speak(lines[wordIndex]);

      // start listening again
      startListening();

    }
  
  }


  Future _speak(wordToSay) async {
    // await flutterTts.setVolume(volume);
    // await flutterTts.setSpeechRate(rate);
    // await flutterTts.setPitch(pitch);
    // print("trying to speak");

    // if (_newVoiceText != null) {
    //   if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(wordToSay);
        // print("result: ");
        // print(result);
    //     if (result == 1) setState(() => ttsState = TtsState.playing);
    //   }
    // }
  }    

  // get previous text as string
  previousTextAsString() {

    var string = "";

    for (var i = 0; i < (wordIndex); i++) {

      string = string + " " + lines[i];
      
    }

    return string;

  }

  // get next text as string
  nextTextAsString() {

    var string = "";

    for (var i = (wordIndex+1); i < (lines.length); i++) {

      string = string + " " + lines[i];
      
    }

    return string;

  }

  @override
  Widget build(BuildContext context) {

    // initialize microphone
    initSpeechState();

    
    return Scaffold(
      appBar: AppBar(
        title: Text('Retrieve Text Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: <Widget> [

                // input
                TextField(
                  // maxLines: 5,
                  controller: myController,
                ),

                // button to split the text
                RaisedButton(

                  onPressed: () {
                    
                    List list = myController.text.split("."); 
                    // list = list.split(",");

                    setState(() {
                      lines = list;   
                    });

                    // print(lines[0]);

                  },
                  child: Text("Split text"),
                ),

                // number of splitter
                Text(lines.length > 0 ? "There are " + (lines.length.toString()) + " sentences" : "No text yet"),

                // Text(previousTextAsString() + (lines.length > 0 ? lines[wordIndex] : "") + nextTextAsString()),

                // Text to read
                RichText(
                  text: new TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: new TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      // new TextSpan(text: 'Hello'),
                      TextSpan(text: previousTextAsString(), ),

                      TextSpan(text: (lines.length > 0 ? lines[wordIndex] : ""), style: TextStyle(backgroundColor: Colors.yellow, fontSize: 40)),

                      TextSpan(text: nextTextAsString()),

                    ],
                  ),
                ),

                // // display previoues words
                // Text(previousTextAsString(), style: TextStyle(backgroundColor: Colors.green)),

                // // displaying word
                // Text(lines.length > 0 ? lines[wordIndex] : "", style: TextStyle(backgroundColor: Colors.yellow, fontSize: 40),),


                // // display next words
                // Text(nextTextAsString(), style: TextStyle(backgroundColor: Colors.red[100])),


                // speak the word
                if (lines.length > 0) 

                  // Speak(
                  //   text: lines[wordIndex],
                  //   correctSpeak: correctSpeak,
                  // )
                  // control buttons
                  Row(

                    mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,

                    children: <Widget>[

                    // listen to the word
                    // if (lines.length > 0) 

                      RaisedButton(
                        onPressed: () => _speak(lines[wordIndex]),
                        child: Text("How to pronounce it?"),
                      ),


                      // start speaching
                      RaisedButton(
                        child: Text('Start'),
                        onPressed: !_hasSpeech || speech.isListening
                            ? null
                            : startListening,
                      ),

                      // // stop speech
                      // RaisedButton(
                      //   child: Text('Stop'),
                      //   onPressed: speech.isListening ? stopListening : null,
                      // ),

                    ],
                  ),

                // user speech
                Text(
                  lastWords!= null ? lastWords : "",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22),
                ),
                // Text("OAJSDIOJASD"),

                // Text(wordIndex.toString()),
                
                // control words
                Row(

                    mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,

                    children: <Widget>[

                      // previoues word
                      RaisedButton(
                        // onPressed: () => setState(() {wordIndex -= 1;}),
                        onPressed: () {

                          if (wordIndex > 0)

                            setState(() {wordIndex -= 1;});

                        },
                        child: Text("Previous word"),
                      ),

                      // next word
                      RaisedButton(
                        onPressed: () {

                          if (wordIndex < (lines.length-1))

                            setState(() {wordIndex += 1;});

                        },
                        child: Text("Next word"),
                      ),

                    ]

                ),

                // list of sentences
                // ConstrainedBox(
                //   constraints: BoxConstraints(maxHeight: 300, minHeight: 56.0),
                //   child: ListView.builder(
                //     shrinkWrap: true,
                //     itemBuilder: (BuildContext context, int index) {

                //       return Column(children: <Widget>[

                        
                //         // // number
                //         // CircleAvatar(
                //         //   backgroundColor: Colors.cyan,
                //         //   child: Text(index.toString()),
                //         // ),

                //         // text
                //         Text(lines[index]),

                //         // // speak
                //         // Speak(
                //         //   text: lines[index],
                //         // ),

                //         ],
                //       );

                //     },
                //     itemCount: lines.length,
                //   ),
                // ),
                
                
            ]
        )
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () {
          return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Retrieve the text the that user has entered by using the
                // TextEditingController.
                content: Text(myController.text),
              );
            },
          );
        },
        tooltip: 'Show me the value!',
        child: Icon(Icons.text_fields),
      ),
    );
  }
}