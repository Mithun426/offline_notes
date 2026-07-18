import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/note/note_bloc.dart';
import 'blocs/note/note_event.dart';
import 'blocs/sync/sync_bloc.dart';
import 'blocs/sync/sync_event.dart';
import 'repositories/note_repository.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  final apiService = ApiService();
  final connectivity = Connectivity();
  final noteRepository = NoteRepository(hiveService, apiService, connectivity);
  runApp(MyApp(noteRepository: noteRepository, connectivity: connectivity));
}

class MyApp extends StatelessWidget {
  final NoteRepository noteRepository;
  final Connectivity connectivity;

  const MyApp({
    super.key,
    required this.noteRepository,
    required this.connectivity,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: noteRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NoteBloc>(
            create: (_) => NoteBloc(noteRepository)..add(LoadNotes()),
          ),
          BlocProvider<SyncBloc>(
            create: (_) => SyncBloc(noteRepository, connectivity)..add(StartSync()),
          ),
        ],
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline-First Notes',
        themeMode: ThemeMode.dark,

        // ─── Every color / style is defined here once ───────────────────────
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,

          // Core palette — change here to retheme the whole app
          colorScheme: const ColorScheme.dark(
            primary:    Color(0xFFFFC107), // amber accent
            secondary:  Color(0xFFFFC107),
            surface:    Color(0xFF1E1E30), // card surface
            onPrimary:  Colors.black,
            onSecondary: Colors.black,
            onSurface:  Color(0xFFF0F0F0), // primary text
            error:      Color(0xFFCF6679),
          ),

          scaffoldBackgroundColor: const Color(0xFF12121F), // page bg

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF12121F),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFFF0F0F0)),
            titleTextStyle: TextStyle(
              color: Color(0xFFF0F0F0),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          tabBarTheme: const TabBarThemeData(
            labelColor: Color(0xFFFFC107),
            unselectedLabelColor: Color(0xFF9090AA),
            indicatorColor: Color(0xFFFFC107),
            dividerColor: Color(0xFF252540),
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFC107),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),

          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),

          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF9090AA)),
          ),

          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: Color(0xFFF0F0F0), fontWeight: FontWeight.w800, fontSize: 28),
            titleLarge:    TextStyle(color: Color(0xFFF0F0F0), fontWeight: FontWeight.w700, fontSize: 17),
            titleMedium:   TextStyle(color: Color(0xFFF0F0F0), fontWeight: FontWeight.w600),
            bodyLarge:     TextStyle(color: Color(0xFFF0F0F0), fontSize: 15),
            bodyMedium:    TextStyle(color: Color(0xFF9090AA), fontSize: 13),
            bodySmall:     TextStyle(color: Color(0xFF9090AA), fontSize: 11),
            labelLarge:    TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
          ),

          iconTheme: const IconThemeData(color: Color(0xFFF0F0F0)),
          dividerColor: const Color(0xFF252540),

          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),

          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF1E1E30),
            titleTextStyle: const TextStyle(color: Color(0xFFF0F0F0), fontSize: 18, fontWeight: FontWeight.w700),
            contentTextStyle: const TextStyle(color: Color(0xFF9090AA), fontSize: 14, height: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFC107)),
          ),
        ),
        // ────────────────────────────────────────────────────────────────────

        home: const HomeScreen(),
        ),
      ),
    );
  }
}
