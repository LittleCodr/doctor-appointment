import 'package:doctro/VideoCall/overlay_handler.dart';
import 'package:doctro/VideoCall/overlay_service.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/doctor_profile.dart';
import 'package:doctro/model/setting.dart';
import 'package:doctro/model/video_call_history_add_model.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/screens/home page/login_home.dart';
import 'package:doctro/screens/videoCall/model/doctorAgoraTokenGenerateModel.dart';

class VideoCall extends StatefulWidget {

  final bool callEnd;
  final int? id;
  final String? flag;

  VideoCall({
    required this.callEnd,
    this.id,
    this.flag,
  });
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool muted = false;
  bool mutedVideo = false;
  late RtcEngine _engine;
  String? appId;
  int uid = 0;
  String? token;
  String? channelName;
  int? doctorId = 0;
  ChannelMediaOptions options = const ChannelMediaOptions(
    clientRoleType: ClientRoleType.clientRoleBroadcaster,
    channelProfile: ChannelProfileType.channelProfileCommunication,
  );

  int? callDuration = 0;
  String? callTime = "";
  String? callDate = "";

  @override
  void initState() {
    debugPrint("Call End : ${widget.callEnd}\tID : ${widget.id}\tFlag : ${widget.flag}");
    super.initState();
    settingRequest();
    offset = const Offset(20.0, 50.0);
  }

  Offset offset = Offset.zero;
  int? boxNumberIsDragged;

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
                    color: muted ? colorWhite : loginButton,
                    size: overlayProvider.inPipMode == true ? 12.0 : 15.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? loginButton : colorWhite,
                  padding: EdgeInsets.all(overlayProvider.inPipMode == true ? 5.0 : 12.0),
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: () => _onCallEnd(context),
                  child: Icon(
                    Icons.call_end,
                    color: colorWhite,
                    size: overlayProvider.inPipMode == true ? 15.0 : 30.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: red,
                  padding: EdgeInsets.all(overlayProvider.inPipMode == true ? 5.0 : 15.0),
                ),
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: Icon(
                    Icons.switch_camera,
                    color: loginButton,
                    size: overlayProvider.inPipMode == true ? 12.0 : 15.0,
                  ),
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: colorWhite,
                  padding: EdgeInsets.all(overlayProvider.inPipMode == true ? 5.0 : 12.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCallEnd(BuildContext context) {
    setState(() {
      _localUserJoined = false;
      _remoteUid = null;
      _engine.leaveChannel();
    });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
      _engine.muteLocalAudioStream(muted);
    });
  }

  void _onSwitchCamera() {
    setState(() {
      _engine.switchCamera();
    });
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await createAgoraRtcEngine();
    await _engine.initialize(
        RtcEngineContext(appId: appId != null ? appId : SharedPreferenceHelper.getString(Preferences.agoraAppId)));
    await _engine.enableVideo();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid : ${connection.localUid} joined the channel");
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
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
            _engine.leaveChannel();
            Fluttertoast.showToast(msg: "Call Ended", toastLength: Toast.LENGTH_SHORT);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats details) {
          setState(() {
            if (widget.flag == "OutGoing") {
              callDuration = details.duration;
              OverlayService().removeVideosOverlay(
                  context,
                  VideoCall(
                    id: widget.id,
                    callEnd: false,
                  ));
            } else {
              callDuration = details.duration;
              if (callTime != "" && callDate != "" && widget.callEnd == false) {
                callApiAddVideoCallHistory();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginHomeScreen(chat: "")));
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginHomeScreen(chat: "")));
              }
            }
          });
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
                      color: grey,
                      child: Center(
                        child: _remoteVideo(),
                      ),
                    ),
                    widget.callEnd == true
                        ? Container()
                        : Stack(
                            children: [
                              Positioned(
                                left: offset.dx,
                                top: offset.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      if (offset.dx > 0.0 &&
                                          (offset.dx + 150) < width &&
                                          offset.dy > 0.0 &&
                                          (offset.dy + 200) < height) {
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
                                          child: _localUserJoined ? _localPreview() : const CircularProgressIndicator(),
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

  Future<BaseModel<DoctorProfile>> doctorProfile() async {
    DoctorProfile response;
    try {
      response = await RestClient(RetroApi().dioData()).doctorProfile();
      if (response.success == true) {
        token = response.data!.agoraToken;
        channelName = response.data!.channelName;
        doctorId = response.data!.id;
        await initAgora();
      }
      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<VideoCallModel>> agoraTokenGenerateDoctor() async {
    VideoCallModel response;
    Map<String, dynamic> body = {"to_id": widget.id};
    try {
      response = await RestClient(RetroApi().dioData()).generateDoctorAgoraTokenCall(body);
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

  Future<BaseModel<Setting>> settingRequest() async {
    Setting response;
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      appId = response.data!.agoraAppId;
      if (widget.flag != "OutGoing") {
        await doctorProfile();
      } else {
        await agoraTokenGenerateDoctor();
      }
      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<VideoCallHistoryAddModel>> callApiAddVideoCallHistory() async {
    VideoCallHistoryAddModel response;
    Map<String, dynamic> body = {
      "user_id": widget.id,
      "date": callDate,
      "start_time": callTime,
      "duration": callDuration,
      "doctor_id": doctorId,
    };
    try {
      response = await RestClient(RetroApi().dioData()).videoCallHistoryAddRequest(body);
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
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
    print(
        'App ID : $appId\t Flag: ${widget.flag}\nChannel Name: ${channelName}\nTocken : ${token}\nRemote UID : ${_remoteUid}');
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return widget.callEnd == true
          ? ScalingText(
              getTranslated(context, AppString.disconnect_call).toString(),
              style: TextStyle(fontSize: 16, color: cardText),
            )
          : widget.flag == "OutGoing"
              ? ScalingText(
                  getTranslated(context, AppString.ringing).toString(),
                  style: TextStyle(fontSize: 16, color: cardText),
                )
              : ScalingText(
                  getTranslated(context,AppString.connect_call).toString(),
                  style: TextStyle(fontSize: 16, color: cardText),
                );
    }
  }
}