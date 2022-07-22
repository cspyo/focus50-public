import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus42/consts/colors.dart';
import 'package:focus42/consts/routes.dart';
import 'package:focus42/models/reservation_model.dart';
import 'package:focus42/models/todo_model.dart';
import 'package:focus42/resources/matching_methods.dart';
import 'package:focus42/utils/signaling.dart';
import 'package:focus42/widgets/countdown_timer_widget.dart';
import 'package:focus42/widgets/todo_popup_widget.dart';
import 'package:focus42/widgets/todo_session_ui.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
    _localRenderer.initialize().then((value) {
      _remoteRenderer.initialize().then((value) {
        MatchingMethods()
            .enterRoom(session.pk!, signaling, _localRenderer, _remoteRenderer);
      });
    });

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();

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
    print("SessionScreen disposed");
    signaling.hangUp(_localRenderer);
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
          backgroundColor: blackSession,
          body: Column(
            children: [
              // SizedBox(height: 8),
              Expanded(
                  child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32)),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.25),
                                  //     spreadRadius: 0,
                                  //     blurRadius: 4,
                                  //     offset: Offset(0, 6),
                                  //   ),
                                  // ]
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32)),
                                  child: RTCVideoView(
                                    _localRenderer,
                                    mirror: true,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            child: Container(
                                // padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // border: Border.all(
                                  //     width: 1.5, color: border100),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32)),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.25),
                                  //     spreadRadius: 0,
                                  //     blurRadius: 4,
                                  //     offset: Offset(0, 6),
                                  //   ),
                                  // ]
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32)),
                                  child: RTCVideoView(
                                    _remoteRenderer,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                  ),
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
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.videocam),
                                        color: blackSession,
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
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.videocam_off),
                                        color: blackSession,
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
                                width: 16,
                              ),
                              (isMicOn)
                                  ? CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.mic),
                                        color: blackSession,
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
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.mic_off),
                                        color: blackSession,
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
                                width: 16,
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.red[400],
                                child: IconButton(
                                  icon: const Icon(Icons.cancel),
                                  color: Colors.white,
                                  tooltip: '나가기',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "정말 방을 나가시겠습니까?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 17,
                                                color: Colors.black),
                                          ),
                                          content: Text(
                                            "한번 나간 방은 다시 입장하실 수 없습니다",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text(
                                                "네",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: purple300),
                                              ),
                                              onPressed: () {
                                                Get.rootDelegate
                                                    .toNamed(Routes.CALENDAR);
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                "아니요",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: purple300),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop('dialog');
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: _todoCurrent(context),
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              // width: 450,
                              margin: EdgeInsets.only(left: 8, right: 8),
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CountDownTimer(
                                  duration: Duration(minutes: 50),
                                  startTime: session.startTime!,
                                ),
                              ),
                            )),
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
      margin: EdgeInsets.only(top: 8, right: 8, left: 8),
      width: 420,
      height: 350,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Container(
          margin: EdgeInsets.only(top: 15),
          child: Text('이번 세션 할 일',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: blackSession,
              )),
        ),
        Container(
          width: 380,
          height: 60,
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
                backgroundColor: MaterialStateProperty.all<Color>(blackSession),
              ),
              child: Text('전체목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ))),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          height: 230,
          width: 380,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: myTodo.length,
              itemBuilder: (BuildContext context, int index) {
                return TodoSessionUi(
                  task: myTodo[index].task!,
                  isComplete: myTodo[index].isComplete!,
                  createdDate: Timestamp.fromDate(myTodo[index].createdDate!),
                  userUid: myTodo[index].userUid!,
                  docId: myTodo[index].pk!,
                  assignedSessionId: session.pk!,
                );
              }),
        ),
      ]),
    );
  }
}
