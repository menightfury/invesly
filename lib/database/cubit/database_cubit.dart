// import 'package:invesly/common_libs.dart';
// import 'package:invesly/main.dart';

// part 'database_state.dart';

// class DatabaseCubit extends Cubit<DatabaseState> {
//   DatabaseCubit() : super(DatabaseInitialState());

//   Future<void> loadDatabase() async {
//     emit(DatabaseLoadingState());
//     try {
//       final api = Bootstrap.instance.api;
//       await api.initializeDatabase();
//       emit(DatabaseLoadedState());
//     } catch (e) {
//       $logger.e('Error loading database: $e');
//       emit(DatabaseErrorState(e.toString()));
//     }
//   }
// }
