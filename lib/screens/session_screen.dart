import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/utils/signaling.dart';

import '../models/reservation_model.dart';
import '../resources/matching_methods.dart';
import '../widgets/countdown_timer_widget.dart';

class SessionScreen extends StatelessWidget {
  final ReservationModel session;
  const SessionScreen({Key? key, required ReservationModel this.session})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SessionPage(session: session),
    );
  }
}

class SessionPage extends StatefulWidget {
  final ReservationModel session;
  SessionPage({Key? key, required this.session}) : super(key: key);

  @override
  _SessionPageState createState() => _SessionPageState(session: session);
}

class _SessionPageState extends State<SessionPage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  final ReservationModel session;

  _SessionPageState({required this.session}) : super();

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();
    MatchingMethods()
        .enterRoom(session.pk!, signaling, _localRenderer, _remoteRenderer);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                ),
                onPressed: () {
                  signaling.openUserMedia(_localRenderer, _remoteRenderer);
                },
                child: Text("Open camera & microphone"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                ),
                onPressed: () {
                  signaling.toggleUserCamera(_localRenderer, _remoteRenderer);
                },
                child: Text("toggle camera"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                ),
                onPressed: () {
                  signaling.toggleUserMic(_localRenderer, _remoteRenderer);
                },
                child: Text("toggle microphone"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                ),
                onPressed: () async {
                  roomId = await signaling.createRoom(_remoteRenderer);
                  textEditingController.text = roomId!;
                  setState(() {});
                },
                child: Text("Create room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                ),
                onPressed: () {
                  // Add roomId
                  signaling.peerClose();
                  signaling.joinRoom(
                    textEditingController.text,
                    _remoteRenderer,
                  );
                },
                child: Text("Join room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: purple300,
                ),
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: Text("Hangup"),
              )
            ],
          ),
          SizedBox(height: 8),
          Expanded(
              child: Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: blackCustomized,
                                  width: 0.5,
                                )),
                            child: RTCVideoView(_localRenderer, mirror: true)),
                      ),
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: blackCustomized,
                                  width: 0.5,
                                )),
                            child: RTCVideoView(_remoteRenderer)),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          "TODO",
                          textAlign: TextAlign.center,
                        )),
                    Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(
                          //       color: blackCustomized,
                          //       width: 0.5,
                          //     )),
                          alignment: Alignment.center,
                          child: CountDownTimer(
                            duration: Duration(minutes: 50),
                            startTime: session.startTime!,
                          ),
                        ))
                  ],
                ),
              )
            ],
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
