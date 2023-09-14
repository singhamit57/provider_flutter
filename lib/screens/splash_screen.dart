import 'package:flutter/material.dart';
import 'package:koibanda_provider_flutter/auth/sign_in_screen.dart';
import 'package:koibanda_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:koibanda_provider_flutter/main.dart';
import 'package:koibanda_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:koibanda_provider_flutter/screens/maintenance_mode_screen.dart';
import 'package:koibanda_provider_flutter/utils/common.dart';
import 'package:koibanda_provider_flutter/utils/configs.dart';
import 'package:koibanda_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    afterBuildCreated(() async {
      appStore.setLanguage(
          getStringAsync(SELECTED_LANGUAGE_CODE,
              defaultValue: DEFAULT_LANGUAGE),
          context: context);
      setStatusBarColor(Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.light : Brightness.dark);

      int themeModeIndex =
          getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }
    });

    if (!await isAndroid12Above()) await 10000.milliseconds.delay;

    if (remoteConfigDataModel.inMaintenanceMode.validate()) {
      MaintenanceModeScreen()
          .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
    } else {
      if (!appStore.isLoggedIn) {
        SignInScreen().launch(context, isNewTask: true);
      } else {
        if (isUserTypeProvider) {
          setStatusBarColor(primaryColor);
          ProviderDashboardScreen(index: 0).launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else if (isUserTypeHandyman) {
          setStatusBarColor(primaryColor);
          HandymanDashboardScreen(index: 0).launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          SignInScreen().launch(context, isNewTask: true);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE96111),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            appStore.isDarkMode ? splash_light_background : splash_background,
            height: context.height(),
            width: context.width(),
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                appLogo,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
              32.height,
              Text(APP_NAME,
                  style: boldTextStyle(size: 26, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
