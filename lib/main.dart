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
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteBloc>(
          create: (context) => NoteBloc(noteRepository)..add(LoadNotes()),
        ),
        BlocProvider<SyncBloc>(
          create: (context) =>
              SyncBloc(noteRepository, connectivity)..add(StartSync()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline-First Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
