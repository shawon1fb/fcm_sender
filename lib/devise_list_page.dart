import 'dart:convert';

import 'package:flutter/material.dart';

import 'cinfig.dart';
import 'device_model.dart';
import 'fcm_notification_model.dart';
import 'package:http/http.dart' as http;

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({Key? key}) : super(key: key);

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  @override
  void initState() {
    getModelData();
    super.initState();
  }

  sendAndRetrieveMessage({
    required FcmNotificationModel model,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Config.serverToken}',
        },
        body: model.toRawJson(),
      );

      print("fcm response : ${response.body}");

      Map<String, dynamic> res = json.decode(response.body);
      FcmResponseModel m = FcmResponseModel.fromJson(res);
      _showMyDialog(m);
    } catch (e, t) {
      print(e);
      print(t);
    }
  }

  Future<void> _showMyDialog(FcmResponseModel m) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(m.success == 1 ? "Success" : "failure"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  m.success == 1
                      ? "message send successful"
                      : "failed to send message",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  sendNotification(DeviceInfoModel model) {
    FcmNotificationModel m = FcmNotificationModel(
      notificationTitle: '${model.deviceModel}',
      token: '${model.fcmToken}',
      gameId: '${model.deviceId}',
      notificationBody:
          'notification from ${model.deviceModel} ip: ${model.internalIp4}',
      routeName: 'empty',
    );

    sendAndRetrieveMessage(model: m);
  }

  getModelData() async {
    modelList = await getAllDeviceFromFireBase();

    print("Device list length :=> ${modelList.length}");
    if (mounted) setState(() {});
  }

  List<DeviceInfoModel> modelList = <DeviceInfoModel>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8CA1A5),
      appBar: AppBar(
        title: const Text("Connected device List"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (modelList.isEmpty) const Text("no Data found"),
                for (int i = 0; i < modelList.length; i++)
                  MobileCard(
                    model: modelList[i],
                    onTap: () {
                      sendNotification(modelList[i]);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileCard extends StatelessWidget {
  const MobileCard({Key? key, required this.model, required this.onTap})
      : super(key: key);

  final DeviceInfoModel model;

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xff6D8299),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "DeviceId : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: Text(
                    model.deviceId ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text(
                    "Device Model : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: Text(
                    model.deviceModel ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text(
                    "DeviceId : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      model.fcmToken ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FcmResponseModel {
  int? multicastId;
  int? success;
  int? failure;
  int? canonicalIds;
  List<Results> results = <Results>[];

  FcmResponseModel({
    this.multicastId,
    this.success,
    this.failure,
    this.canonicalIds,
    this.results = const <Results>[],
  });

  FcmResponseModel.fromJson(Map<String, dynamic> json) {
    multicastId = json['multicast_id'];
    success = json['success'];
    failure = json['failure'];
    canonicalIds = json['canonical_ids'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['multicast_id'] = this.multicastId;
    data['success'] = this.success;
    data['failure'] = this.failure;
    data['canonical_ids'] = this.canonicalIds;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? messageId;

  Results({this.messageId});

  Results.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message_id'] = this.messageId;
    return data;
  }
}
