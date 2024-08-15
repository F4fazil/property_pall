import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class CallPage extends StatefulWidget {

  const CallPage({
    Key? key,

  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  bool _joinedChannel = false;
  int? _remoteUid;
  bool _muted = false;
  bool _cameraFront = true;
  bool _speakerOn = true;
  final String appId = '3540825240994d57a213156e10845438';
  final String token =
      "007eJxTYMjWEp/xf/+r2d1yMy9xl/MsPGComJ2y9c7vcHFzmaMGE+8qMCQamRikJJsnpSSam5gkWZpZppmlmaSZmyWapBobAkWz5qxLawhkZLhTxMLACIUgPg9DQVF+QWpRSWVBYk4OAwMAaXIjPQ==";
  final String channelName = 'propertypall';
  final String _appCertficate = "3540825240994d57a213156e10845438";


  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Request camera and microphone permissions
    await _handleCameraAndMicrophonePermissions();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId:appId ,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine.enableVideo();

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _joinedChannel = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        setState(() {
          _remoteUid = null;
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        // Handle leaving the channel
        setState(() {
          _joinedChannel = false;
          _remoteUid = null;
        });
      },
    ));

    await _joinChannel();
  }

  Future<void> _handleCameraAndMicrophonePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      // Handle permission denied
    }
  }

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
    await _engine.startPreview();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
    setState(() {
      _cameraFront = !_cameraFront;
    });
  }

  void _onToggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
    });
    _engine.setEnableSpeakerphone(_speakerOn);
  }

  void _onEndCall() {
    _engine.leaveChannel();
    Navigator.pop(context);
  }

  Widget _renderLocalPreview() {
    return _joinedChannel
        ? AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _renderRemoteVideo() {
    return _remoteUid != null
        ? AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: channelName),
      ),
    )
        : const Center(
      child: Text(
        'Connecting....',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              color: _muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: _muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onEndCall,
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleSpeaker,
            child: Icon(
              _speakerOn ? Icons.volume_up : Icons.volume_off,
              color: _speakerOn ? Colors.blueAccent : Colors.white,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: _speakerOn ? Colors.white : Colors.blueAccent,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        },
          icon: Icon(Icons.arrow_back_ios_rounded,color: Colors.indigo.shade200,),
        ),
        title: const Text(' Video Call'),
      ),
      body: Stack(
        children: [
          _renderRemoteVideo(),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 120,
              height: 160,
              margin: const EdgeInsets.all(8.0),
              child: _renderLocalPreview(),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }
}
