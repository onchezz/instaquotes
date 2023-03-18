import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:instaquotes/quote.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();

  bool isPlaying = true;

  Future<Quote> getdata() async {
    var response = await http.get(Uri.parse('https://api.quotable.io/random/'));

    if (response.statusCode == 200) {
      var data = Quote.fromJson(jsonDecode(response.body));

      return data;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future _speak(String? voiceMessage) async {
    _stop();
    if (voiceMessage != null) {
      if (voiceMessage.isNotEmpty) {
        await flutterTts.speak(voiceMessage);
        isPlaying = true;
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) isPlaying = false;
  }

  @override
  void initState() {
    getdata();
    super.initState();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: FutureBuilder<Quote>(
        future: getdata(),
        builder: (_, snapshot) {
          String? randomQouteText = snapshot.data?.quote;
          String? randomQouteAuthor = snapshot.data?.author;
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(255, 173, 174, 245),
                          spreadRadius: 4,
                          blurRadius: 4,
                          offset: Offset(4, 6))
                    ]),
                padding: const EdgeInsets.all(20),
                width: screenWidth,
                height: screenHeight * 0.6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.format_quote_sharp,
                          size: 30,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      //quote text
                      Expanded(
                        child: SingleChildScrollView(
                          child: randomQouteText != null
                              ? Text(
                                  randomQouteText,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.format_quote_sharp,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),

                      //author text
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          randomQouteAuthor != null
                              ? '--- ' + randomQouteAuthor
                              : '--- Loading...',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w100,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            getdata();
                            setState(() {});
                            _stop();
                          },
                          child: const Text('New Quote'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: Size(
                                  screenWidth * 0.9, screenHeight * 0.07))),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await _speak(randomQouteText);
                            },
                            icon: Icon(
                              Icons.volume_up,
                              color: Colors.blueAccent.shade200,
                            ),
                            iconSize: 60,
                          ),
                          IconButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                      ClipboardData(text: randomQouteText))
                                  .then((_) => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Quote copied to clip board"))));
                            },
                            icon: Icon(
                              Icons.copy,
                              color: Colors.blueAccent.shade200,
                            ),
                            iconSize: 60,
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.share,
                          //     color: Colors.blueAccent.shade200,
                          //   ),
                          //   iconSize: 60,
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }
}
