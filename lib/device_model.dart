import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceModel {
  static DeviceModel? _instance = DeviceModel._();

  DeviceModel._();

  static DeviceModel get getInstance => _instance ??= DeviceModel._();

  String? deviceId;
  String? deviceModel;
  bool? active;
  bool? block;

  String? fcmToken;

  ///network
  String? internalIp4;
  String? internalIp6;

  DeviceModel({
    this.deviceId,
    this.deviceModel,
    this.active = false,
    this.block = false,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['deviceId'] = deviceId;
    map['deviceModel'] = deviceModel;
    map['active'] = active ?? false;
    map['block'] = block ?? false;
    map['fcmToken'] = fcmToken ?? "";

    map['internalIp4'] = internalIp4 ?? "";
    map['internalIp6'] = internalIp6 ?? "";
    return map;
  }

  fromJson(Map<String, dynamic> map) {
    deviceId = map['deviceId'];
    deviceModel = map['deviceModel'];
    active = map['active'];
    block = map['block'];
    fcmToken = map['fcmToken'];

    internalIp4 = map['internalIp4'];
    internalIp6 = map['internalIp6'];
  }

  fromSnapShort(DocumentSnapshot map) {
    deviceId = map.get('deviceId');
    deviceModel = map.get('deviceModel');
    active = map.get('active');
    block = map.get('block');
    fcmToken = map.get('fcmToken');

    internalIp4 = map.get('internalIp4');
    internalIp6 = map.get('internalIp6');
  }

  setActive() {
    active = true;
  }

  setDeActive() {
    active = false;
  }

  setBlock() {
    block = true;
  }

  setUnBlock() {
    block = false;
  }

  getInfo(token) async {
    this.fcmToken = token;
    await _getDeviceInfo();
    await _getNetworkInfo();
  }

  _getNetworkInfo() async {
    internalIp4 = await Ipify.ipv4();
    internalIp6 = await Ipify.ipv64();
  }

  _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    print("getDeviceInfo ---");
    try {
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.identifierForVendor}');
        print('Running on ${iosInfo.utsname.machine}');
        deviceId = iosInfo.identifierForVendor;
        deviceModel = iosInfo.utsname.machine;
        return;
      }
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('model on ${androidInfo.model}');
        print('androidId on ${androidInfo.androidId}');
        deviceId = androidInfo.androidId;
        deviceModel = androidInfo.model;
        return;
      }
    } catch (e, t) {
      print(e);
      print(t);
    }
  }

  static const collectionPath = "all_device_info";

  saveDataToFireBase() async {
    await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(this.deviceId)
        .set(toJson());
  }

  getDataFromFireBase() async {
    try {
      await getInfo("");
      DocumentSnapshot qt = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(this.deviceId)
          .get();

      if (qt.exists) {
        fromSnapShort(qt);
      }
    } catch (e, t) {
      print(e);
      print(t);
    }
  }
}

class DeviceInfoModel {
  String? deviceId;
  String? deviceModel;
  bool? active;
  bool? block;

  String? fcmToken;

  ///network
  String? internalIp4;
  String? internalIp6;

  DeviceInfoModel({
    this.deviceId,
    this.deviceModel,
    this.active = false,
    this.block = false,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['deviceId'] = deviceId;
    map['deviceModel'] = deviceModel;
    map['active'] = active ?? false;
    map['block'] = block ?? false;
    map['fcmToken'] = fcmToken ?? "";

    map['internalIp4'] = internalIp4 ?? "";
    map['internalIp6'] = internalIp6 ?? "";
    return map;
  }

  DeviceInfoModel.fromJson(Map<String, dynamic> map) {
    deviceId = map['deviceId'];
    deviceModel = map['deviceModel'];
    active = map['active'];
    block = map['block'];
    fcmToken = map['fcmToken'];

    internalIp4 = map['internalIp4'];
    internalIp6 = map['internalIp6'];
  }

  DeviceInfoModel.fromSnapShort(DocumentSnapshot map) {
    deviceId = map.get('deviceId');
    deviceModel = map.get('deviceModel');
    active = map.get('active');
    block = map.get('block');
    fcmToken = map.get('fcmToken');

    internalIp4 = map.get('internalIp4');
    internalIp6 = map.get('internalIp6');
  }
}

Future<List<DeviceInfoModel>> getAllDeviceFromFireBase() async {
  try {
    QuerySnapshot qt = await FirebaseFirestore.instance
        .collection(DeviceModel.collectionPath)
        .get();

    List<DeviceInfoModel> deviceList = <DeviceInfoModel>[];
    qt.docs.forEach((element) {
      DeviceInfoModel m = DeviceInfoModel.fromSnapShort(element);
      deviceList.add(m);
    });

    return deviceList;
  } catch (e, t) {
    print(e);
    print(t);
    return <DeviceInfoModel>[];
  }
}
