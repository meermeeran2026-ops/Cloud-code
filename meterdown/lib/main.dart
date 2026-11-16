import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/l10n.dart';
import 'screens/start.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadVehiclePhotos();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MeterDownApp());
}

class MeterDownApp extends StatelessWidget {
  const MeterDownApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: lang,
    builder: (_, _, _) => MaterialApp(
      title: 'MeterDown',
      debugShowCheckedModeBanner: false,
      theme: mdTheme(Brightness.light),
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const SplashScreen(),
    ),
  );
}
