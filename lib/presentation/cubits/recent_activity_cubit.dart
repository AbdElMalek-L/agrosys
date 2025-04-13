import 'package:agrosys/controllers/recent_activity_storage.dart';
import 'package:bloc/bloc.dart';

/// Cubit for managing the list of recent activities.
class RecentActivityCubit extends Cubit<List<Map<String, String>>> {
  RecentActivityCubit() : super([]);

  /// Loads activities from storage and emits the loaded list.
  Future<void> loadActivities() async {
    final loadedActivities = await RecentActivityStorage.loadActivities();
    emit(loadedActivities);
  }
}
