import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: remove this.

class AppStateTest extends StatelessWidget {
  const AppStateTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppStateCubit, AppState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(state.darkMode ? "Dark Mode" : "Light Mode"),
                ElevatedButton(
                  onPressed:
                      () => context.read<AppStateCubit>().toggleDarkMode(),
                  child: const Text("Switch Theme Mode"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
