import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': "turn:13.124.180.232:3478",
        'username': "focusmaker",
        'credential': "focusmaker423",
      }
    ],
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  static String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;
  bool _isOpenMic = false;
  bool _isOpenCamera = false;
  var logger = Logger();

  Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    var _roomId = roomRef.id;
    roomId = _roomId;
    currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
    };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        await peerConnection?.setRemoteDescription(answer);
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
    // Listen for remote ICE candidates above

    return _roomId;
  }

  Future<void> joinRoom(String _roomId, RTCVideoRenderer remoteVideo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    roomId = _roomId;
    DocumentReference roomRef = db.collection('rooms').doc('$roomId');
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      await doJoin(roomRef);
    } else {
      var roomListener;
      roomListener = db.collection('rooms').snapshots().listen((querySnapshot) {
        querySnapshot.docChanges.forEach((element) async {
          if (element.type == DocumentChangeType.added) {
            if (element.doc.id == roomId) {
              await doJoin(roomRef);
              roomListener.cancel();
            }
          }
        });
      });
    }
  }

  Future<void> doJoin(DocumentReference roomRef) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot roomSnapshot = await transaction.get(roomRef);
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        event.streams[0].getTracks().forEach((track) {
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await transaction.update(roomRef, roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    });
  }

  Future<void> recreateRoom() async {
    //* hang up 참고하여 수정
    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
      remoteStream = null;
    }
    if (peerConnection != null) await peerConnection!.dispose();

    //* createRoom 참고하여 수정
    FirebaseFirestore db = FirebaseFirestore.instance;
    assert(roomId != null, 'roomId should be not null');
    DocumentReference roomRef = db.collection('rooms').doc('$roomId');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.get(roomRef);
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var callerCandidatesCollection = roomRef.collection('callerCandidates');

      peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        callerCandidatesCollection.add(candidate.toMap());
      };
      // Finish Code for collecting ICE candidate

      // Add code for creating a room
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);

      Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

      await transaction.set(roomRef, roomWithOffer);
      currentRoomText = 'Current room is $roomId - You are the caller!';
      // Created a Room

      peerConnection?.onTrack = (RTCTrackEvent event) {
        event.streams[0].getTracks().forEach((track) {
          remoteStream?.addTrack(track);
        });
      };

      // Listening for remote session description below
      roomRef.snapshots().listen((snapshot) async {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (peerConnection?.getRemoteDescription() != null &&
            data['answer'] != null) {
          var answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );

          await peerConnection?.setRemoteDescription(answer);
        }
      });
      // Listening for remote session description above

      // Listen for remote Ice candidates below
      roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            Map<String, dynamic> data =
                change.doc.data() as Map<String, dynamic>;
            peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        });
      });
      // Listen for remote ICE candidates above
    });
  }

  //* MediaStream 단의 객체
  //* localStream (class member)
  //* remoteStream (class member)
  //* navigator.mediaDevices.getUserMedia
  //* remoteVideo(:RTCVideoRenderer).srcObject

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    _isOpenMic = true;
    _isOpenCamera = true;

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> turnOnUserCamera(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    localVideo.srcObject!.getVideoTracks()[0].enabled = true;
  }

  Future<void> turnOffUserCamera(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    localVideo.srcObject!.getVideoTracks()[0].enabled = false;
  }

  Future<void> turnOnUserMic(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    localVideo.srcObject!.getAudioTracks()[0].enabled = true;
  }

  Future<void> turnOffUserMic(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    localVideo.srcObject!.getAudioTracks()[0].enabled = false;
  }

  void peerClose() {
    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();
  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    tracks.forEach((track) {
      track.stop();
    });

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      calleeCandidates.docs.forEach((document) => document.reference.delete());

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      callerCandidates.docs.forEach((document) => document.reference.delete());

      await roomRef.delete();
    }

    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      logger.d("peerConnection?.onIceGatheringState : ${state}");
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) async {
      logger.d("peerConnection?.onConnectionState ${state}");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        recreateRoom();
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      logger.d("peerConnection?.onSignalingState ${state}");
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      logger.d("peerConnection?.onIceGatheringState ${state}");
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      logger.d("peerConnection?.onAddStream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
