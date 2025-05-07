import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/pages/devices_list_page.dart';
import 'package:flutter/material.dart';

class DeviceSelectorTile extends StatelessWidget {
  final List<Device> devices;
  final AppState appState;
  final int expansionKey;

  const DeviceSelectorTile({
    super.key,
    required this.devices,
    required this.appState,
    required this.expansionKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: "change_selected_device",
      child: Material(
        type: MaterialType.transparency,
        child: Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: ValueKey(expansionKey),
              onExpansionChanged: (expanded) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DevicesListPage(),
                  ),
                );
              },
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              iconColor: colorScheme.primary,
              collapsedIconColor: colorScheme.primary,
              title:
                  devices.isEmpty
                      ? Text(
                        "No devices added",
                        style: TextStyle(color: colorScheme.onSurface),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            devices[appState.selectedDeviceIndex].model,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            devices[appState.selectedDeviceIndex].name,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
              trailing: const AnimatedRotation(
                turns: 0,
                duration: Duration(milliseconds: 300),
                child: Icon(Icons.expand_more),
              ),
              children: const [],
            ),
          ),
        ),
      ),
    );
  }
}
