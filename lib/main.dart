import 'package:flutter/material.dart';
import 'Routes/App_Routes.dart';
import 'Screens/Auth/Login_Screen.dart';
import 'Screens/Auth/Signup_Screen.dart';
import 'Screens/Auth/Splash_Screen.dart';
import 'Screens/Chat/Chat_List.dart';
import 'Screens/Chat/Chat_Message_Screen.dart';
import 'Screens/Home/Home_Screen.dart';
import 'Screens/Match/Request_Received_Screen.dart';
import 'Screens/Match/Search_Filter_Screen.dart';
import 'Screens/Match/Shortlisted_Screen.dart';
import 'Screens/Onboarding/Onboarding_Screen.dart';
import 'Screens/Payment/Payment_Screen.dart';
import 'Screens/Premium/Subscription_Screen.dart';
import 'Screens/Profile/My_Profile_Screen.dart';
import 'Screens/Profile/Partner_Preference_Screen.dart';
import 'Screens/Profile/Profile_Detail_Screen.dart';
import 'Screens/Profile/Profile_Setup_Screen.dart';
import 'Screens/Settings/Block_User_Screen.dart';
import 'Screens/Settings/Setting_Screen.dart';
import 'Screens/Settings/Support_Screen.dart';
import 'Screens/Success/Success_Stories_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matrimony App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
        AppRoutes.partnerPreference: (context) => const PartnerPreferenceScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.myProfile: (context) => const MyProfileScreen(),
        AppRoutes.profileDetail: (context) => const ProfileDetailScreen(),
        AppRoutes.searchFilter: (context) => const SearchFilterScreen(),
        AppRoutes.shortlisted: (context) => const ShortlistedScreen(),
        AppRoutes.requestReceived: (context) => const RequestReceivedScreen(),
        AppRoutes.chatList: (context) => const ChatListScreen(),
        AppRoutes.chatMessage: (context) => const ChatMessageScreen(user: {},),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.blockedUsers: (context) => const BlockedUsersScreen(),
        AppRoutes.support: (context) => const SupportScreen(),
        AppRoutes.subscription: (context) => const SubscriptionScreen(),
        AppRoutes.successStories: (context) => const SuccessStoriesScreen(),
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:textformfield/Screens/Chat/Chat_Message_Screen.dart';
// import 'package:textformfield/Screens/Onboarding/Onboarding_Screen.dart';
// import 'Screens/Auth/Login_Screen.dart';
// import 'Screens/Auth/Signup_Screen.dart';
// import 'Screens/Auth/Splash_Screen.dart';
// import 'Screens/Chat/Chat_List.dart';
// import 'Screens/Home/Home_Screen.dart';
// import 'Screens/Match/Request_Received_Screen.dart';
// import 'Screens/Match/Request_Sent_Screen.dart';
// import 'Screens/Match/Search_Filter_Screen.dart';
// import 'Screens/Match/Shortlisted_Screen.dart';
// import 'Screens/Profile/My_Profile_Screen.dart';
// import 'Screens/Profile/Partner_Preference_Screen.dart';
// import 'Screens/Profile/Profile_Detail_Screen.dart';
// import 'Screens/Profile/Profile_Setup_Screen.dart';
// import 'Screens/Settings/Block_User_Screen.dart';
// import 'Screens/Success/Success_Stories_Screen.dart';
// import 'Screens/premium/subscription_screen.dart';
// import 'Screens/settings/setting_screen.dart';
//
//
//
//  void main()
// {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: OnboardingScreen(),
//     );
//   }
// }
