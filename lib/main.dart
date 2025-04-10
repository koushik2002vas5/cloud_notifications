import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingApp());
}

class MessagingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF4A4AFF), // Deep Indigo
        secondary: Color(0xFF00B8D4), // Cyan
        background: Color(0xFF121212), // True black
        surface: Color(0xFF1E1E1E), // Dark surface
        onPrimary: Colors.white,
        onSurface: Colors.white70,
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        elevation: 0,
        color: Color(0xFF1F1B24),
        foregroundColor: Colors.white,
      ),
      textTheme: Typography.whiteCupertino,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: darkTheme,
      home: MyHomePage(title: 'Firebase Messaging Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText = "📭 No notifications received yet.";

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.requestPermission();

    messaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    messaging.subscribeToTopic("messaging");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        notificationText = message.notification?.body ?? "No message body";
      });
      _showNotificationDialog(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      setState(() {
        notificationText = message.notification?.body ?? "No message body";
      });
      _showNotificationDialog(message);
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    String notificationType = message.data['type'] ?? 'regular';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            notificationType == 'important'
                ? "🔔 Important Notifications"
                : "📢 Notification",
            style: TextStyle(
              color: Color(0xFF4A4AFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message.notification?.body ?? "No message body",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF4A4AFF),
              ),
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: cardColor.withOpacity(0.2),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              notificationText ?? '',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
