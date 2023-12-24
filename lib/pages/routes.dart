import 'package:flutter/material.dart';
import 'package:resonance_chatroom/models/models.dart';

import 'src/chat.dart';
import 'src/user_activity_main_page.dart';
import 'src/host_activity_set_page.dart';
import 'src/login_page.dart';
import 'src/host_activity_tag_page.dart';
import 'src/host_activity_topic_page.dart';
import 'src/host_activity_question_page.dart';
import 'src/host_question_statistic.dart';
import 'src/main_page.dart';
import 'src/personal_setting.dart';

export 'src/chat.dart';
export 'src/host_activity_set_page.dart';
export 'src/login_page.dart';
export 'src/host_activity_tag_page.dart';
export 'src/host_activity_topic_page.dart';
export 'src/host_activity_question_page.dart';
export 'src/host_question_statistic.dart';
export 'src/main_page.dart';
export 'src/personal_setting.dart';

Map<String, Widget Function(BuildContext)> routes = {
  HostActivitySetPage.routeName: (_) => const HostActivitySetPage(),
  LoginPage.routeName: (_) => const LoginPage(),
  ChatPage.routeName: (_) => const ChatPage(),
  UserActivityMainPage.routeName: (_) => const UserActivityMainPage(),
  HostActivityTagPage.routeName: (_) => const HostActivityTagPage(),
  HostActivityTopicPage.routeName: (_) => const HostActivityTopicPage(),
  HostActivityQuestionPage.routeName: (_) => const HostActivityQuestionPage(),
};
