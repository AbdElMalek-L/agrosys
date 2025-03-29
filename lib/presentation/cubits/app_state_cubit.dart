/*

  APPSTATE CUBIT - state management

  Each cubit is a card of appStates.
*/

import 'package:agrosys/domain/models/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/repository/app_state_repo.dart';

class AppStateCubit extends Cubit<AppState> {
  final AppStateRepo appStateRepo;

  // Provide initial state to super constructor
  AppStateCubit(this.appStateRepo) : super(AppState()) {
    loadAppState();
  }

  Future<void> loadAppState() async {
    final appState = await appStateRepo.getAppState();
    emit(appState); // Update state with fetched data
  }

  // No need for parameter - use current state
  Future<void> toggleDarkMode() async {
    final currentState = state;
    final updatedAppState = currentState.toggleDarkMode();
    // Use repository to persist changes
    await appStateRepo.updateAppState(updatedAppState);
    emit(updatedAppState);
  }

  // Accept only necessary parameters
  Future<void> toggleSeenIntro() async {
    final currentState = state;
    final updatedAppState = currentState.sawIntro();
    await appStateRepo.updateAppState(updatedAppState);
    emit(updatedAppState);
  }
}
