import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/pages/devices_list_page.dart';
import 'package:flutter/material.dart';

/// A widget that displays the currently selected device in an ExpansionTile.
///
/// Tapping the tile navigates to the [DevicesListPage] to allow changing
/// the selected device.
class DeviceSelectorTile extends StatelessWidget {
  final List<Device> devices;
  final AppState appState;
  final int expansionKey; // Used to maintain state across rebuilds if needed

  const DeviceSelectorTile({
    super.key,
    required this.devices,
    required this.appState,
    required this.expansionKey,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the tile should appear expanded (visual only, as it navigates)
    // This might need adjustment based on desired UX, currently always collapsed visually.

    return Hero(
      tag: "change_selected_device", // Tag for Hero animation
      child: Material(
        type: MaterialType.transparency,
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Theme(
            // Remove the default divider line
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: ValueKey(expansionKey), // Unique key for the tile
              // Navigate to device list page when the tile is tapped
              onExpansionChanged:
                  (expanded) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DevicesListPage(),
                    ),
                  ),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              iconColor: Colors.green[700],
              collapsedIconColor: Colors.green[700],
              // Display device model and name, or "none" if no devices exist
              title:
                  devices.isEmpty
                      ? const Text("No devices added") // Improved message
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            devices[appState.selectedDeviceIndex].model,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 66, 66, 66),
                            ),
                          ),
                          Text(
                            devices[appState.selectedDeviceIndex].name,
                            textDirection:
                                TextDirection.rtl, // Keep RTL for name
                            style: const TextStyle(
                              color: Color.fromARGB(255, 129, 129, 129),
                            ),
                          ),
                        ],
                      ),
              // Animated arrow icon
              trailing: AnimatedRotation(
                turns: 0, // Controls arrow direction
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more),
              ),
              // Prevent expansion by not providing children
              children: const [],
            ),
          ),
        ),
      ),
    );
  }
}
