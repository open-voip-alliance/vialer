import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:vialer/domain/usecases/use_case.dart';

class GetInstalledMessagingApps extends UseCase {
  Future<List<String>> call() async {
    if (!Platform.isAndroid) {
      throw Exception(
        'We are only able to get Installed Messaging apps on Android',
      );
    }

    final apps = await InstalledApps.getInstalledApps(true);
    final packages = apps.map((app) => app.packageName);
    return packages.onlyRelevant;
  }
}

extension on Iterable<String> {
  /// The list of relevant messaging apps that we want to track.
  ///
  /// Note: When this list is updated you MUST also modify the AndroidManifest
  /// file found at:
  /// `android/app/src/main/AndroidManifest.xml`
  ///
  /// Add a new entry to the `<queries>` array such as:
  /// `<package android:name="com.whatsapp" />`
  ///
  /// Any package name that is not in both the manifest and this list will NOT
  /// be included in the survey results.
  static const _relevantApps = [
    'com.voys.app',
    'com.voipgrid.vialer',
    'nl.verbonden.app',
    'com.bellenmetannabel.app',
    'com.whatsapp',
    'com.whatsapp.w4b',
    'com.trengo.mobile',
    'zendesk.android',
    'com.zopim.android',
    'com.futuresimple.base',
    'com.Slack',
    'com.facebook.orca',
    'com.instagram.android',
    'org.telegram.messenger',
    'org.thoughtcrime.securesms',
    'com.snapchat.android',
    'com.zhiliaoapp.musically',
    'com.instagram.barcelona',
    'com.openai.chatgpt',
    'com.jivosite.mobile',
    'com.salesforce.chatter',
    'com.hubspot.android',
    'com.tidiochat.app',
    'io.intercom.android',
    'com.freshdesk.helpdesk',
    'to.tawk.android',
    'com.activecampaign.androidcrm',
    'com.livechatinc.android',
    'com.microsoft.teams',
    'com.google.android.apps.dynamite',
    'com.tencent.mm',
    'net.helpscout.android',
  ];

  List<String> get onlyRelevant =>
      filter((app) => _relevantApps.contains(app)).toList();
}
