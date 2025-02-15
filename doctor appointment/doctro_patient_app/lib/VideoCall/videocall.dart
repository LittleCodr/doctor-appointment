import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

import 'package:doctro_patient/Screen/Screens/Home.dart';
import 'package:doctro_patient/VideoCall/overlay_handler.dart';
import 'package:doctro_patient/VideoCall/overlay_service.dart';
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/user_detail_model.dart';
import 'package:doctro_patient/model/video_call_model.dart';

class VideoCall extends StatefulWidget {
  final int? doctorId;
  final String? flag;

  VideoCall({this.doctorId, this.flag});

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool muted = false;
  bool mutedVideo = false;
  late RtcEngine _engine;
  String? appId = SharedPreferenceHelper.getString(Preferences.agoraAppId);
  String? token = "";
  String? channelName = "";
  int? callDuration = 0;
  bool? timeOut = false;
  int uid = 0;
  ChannelMediaOptions options = const ChannelMediaOptions(
    clientRoleType: ClientRoleType.clientRoleBroadcaster,
    channelProfile: ChannelProfileType.channelProfileCommunication,
  );

  @override
  void initState() {
    debugPrint("Doctor ID : ${widget.doctorId}\tFlag : ${widget.flag}");
    super.initState();
    if (widget.flag == "InComming") {
      callApiUserProfile();
    } else if (widget.flag == "Cut") {
      callApiUserProfile();
    } else {
      callApiVideoCallToken();
    }
    offset = const Offset(20.0, 50.0);
  }

  Offset offset = Offset.zero;

  Widget _toolbar() {
    return Consumer<OverlayHandlerProvider>(
      builder: (context, overlayProvider, _) {
        return Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(vertical: overlayProvider.inPipMode == true ? 20 : 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Palette.white : Palette.blue,
                    size: overlayProvider.inPipMode == true ? 12.0 : 15.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? Palette.blue : Palette.white,
                  padding: EdgeInsets.all(overlayProvider.inPipMode == true ? 5.0 : 12.0),
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: Icon(
                    Icons.call_end,
                    color: Palette.white,
                    size: overlayProvider.inPipMode == true ? 15.0 : 30.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: Palette.red,
                  padding: EdgeInsets.all(overlayProvider.inPipMode == true ? 5.0 : 15.0),
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: Icon(
                    Icons.switch_camera,
                    color: Palette.blue,
                    size: overlayProvider.inPipMode == true ? 12.0 : 15.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: Palette.white,
                  padding: EdgeInsets.all(overlayProvider.inPipMode == true ? 5.0 : 12.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? callTime = "";
  String? callDate = "";

  void _onCallEnd(BuildContext context) async {
    await _engine.leaveChannel();
    setState(() { 
      _localUserJoined = false;
      _remoteUid = null;
    });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId!,
    ));
    await _engine.enableVideo();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
          DateTime now = DateTime.now();
          callTime = DateFormat('h:mm a').format(now);
          callDate = DateFormat('yyyy-MM-dd').format(now);
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
            _engine.leaveChannel();
            Fluttertoast.showToast(msg: "Call Ended",toastLength: Toast.LENGTH_SHORT);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats detail) {
          if (widget.flag == "InComming") {
            setState(() {
              callDuration = detail.duration;
              if (callTime != "" && callDate != "") {
                Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => Home()));
              } else {
                Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => Home()));
              }
            });
          } else if (widget.flag == "Cut") {
            setState(() {
              callDuration = detail.duration;
              if (callTime != "" && callDate != "") {
                Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => Home()));
              } else {
                Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => Home()));
              }
            });
          } else {
            setState(() {
              callDuration = detail.duration;
              OverlayService().removeVideosOverlay(context, VideoCall(doctorId: widget.doctorId));
            });
          }
        },
      ),
    );

    await _engine.startPreview();
    _engine.joinChannel(
      token: '$token',
      channelId: '$channelName',
      uid: uid,
      options: options,
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _engine.leaveChannel();
    await _engine.release();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return PIPView(
      builder: (context, isFloating) {
        return Scaffold(
          body: Consumer<OverlayHandlerProvider>(
            builder: (context, overlayProvider, _) {
              return InkWell(
                onTap: () {
                  Provider.of<OverlayHandlerProvider>(context, listen: false).disablePip();
                },
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: _remoteVideo(),
                      ),
                    ),
                    widget.flag == "Cut"
                        ? Container()
                        : Stack(
                      children: [
                        Positioned(
                          left: offset.dx,
                          top: offset.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                if (offset.dx > 0.0 && (offset.dx + 150) < width && offset.dy > 0.0 && (offset.dy + 200) < height) {
                                  offset = Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                                } else {
                                  offset = Offset(details.delta.dx + 20, details.delta.dy + 50);
                                }
                              });
                            },
                            child: Consumer<OverlayHandlerProvider>(
                              builder: (context, overlayProvider, _) {
                                return SizedBox(
                                  width: overlayProvider.inPipMode == true ? 80 : 150,
                                  height: overlayProvider.inPipMode == true ? 80 : 200,
                                  child: Center(
                                    child: _localUserJoined
                                        ? _localPreview()
                                        : const CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    _toolbar(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _localPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _remoteVideo() {
    print('App ID : $appId\tFlag: ${widget.flag}\nChannel Name: ${channelName}\nTocken : ${token}\nRemote UID : ${_remoteUid}');
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      if (widget.flag == "InComming") {
        return ScalingText(
          'Connecting...',
          style: TextStyle(fontSize: 16, color: Palette.dark_blue),
        );
      } else if (widget.flag == "Cut") {
        return ScalingText(
          'Call Ended...',
          style: TextStyle(fontSize: 16, color: Palette.dark_blue),
        );
      } else {
        return ScalingText(
          'Ringing...',
          style: TextStyle(fontSize: 16, color: Palette.dark_blue),
        );
      }
    }
  }

  Future<BaseModel<VideoCallModel>> callApiVideoCallToken() async {
    VideoCallModel response;
    Map<String, dynamic> body = {
      "to_id": widget.doctorId,
    };
    try {
      response = await RestClient(RetroApi().dioData()).videoCallRequest(body);
      if (response.success == true) {
        channelName = response.data!.cn;
        token = response.data!.token;
        await initAgora();
      }
      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<UserDetail>> callApiUserProfile() async {
    UserDetail response;
    try {
      response = await RestClient(RetroApi().dioData()).userDetailRequest();
      if(response.status == 1){
        channelName = response.channelName!;
        token = response.agoraToken;
        await initAgora();
      }
      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}