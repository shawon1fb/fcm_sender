import 'dart:convert';

import 'package:flutter/material.dart';

class FcmNotificationModel {
  String notificationBody;
  String notificationTitle;
  String routeName;
  String gameId;
  String token;

  FcmNotificationModel({
    required this.token,
    required this.notificationBody,
    required this.notificationTitle,
    required this.routeName,
    required this.gameId,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> notification = {};
    notification['to'] = token;
    notification['priority'] = 'high';

    Map<String, dynamic> notificationBody = {};
    notificationBody['body'] = this.notificationBody;
    notificationBody['title'] = notificationTitle;

    Map<String, dynamic> dataBody = {};
    dataBody['click_action'] = 'FLUTTER_NOTIFICATION_CLICK';
    dataBody['route'] = routeName;
    dataBody['gameId'] = gameId;

    notification['notification'] = notificationBody;
    notification['data'] = dataBody;
    return notification;
  }

  String toRawJson() {
    return jsonEncode(toJson());
  }
}
