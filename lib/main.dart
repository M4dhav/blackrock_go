import 'dart:io';

import 'package:blackrock_go/controllers/biometrics_controller.dart';
import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/controllers/timeline_post_controller.dart';
import 'package:blackrock_go/controllers/user_controller.dart';
import 'package:blackrock_go/models/user_model.dart';
import 'package:blackrock_go/views/screens/base_view.dart';
import 'package:blackrock_go/views/screens/event_details_screen.dart';
import 'package:blackrock_go/views/screens/legal_screen.dart';
import 'package:blackrock_go/views/screens/onboarding.dart';
import 'package:blackrock_go/views/screens/search_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:vs_story_designer/vs_story_designer.dart';
import 'package:blackrock_go/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final SharedPreferencesWithCache prefs =
      Get.put(await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  ));

  final UserController userController = Get.put(UserController());

  final TimelinePostController timelineController =
      Get.put(TimelinePostController());
  final EventController eventController = Get.put(EventController());
  final BiometricsController auth = Get.put(BiometricsController());
  await eventController.getEvents();
  await timelineController.getPosts();
  await auth.initialize();
  if (prefs.containsKey('pfpUrl') && prefs.containsKey('accountName')) {
    final String pfpUrl = prefs.getString('pfpUrl')!;
    final String accountName = prefs.getString('accountName')!;
    userController
        .setUser(User(pfpUrl: File(pfpUrl), accountName: accountName));
    runApp(MyApp(initWidget: NavBar()));
  } else {
    runApp(MyApp(initWidget: const LoginPage()));
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.initWidget}) {
    final TimelinePostController timelineController =
        Get.find<TimelinePostController>();
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => initWidget,
          routes: [
            GoRoute(
              path: 'home',
              builder: (context, state) => const NavBar(),
            ),
            GoRoute(
                path: 'legal',
                builder: (context, state) {
                  return LegalPage();
                }),
            GoRoute(
                path: 'login',
                builder: (context, state) {
                  return const LoginPage();
                }),
            GoRoute(
                path: 'onboarding',
                builder: (context, state) {
                  return const OnboardingScreen();
                }),
            GoRoute(
                path: 'search',
                pageBuilder: (context, state) => CustomTransitionPage(
                    child: const SearchScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin =
                          Offset(0.0, 1.0); // Start from below the screen
                      const end = Offset.zero; // End at the current position
                      const curve = Curves.easeInOutQuad;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    })),
            GoRoute(
              path: 'event',
              builder: (context, state) {
                final eventName = state.uri.queryParameters['event'];
                final EventController eventController =
                    Get.find<EventController>();
                final event = eventController.events.firstWhere(
                  (element) {
                    return element.eventName == eventName?.replaceAll('-', ' ');
                  },
                );
                return EventDetailsScreen(event: event, hosts: event.hosts);
              },
            ),
            GoRoute(
                path: 'storyDesigner',
                builder: (context, state) => VSStoryDesigner(
                    onDone: (String uri) {
                      timelineController.addPostToTimeline(uri);
                      context.pop();
                    },
                    mediaPath: state.extra as String,
                    middleBottomWidget: Container(),
                    centerText: '')),
            GoRoute(
              path: 'eventDetails',
              builder: (context, state) => EventDetailsScreen(
                  event: (state.extra as List)[0],
                  hosts: (state.extra as List)[1]),
            ),
          ],
        ),
      ],
    );
  }
  final Widget initWidget;
  late final GoRouter router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return GetMaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        routeInformationProvider: router.routeInformationProvider,
        backButtonDispatcher: router.backButtonDispatcher,
        title: 'Blackrock Go',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: TextTheme(
            displayLarge: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 57,
                fontWeight: FontWeight.bold),
            displayMedium: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 45,
                fontWeight: FontWeight.bold),
            displaySmall: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 36,
                fontWeight: FontWeight.bold),
            headlineLarge: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 32,
                fontWeight: FontWeight.bold),
            headlineMedium: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 28,
                fontWeight: FontWeight.bold),
            headlineSmall: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 24,
                fontWeight: FontWeight.bold),
            titleLarge: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 22,
                fontWeight: FontWeight.w900),
            titleMedium: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 16,
                fontWeight: FontWeight.w900),
            titleSmall: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 14,
                fontWeight: FontWeight.w500),
            bodyLarge: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 16,
                fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(
                color: Colors.white,
                fontFamily: 'Cinzel',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
            bodySmall: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                fontWeight: FontWeight.w400),
            labelLarge: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 14,
                fontWeight: FontWeight.w500),
            labelMedium: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                fontWeight: FontWeight.w400),
            labelSmall: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 11,
                fontWeight: FontWeight.w400),
          ),
        ),
      );
    });
  }
}
