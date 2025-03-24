import 'package:flutter/material.dart';
import '../themes/colors.dart';

class DeviceModelsCard extends StatefulWidget {
  final List<String> models;
  final ValueChanged<String>? onModelSelected;

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
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(_expansionKey), // Key to force rebuild
          onExpansionChanged:
              (expanded) => setState(() => _isExpanded = expanded),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          iconColor: Colors.green[700],
          collapsedIconColor: Colors.green[700],
          title: Text(
            _selectedModel ?? "طراز الجهاز",
            style: TextStyle(
              fontSize: 16,
              color: _selectedModel != null ? Colors.black : Colors.grey[600],
            ),
            textDirection: TextDirection.rtl,
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.expand_more),
          ),
          children: [
            Divider(indent: 30, endIndent: 30, thickness: 1, color: mainColor),
            ...widget.models.map((model) => _buildModelItem(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelItem(String model) {
    return Column(
      children: [
        ListTile(
          title: Text(
            model,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _selectedModel == model ? mainColor : Colors.black,
            ),
          ),
          trailing:
              _selectedModel == model
                  ? Icon(Icons.check_circle, color: mainColor)
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
        Divider(indent: 30, endIndent: 30, thickness: 1, color: mainColor),
      ],
    );
  }
}
