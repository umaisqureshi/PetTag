import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/screens/about_screen.dart';
import 'package:pett_tagg/screens/agree_screen.dart';
import 'package:pett_tagg/screens/editOwnerInfo.dart';
import 'package:pett_tagg/screens/edit_info.dart';
import 'package:pett_tagg/screens/email_notification.dart';
import 'package:pett_tagg/screens/home_screen.dart';
import 'package:pett_tagg/screens/liked_pet_screen.dart';
import 'package:pett_tagg/screens/match_pet_screen.dart';
import 'package:pett_tagg/screens/pet_chat_screen.dart';
import 'package:pett_tagg/screens/pet_detail_screen.dart';
import 'package:pett_tagg/screens/pet_profile.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:pett_tagg/screens/push_notification.dart';
import 'package:pett_tagg/screens/register_screen.dart';
import 'package:pett_tagg/screens/second_register_screen.dart';
import 'package:pett_tagg/screens/settings_screen.dart';
import 'package:pett_tagg/screens/sign_in_screen.dart';
import 'package:pett_tagg/screens/top_picked_pet.dart';
import 'package:pett_tagg/widgets/generic_next_sign_register_button.dart';
import 'package:pett_tagg/screens/sign_in_screen.dart';
import 'package:pett_tagg/widgets/mySearchDialog.dart';
import 'package:pett_tagg/widgets/pet_wall_screen.dart';
import 'package:pett_tagg/widgets/subscriptionDealCard.dart';
import 'package:provider/provider.dart';
import 'constant.dart';
import 'package:pett_tagg/screens/all_profiles.dart';
import 'screens/splash_screen.dart';
import 'screens/treat_screen.dart';
import 'package:pett_tagg/screens/edit_profile.dart';
import 'screens/signupPlan.dart';
import 'screens/addNewFeed.dart';
import 'screens/userDetails.dart';
import 'package:pett_tagg/screens/addNewProfile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_services.dart';
import 'services/sharedPref.dart';
import 'package:pett_tagg/screens/ptPlus.dart';
import 'package:pett_tagg/screens/ownerProfile.dart';
import 'package:pett_tagg/chat/widgets/route_generator.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pett_tagg/utilities/appData.dart';

final appData = AppData();

final sharedPrefs = SharedPrefs();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.white,
        unselectedWidgetColor: Colors.black.withOpacity(0.4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: PetDetailedScreen(),
      home: SplashScreen(),
      onGenerateRoute: RouteGenerator.generateRoute,
      routes: {
        HomeScreen.homeScreenRoute: (BuildContext ctx) => HomeScreen(),
        OwnerProfile.ownerProfileScreenRoute: (BuildContext ctx) => OwnerProfile(),
        AllProfiles.allProfilesScreenRoute: (BuildContext ctx) => AllProfiles(),
        SplashScreen.splashScreenRoute: (BuildContext ctx) => SplashScreen(),
        SignInScreen.secondScreenRoute: (BuildContext ctx) => SignInScreen(),
        TreatScreen.treatScreenRoute: (BuildContext ctx) => TreatScreen(),
        SignUpPlan.singUpPlanRoute: (BuildContext ctx) => SignUpPlan(),
        EditOwnerInfoScreen.editOwnerInfoScreenRoute: (BuildContext ctx) =>
            EditOwnerInfoScreen(),
        EditInfoScreen.editInfoScreenRoute: (BuildContext ctx) =>
            EditInfoScreen(),
        EditProfileScreen.editProfileScreenRoute: (BuildContext ctx) =>
            EditProfileScreen(),
        AddNewProfileScreen.addNewProfileScreenRoute: (BuildContext ctx) =>
            AddNewProfileScreen(),
        RegisterScreen.registerScreenRoute: (BuildContext context) =>
            RegisterScreen(),
        SecondRegisterScreen.secondRegisterScreenRoute:
            (BuildContext context) => SecondRegisterScreen(),
        AgreeScreen.agreeScreenRoute: (BuildContext context) => AgreeScreen(),
        AboutScreen.aboutScreenRoute: (BuildContext context) => AboutScreen(),
        PetMatch.petMatchScreenRoute: (BuildContext context) => PetMatch(),
        PetLiked.petLikedScreenRoute: (BuildContext context) => PetLiked(),
        TopPickedPet.TopPickedPetScreenRoute: (BuildContext context) =>
            TopPickedPet(),
        PetDetailedScreen.petDetailedScreenRoute: (BuildContext context) =>
            PetDetailedScreen(),
        PetChatScreen.petChatScreenRoute: (BuildContext context) =>
            PetChatScreen(),
        PetSlideScreen.petSlideScreenRouteName: (BuildContext context) =>
            PetSlideScreen(),
        PetProfileScreen.petProfileScreenRouteName: (BuildContext context) =>
            PetProfileScreen(),
        SettingsScreen.settingsScreenRoute: (BuildContext context) =>
            SettingsScreen(),
        UserDetails.userDetailsRoute: (BuildContext ctx) => UserDetails(),
        AddNewFeed.addNewFeedScreenRoute: (BuildContext ctx) => AddNewFeed(),
        SubscriptionDealCard.subscriptionDealCardScreenRoute: (BuildContext ctx) => SubscriptionDealCard(),
        MySearchDialog.mySearchDialogScreenDialog: (BuildContext ctx) => MySearchDialog(),
        PushNotification.pushNotificationScreenRoute: (BuildContext ctx) => PushNotification(),
        EmailNotification.emailNotificationScreenRoute: (BuildContext ctx) => EmailNotification(),
        PTPlus.ptPlusScreenRoute: (BuildContext ctx) => PTPlus(),
      },
    );
  }
}

