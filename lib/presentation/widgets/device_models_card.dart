import 'package:flutter/material.dart';

/// A card widget that displays a list of device models within an
/// expandable tile.
///
/// Allows the user to select a device model from the provided [models] list.
/// The selected model is displayed in the tile header.
/// Calls the [onModelSelected] callback when a model is chosen.
class DeviceModelsCard extends StatefulWidget {
  /// The list of device model names to display.
  final List<String> models;

  /// Callback function invoked when a model is selected.
  final ValueChanged<String>? onModelSelected;

  /// Creates a DeviceModelsCard.
  const DeviceModelsCard({
    super.key,
    required this.models,
    this.onModelSelected,
  });

  @override
  _DeviceModelsCardState createState() => _DeviceModelsCardState();
}

class _DeviceModelsCardState extends State<DeviceModelsCard> {
  String? _selectedModel;
  bool _isExpanded = false;
  int _expansionKey = 0; // Key counter to force tile reset

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(_expansionKey),
          onExpansionChanged:
              (expanded) => setState(() => _isExpanded = expanded),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          iconColor: theme.colorScheme.primary,
          collapsedIconColor: theme.colorScheme.primary,
          title: Text(
            _selectedModel ?? "طراز الجهاز",
            style: TextStyle(
              fontSize: 16,
              color:
                  _selectedModel != null
                      ? theme.textTheme.bodyLarge?.color
                      : theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
            textDirection: TextDirection.rtl,
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.expand_more),
          ),
          children: [
            Divider(
              indent: 30,
              endIndent: 30,
              thickness: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
            ...widget.models.map((model) => _buildModelItem(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelItem(String model) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(
            model,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color:
                  _selectedModel == model
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyLarge?.color,
            ),
          ),
          trailing:
              _selectedModel == model
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            setState(() {
              _selectedModel = model;
              _expansionKey++; // Force tile rebuild
            });
            widget.onModelSelected?.call(model);
          },
        ),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
