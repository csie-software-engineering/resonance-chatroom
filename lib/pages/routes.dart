import 'package:flutter/material.dart';
import 'package:resonance_chatroom/models/models.dart';

import 'src/chat.dart';
import 'src/host_activity_question_page.dart';
import 'src/host_activity_set_page.dart';
import 'src/host_activity_tag_page.dart';
import 'src/host_activity_topic_page.dart';
import 'src/host_question_statistic.dart';
import 'src/login_page.dart';
import 'src/main_page.dart';
import 'src/personal_setting.dart';
import 'src/user_activity_main_page.dart';
import 'src/welcome_page.dart';
import 'src/manager.dart';

export 'src/chat.dart';
export 'src/host_activity_question_page.dart';
export 'src/host_activity_set_page.dart';
export 'src/host_activity_tag_page.dart';
export 'src/host_activity_topic_page.dart';
export 'src/host_question_statistic.dart';
export 'src/login_page.dart';
export 'src/main_page.dart';
export 'src/personal_setting.dart';
export 'src/user_activity_main_page.dart';
export 'src/welcome_page.dart';
export 'src/manager.dart';

Map<String, Widget Function(BuildContext)> routes = {
  ChatPage.routeName: (_) => const ChatPage(),
  HostActivityQuestionPage.routeName: (_) => const HostActivityQuestionPage(),
  HostActivitySetPage.routeName: (_) => const HostActivitySetPage(),
  HostActivityTagPage.routeName: (_) => const HostActivityTagPage(),
  HostActivityTopicPage.routeName: (_) => const HostActivityTopicPage(),
  HostQuestionStatisticPage.routeName: (_) => const HostQuestionStatisticPage(),
  LoginPage.routeName: (_) => const LoginPage(),
  MainPage.routeName: (_) => const MainPage(),
  PersonalSettingPage.routeName: (_) => const PersonalSettingPage(),
  UserActivityMainPage.routeName: (_) => const UserActivityMainPage(),
  WelcomePage.routeName: (_) => const WelcomePage(),
  ManagerPage.routeName: (_) => const ManagerPage(),
};
