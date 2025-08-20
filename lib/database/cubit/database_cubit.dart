import 'package:invesly/common_libs.dart';
import 'package:invesly/main.dart';

part 'database_state.dart';

class DatabaseCubit extends Cubit<DatabaseState> {
  DatabaseCubit() : super(DatabaseInitial());

  Future<void> loadDatabase() async {
    emit(DatabaseLoading());
    try {
      final api = Bootstrap.instance.api;
      await api.initializeDatabase();
      emit(DatabaseLoaded());
    } catch (e) {
      $logger.e('Error loading database: $e');
      emit(DatabaseError(e.toString()));
    }
  }
}
