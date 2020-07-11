import "package:flutter/material.dart";
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'dart:math';

// ways to say correct
// import "../constants.dart" as Constant;

// randome numbers
// import 'dart:math';

// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';


class Speak extends StatefulWidget {

  // final component;
  // final speaking;
  // final userSpeech;
  final text;
  final correctSpeak;

  const Speak ({ 
    Key key, 
    this.text,
    this.correctSpeak,
    // this.component,
    // this.speaking,
    // this.userSpeech,

  }): super(key: key);

  @override _SpeakState createState() => _SpeakState();
  
}

class _SpeakState extends State<Speak> {


  final SpeechToText speech = SpeechToText();

  // String lastError = "";
  // String lastStatus = "";

  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = null;
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];

  var answerIsCorrect;
  bool displayChecking;

  // initi state
  @override
  void initState() {

    super.initState();

    answerIsCorrect = null;
    displayChecking = false;

  }

  
  Future<void> initSpeechState() async {

    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      // _localeNames = await speech.locales();

      // var systemLocale = await speech.systemLocale();
      // _currentLocaleId = systemLocale.localeId;
      _currentLocaleId = "en_US";
    }
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
        listenFor: Duration(seconds: 10),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true);
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

      // print("SOME FINAL RESULT");
      if (result.recognizedWords.toLowerCase() == widget.text.toLowerCase()) {
        print("CORRECT!");

        setState(() {
          // lastWords = "${result.recognizedWords} - ${result.finalResult}";
          lastWords = "${result.recognizedWords}";
          answerIsCorrect = false;
          displayChecking = true;
        });

        widget.correctSpeak(true);

      }
      else {
        print("wrong!");

        setState(() {
          // lastWords = "${result.recognizedWords} - ${result.finalResult}";
          lastWords = "${result.recognizedWords}";
          answerIsCorrect = true;
          displayChecking = true;
        });

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

  // _switchLang(selectedVal) {
  //   setState(() {
  //     _currentLocaleId = selectedVal;
  //   });

  //   print(selectedVal);;
  // }

  @override
  Widget build(BuildContext context) {

    // initialize microphone
    initSpeechState();

    return (

      Column(children: [

        // instruction
        // Text(widget.component["instruction"]),

        // control buttons
        Row(

          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,

          children: <Widget>[

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
          
        // // Button to check the answer
        // FlatButton(
        //   onPressed: () {

        //     // correct answer
        //     if (lastWords.toLowerCase() == widget.text.toLowerCase()) {

        //       widget.correctSpeak(true);
              
        //       // print("correct answer");
        //       setState(() {
        //         answerIsCorrect = true;
        //         displayChecking = true;
        //       });

        //     }

        //     else {
        //       setState(() {
        //         answerIsCorrect = false;
        //         displayChecking = true;
        //       });
        //     }

        //     // reste the answer and alternatives
        //       Future.delayed(const Duration(milliseconds: 1200), ()=> {
        //         setState(() {
        //           displayChecking = false; 
        //           // userAnswer = userAnswerDefault;
        //           answerIsCorrect = null;
        //         })
        //       });

            
        //   }, 

        //   child: Text("CLICK HERE TO CHECK THE ANSWER"),

        // ),

        // // displa if answer is correct
        // if (lastWords != null && answerIsCorrect != null && displayChecking)
        
        // (
          
        //   answerIsCorrect 
        
        //   ? 
          
        //     Text(
        //       // Constant.waysToSayCorrect[new Random().nextInt(Constant.waysToSayCorrect.length)], 
        //       // Constant.waysToSayCorrect[0],
        //       "very good",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.green,
        //         fontSize: 30,
        //       )
        //     ) 
            
        //   : 
          
        //     Text(
        //       "Ups, It is not correct! Try it again!",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.red,
        //         fontSize: 20,
        //       )  
        //     )
            
        // )
          
        // , 

      ])
    
    );
    
  }

}