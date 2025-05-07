import 'package:flutter/material.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/services/schedule_service.dart';
import 'package:agrosys/presentation/pages/schedule_page.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatefulWidget {
  final Device device;

  const ScheduleCard({super.key, required this.device});

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    debugPrint('ScheduleCard: Initializing for device ${widget.device.name}');
    debugPrint('ScheduleCard: Schedule enabled: ${widget.device.isScheduleEnabled}');
    if (widget.device.isScheduleEnabled) {
      debugPrint('ScheduleCard: Starting schedule service');
      _scheduleService.startScheduleCheck(widget.device);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('ScheduleCard: Setting context for schedule service');
    _scheduleService.setContext(context);
  }

  @override
  void dispose() {
    debugPrint('ScheduleCard: Disposing schedule service');
    _scheduleService.stopScheduleCheck();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('ScheduleCard: Widget updated');
    debugPrint('ScheduleCard: Old schedule enabled: ${oldWidget.device.isScheduleEnabled}');
    debugPrint('ScheduleCard: New schedule enabled: ${widget.device.isScheduleEnabled}');
    
    if (_hasScheduleChanged(oldWidget.device, widget.device)) {
      debugPrint('ScheduleCard: Schedule properties changed, updating service');
      _scheduleService.updateSchedule(widget.device);
    }
  }

  bool _hasScheduleChanged(Device oldDevice, Device newDevice) {
    return oldDevice.isScheduleEnabled != newDevice.isScheduleEnabled ||
           oldDevice.scheduleStartTime != newDevice.scheduleStartTime ||
           oldDevice.scheduleEndTime != newDevice.scheduleEndTime ||
           !_areListsEqual(oldDevice.scheduleDays, newDevice.scheduleDays);
  }

  bool _areListsEqual(List<bool> list1, List<bool> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // Day names in Arabic - short form
  final List<String> _dayNames = const [
    'إث',
    'ثل',
    'أر',
    'خم',
    'جم',
    'سب',
    'أح',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isScheduleActive = widget.device.isScheduleEnabled;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchedulePage(device: widget.device),
            ),
          );
        },
        splashColor:
            isScheduleActive
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.onSurface.withOpacity(0.1),
        highlightColor:
            isScheduleActive
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.onSurface.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors:
                  isScheduleActive
                      ? [
                        colorScheme.primary.withOpacity(0.8),
                        colorScheme.primary,
                      ]
                      : [
                        theme.brightness == Brightness.dark
                            ? colorScheme.surface.withOpacity(0.7)
                            : Colors.grey.shade200,
                        theme.brightness == Brightness.dark
                            ? colorScheme.surface
                            : Colors.grey.shade300,
                      ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    isScheduleActive
                        ? colorScheme.primary.withOpacity(0.3)
                        : theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background pattern
                if (isScheduleActive)
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.schedule,
                      size: 100,
                      color: colorScheme.onPrimary.withOpacity(0.1),
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isScheduleActive
                                      ? colorScheme.onPrimary
                                      : theme.brightness == Brightness.dark
                                      ? colorScheme.onSurface.withOpacity(0.4)
                                      : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isScheduleActive ? 'مفعّل' : 'غير مفعّل',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isScheduleActive
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withOpacity(
                                          0.9,
                                        ),
                              ),
                            ),
                          ),
                          // Title
                          Row(
                            children: [
                              Text(
                                'جدول الطاقة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isScheduleActive
                                          ? colorScheme.onPrimary
                                          : theme.brightness == Brightness.dark
                                          ? colorScheme.onSurface
                                          : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit,
                                size: 16,
                                color:
                                    isScheduleActive
                                        ? colorScheme.onPrimary.withOpacity(0.7)
                                        : theme.brightness == Brightness.dark
                                        ? colorScheme.onSurface.withOpacity(0.7)
                                        : Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (isScheduleActive) ...[
                        // Time info with icons
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInfo(
                                context,
                                icon: Icons.power,
                                title: 'وقت البدء',
                                time: widget.device.scheduleStartTime,
                                isActiveSchedule: true,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: colorScheme.onPrimary.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildTimeInfo(
                                context,
                                icon: Icons.power_off,
                                title: 'وقت الانتهاء',
                                time: widget.device.scheduleEndTime,
                                isActiveSchedule: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Days display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'أيام التشغيل',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(7, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color:
                                          widget.device.scheduleDays[index]
                                              ? colorScheme.onPrimary
                                              : colorScheme.onPrimary
                                                  .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      boxShadow:
                                          widget.device.scheduleDays[index]
                                              ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _dayNames[index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              widget.device.scheduleDays[index]
                                                  ? colorScheme.primary
                                                  : colorScheme.onPrimary
                                                      .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ] else
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.timer_off,
                                size: 40,
                                color:
                                    theme.brightness == Brightness.dark
                                        ? colorScheme.onSurface.withOpacity(0.7)
                                        : Colors.grey.shade600,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'لم يتم تعيين جدول',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      theme.brightness == Brightness.dark
                                          ? colorScheme.onSurface.withOpacity(
                                            0.7,
                                          )
                                          : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(
    BuildContext context, {
    required IconData icon,
    required String title,
    required TimeOfDay? time,
    required bool isActiveSchedule,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedTime =
        time != null
            ? DateFormat(
                  'hh:mm',
                  'en',
                ).format(DateTime(2023, 1, 1, time.hour, time.minute)) +
                (time.hour < 12 ? ' صباحاً' : ' مساءً')
            : 'غير محدد';

    final color =
        isActiveSchedule ? colorScheme.onPrimary : colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color.withOpacity(0.9), size: 22),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedTime,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
