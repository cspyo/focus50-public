import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/models/todo_model.dart';
import 'package:focus42/utils/signaling.dart';
import 'package:focus42/widgets/todo_popup_widget.dart';
import 'package:focus42/widgets/todo_ui.dart';
import 'package:logger/logger.dart';

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
  final _formKey = GlobalKey<FormState>();
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  final ReservationModel session;
  bool isMicOn = true;
  bool isCamOn = true;

  final _user = FirebaseAuth.instance;
  final _todoColRef =
      FirebaseFirestore.instance.collection('todo').withConverter<TodoModel>(
            fromFirestore: TodoModel.fromFirestore,
            toFirestore: (TodoModel todoModel, _) => todoModel.toFirestore(),
          );
  late final Stream<QuerySnapshot> _myTodoColRef;
  List<TodoModel> myTodo = [];

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

    // myTodoColRef
    _myTodoColRef = _todoColRef
        .where('userUid', isEqualTo: _user.currentUser?.uid)
        .where('assignedSessionId', isEqualTo: session.pk!)
        .orderBy('completedDate')
        .orderBy('modifiedDate', descending: true)
        .orderBy('createdDate', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    signaling.hangUp(_localRenderer);
    var logger = Logger();
    logger.d("disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _myTodoColRef,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          var logger = Logger();
          logger.e(snapshot.error);
          return Text('오류가 났어요 ㅠㅠ');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("");
        }
        myTodo.clear();
        snapshot.data!.docs.forEach((doc) {
          final TodoModel todo = doc.data() as TodoModel;
          todo.pk = doc.id;
          myTodo.add(todo);
        });
        return Scaffold(
          body: Column(
            children: [
              SizedBox(height: 8),
              Expanded(
                  child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1.5, color: border100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 6),
                                      ),
                                    ]),
                                child: RTCVideoView(
                                  _localRenderer,
                                  mirror: true,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                )),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (isCamOn)
                                  ? CircleAvatar(
                                      backgroundColor: purple200,
                                      child: IconButton(
                                        icon: const Icon(Icons.videocam),
                                        color: Colors.white,
                                        tooltip: '카메라 끄기',
                                        onPressed: () {
                                          // Cam Off 하려고 클릭
                                          signaling.turnOffUserCamera(
                                              _localRenderer, _remoteRenderer);
                                          setState(() {
                                            isCamOn = false;
                                          });
                                        },
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: purple200,
                                      child: IconButton(
                                        icon: const Icon(Icons.videocam_off),
                                        color: Colors.white,
                                        tooltip: '카메라 켜기',
                                        onPressed: () {
                                          // Cam On 하려고 클릭
                                          signaling.turnOnUserCamera(
                                              _localRenderer, _remoteRenderer);
                                          setState(() {
                                            isCamOn = true;
                                          });
                                        },
                                      ),
                                    ),
                              SizedBox(
                                width: 8,
                              ),
                              (isMicOn)
                                  ? CircleAvatar(
                                      backgroundColor: purple200,
                                      child: IconButton(
                                        icon: const Icon(Icons.mic),
                                        color: Colors.white,
                                        tooltip: '마이크 끄기',
                                        onPressed: () {
                                          // Mic Off 하려고 클릭
                                          signaling.turnOffUserMic(
                                              _localRenderer, _remoteRenderer);
                                          setState(() {
                                            isMicOn = false;
                                          });
                                        },
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: purple200,
                                      child: IconButton(
                                        icon: const Icon(Icons.mic_off),
                                        color: Colors.white,
                                        tooltip: '마이크 켜기',
                                        onPressed: () {
                                          // Mic On 하려고 클릭
                                          signaling.turnOnUserMic(
                                              _localRenderer, _remoteRenderer);
                                          setState(() {
                                            isMicOn = true;
                                          });
                                        },
                                      ),
                                    ),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1.5, color: border100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 6),
                                      ),
                                    ]),
                                child: RTCVideoView(
                                  _remoteRenderer,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: _todoCurrent(context),
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CountDownTimer(
                                  duration: Duration(minutes: 50),
                                  startTime: session.startTime!,
                                ),
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _todoCurrent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 27),
      child: Column(children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                    child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.transparent))),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(purple200),
                  ),
                  child: Text(
                    '이번 세션 할 일',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
              ),
            ],
          ),
        ),
        for (var i = 0; i < myTodo.length; i++)
          Expanded(
            child: TodoUi(
              task: myTodo[i].task!,
              isComplete: myTodo[i].isComplete!,
              createdDate: Timestamp.fromDate(myTodo[i].createdDate!),
              userUid: myTodo[i].userUid!,
              docId: myTodo[i].pk!,
              assignedSessionId: session.pk!,
            ),
          ),
        Container(
          width: 380,
          height: 80,
          // margin: EdgeInsets.only(top: 32),
          padding: EdgeInsets.only(top: 15),
          child: TextButton(
              onPressed: () => {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Positioned(
                                  right: -40.0,
                                  top: -40.0,
                                  child: InkResponse(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: CircleAvatar(
                                      child: Icon(Icons.close),
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                                TodoPopup(
                                  session: session,
                                ),
                              ],
                            ),
                          );
                        })
                  },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: Colors.transparent))),
                backgroundColor: MaterialStateProperty.all<Color>(purple300),
              ),
              child: Text('전체목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ))),
        ),
      ]),
    );
  }
}
