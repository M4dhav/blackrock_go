import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/controllers/timeline_post_controller.dart';
import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/services/camp_network_service.dart';
import 'package:blackrock_go/services/camp_service.dart';
import 'package:blackrock_go/services/crypto_service.dart';
import 'package:blackrock_go/services/location_link_service.dart';
import 'package:blackrock_go/services/mesh_message_service.dart';
import 'package:blackrock_go/services/pythia_service.dart';
import 'package:blackrock_go/views/screens/base_view.dart';
import 'package:blackrock_go/views/screens/camp_screen.dart';
import 'package:blackrock_go/views/screens/channels.dart';
import 'package:blackrock_go/views/screens/chat.dart';
import 'package:blackrock_go/views/screens/chats_page.dart';
import 'package:blackrock_go/views/screens/connect_node_screen.dart';
import 'package:blackrock_go/views/screens/direct_messages.dart';
import 'package:blackrock_go/views/screens/event_details_screen.dart';
import 'package:blackrock_go/views/screens/events.dart';
import 'package:blackrock_go/views/screens/location_share_screen.dart';
import 'package:blackrock_go/views/screens/oracle_screen.dart';
import 'package:blackrock_go/views/screens/search_screen.dart';
import 'package:blackrock_go/views/screens/users.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vs_story_designer/vs_story_designer.dart';
import 'package:blackrock_go/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Database — version 2 adds camp, member, and location_link tables
  Get.put(await openDatabase(
    join(await getDatabasesPath(), 'blackrock_database.db'),
    onCreate: (db, version) async {
      await _createSchema(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) await _addCampSchema(db);
    },
    version: 2,
  ));

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final SharedPreferencesWithCache prefs =
      Get.put(await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  ));

  // Crypto — must init before any service that encrypts/decrypts
  final crypto = Get.put(CryptoService());
  await crypto.initialize();

  // Network detection — probes for camp.local on a 30s interval
  Get.put(CampNetworkService(), permanent: true);

  final TimelinePostController timelineController =
      Get.put(TimelinePostController());
  final EventController eventController = Get.put(EventController());
  Get.put(MeshtasticNodeController(), permanent: true);

  // Services that depend on mesh + crypto
  Get.put(MeshMessageService(), permanent: true);
  Get.put(CampService(), permanent: true);
  Get.put(LocationLinkService(), permanent: true);
  Get.put(PythiaService(), permanent: true);

  await eventController.getEvents();
  await timelineController.getPosts();
  MapboxOptions.setAccessToken(Constants.mapboxToken);

  if (prefs.containsKey('isEntered') && prefs.getBool('isEntered') == true) {
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
                path: 'login',
                builder: (context, state) {
                  return const LoginPage();
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
            // GoRoute(
            //   path: 'event',
            //   builder: (context, state) {
            //     final eventName = state.uri.queryParameters['event'];
            //     final EventController eventController =
            //         Get.find<EventController>();
            //     final event = eventController.events.firstWhere(
            //       (element) {
            //         return element.eventName == eventName?.replaceAll('-', ' ');
            //       },
            //     );
            //     return EventDetailsScreen(
            //       event: event,
            //     );
            //   },
            // ),
            GoRoute(
                path: 'storyDesigner',
                builder: (context, state) => VSStoryDesigner(
                    onDone: (String uri) {
                      timelineController.addPostToTimeline(uri);
                      context.pop();
                    },
                    // onDoneButtonStyle: Icon(Icons.done),
                    mediaPath: state.extra as String,
                    middleBottomWidget: Container(),
                    centerText: '')),
            GoRoute(
              path: 'eventDetails',
              builder: (context, state) => EventDetailsScreen(
                event: (state.extra as List)[0],
              ),
            ),
            GoRoute(
                path: 'connectNode',
                builder: (context, state) => const ConnectNodeScreen()),
            GoRoute(
                path: 'allChat',
                builder: (context, state) => const ChatPage(title: 'Everyone')),
            GoRoute(
                path: 'users', builder: (context, state) => const UsersPage()),
            GoRoute(
                path: 'userChat',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return ChatPage(
                    title: args['title'],
                    user: args['user'],
                  );
                }),
            GoRoute(
              path: 'chatsPage',
              builder: (context, state) => const ChatsPage(),
            ),
            GoRoute(
              path: 'channelsPage',
              builder: (context, state) => const ChannelsPage(),
            ),
            GoRoute(
              path: 'directMessagesPage',
              builder: (context, state) => const DirectMessagesPage(),
            ),
            GoRoute(
              path: 'eventsList',
              builder: (context, state) => const EventsScreen(),
            ),
            GoRoute(
              path: 'oracle',
              builder: (context, state) => const OracleScreen(),
            ),
            GoRoute(
              path: 'camp',
              builder: (context, state) => const CampScreen(),
            ),
            GoRoute(
              path: 'playaLinks',
              builder: (context, state) => const LocationShareScreen(),
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

// ── Database schema ────────────────────────────────────────────────────────

Future<void> _createSchema(Database db) async {
  await Future.wait([
    db.execute(
      'CREATE TABLE timeline_posts ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'imageUrl TEXT NOT NULL, '
      'timestamp INTEGER NOT NULL'
      ')',
    ),
    ..._campSchemaSql().map(db.execute),
  ]);
}

Future<void> _addCampSchema(Database db) async {
  for (final sql in _campSchemaSql()) {
    await db.execute(sql);
  }
}

List<String> _campSchemaSql() => [
  '''CREATE TABLE IF NOT EXISTS camps (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    latitude REAL,
    longitude REAL,
    meshtastic_slot INTEGER NOT NULL DEFAULT 1,
    channel_psk TEXT NOT NULL,
    gateway_node_id TEXT,
    role TEXT NOT NULL DEFAULT 'member',
    joined_at INTEGER NOT NULL
  )''',
  '''CREATE TABLE IF NOT EXISTS camp_members (
    id TEXT PRIMARY KEY,
    camp_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    display_name TEXT,
    public_key TEXT,
    role TEXT NOT NULL DEFAULT 'member',
    location_opt_in INTEGER NOT NULL DEFAULT 0,
    last_seen INTEGER,
    last_lat REAL,
    last_lon REAL,
    FOREIGN KEY(camp_id) REFERENCES camps(id) ON DELETE CASCADE
  )''',
  '''CREATE TABLE IF NOT EXISTS location_links (
    id TEXT PRIMARY KEY,
    peer_node_id TEXT NOT NULL,
    peer_display_name TEXT,
    expires_at INTEGER NOT NULL,
    bidirectional INTEGER NOT NULL DEFAULT 1,
    status TEXT NOT NULL DEFAULT 'pending',
    am_sharing INTEGER NOT NULL DEFAULT 1,
    they_sharing INTEGER NOT NULL DEFAULT 1
  )''',
];
