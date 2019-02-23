import 'dart:async';

import 'package:appcenter_analytics/appcenter_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

abstract class IAnalyticsService {
  Future<void> trackEvent(String event, {Map<String, dynamic> data});
}

class FirebaseAnalyticsService extends IAnalyticsService {

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService(this._analytics);

  @override
  Future<void> trackEvent(String event, {Map<String, dynamic> data}) async {
    await this._analytics.logEvent(
      name: event,
      parameters: data
    );
  }
}

class AppCenterAnalyticsService extends IAnalyticsService {

  @override
  Future<void> trackEvent(String event, {Map<String, dynamic> data}) async {
    await AppCenterAnalytics.trackEvent(event, data);
  }
}

class MultiAnalyticsProviderService extends IAnalyticsService {

  final List<IAnalyticsService> _analyticsServices;

  MultiAnalyticsProviderService(this._analyticsServices);
  
  @override
  Future<void> trackEvent(String event, {Map<String, dynamic> data}) async {
    for (var service in this._analyticsServices) {
      await service.trackEvent(event, data: data);
    }
  }
}
