import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memory_notes/app_router.dart';
import 'package:memory_notes/core/constants/hive_keys.dart';
import 'package:memory_notes/core/di_container.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:memory_notes/features/connectivity/widgets/connectivity_notifier.dart';
import 'package:memory_notes/features/notes/cubit/notes_cubit.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(HiveKeys.noteModelTypeId)) {
    Hive.registerAdapter(NoteModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveKeys.taskModelTypeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  await Hive.openBox<NoteModel>(HiveKeys.notesBox);
  final settingsBox = await Hive.openBox<dynamic>(HiveKeys.settingsBox);

  initDi();

  final seenOnboarding =
      settingsBox.get(HiveKeys.seenOnboarding, defaultValue: false) as bool;

  runApp(
    MyApp(
      initialRoute: seenOnboarding ? AppRoutes.notesList : AppRoutes.onboarding,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = AppRoutes.notesList});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesCubit>(create: (_) => sl<NotesCubit>()..watchNotes()),
        BlocProvider<ConnectivityCubit>(
          create: (_) => sl<ConnectivityCubit>()..watchConnectivity(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Memory Notes',
        theme: AppTheme.dark,
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
        // Wraps every screen: shows a one-time snackbar whenever the
        // device goes offline or comes back online.
        builder: (context, child) => ConnectivityNotifier(child: child!),
      ),
    );
  }
}
