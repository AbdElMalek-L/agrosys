import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/presentation/services/schedule_service.dart';

class SchedulePage extends StatefulWidget {
  final Device device;

  const SchedulePage({super.key, required this.device});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TimeOfDay? _startTime;
  late TimeOfDay? _endTime;
  late bool _isScheduleEnabled;
  late List<bool> _scheduleDays;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ScheduleService _scheduleService = ScheduleService();

  // Day names in Arabic
  final List<String> _dayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  void initState() {
    super.initState();
    _startTime = widget.device.scheduleStartTime;
    _endTime = widget.device.scheduleEndTime;
    _isScheduleEnabled = widget.device.isScheduleEnabled;
    _scheduleDays = List.from(widget.device.scheduleDays.isEmpty ? List.filled(7, true) : widget.device.scheduleDays);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isScheduleEnabled) {
      _animationController.value = 1.0;
    }

    // Debug logs
    debugPrint('SchedulePage: Initializing for device ${widget.device.name}');
    debugPrint('SchedulePage: Schedule enabled: $_isScheduleEnabled');
    debugPrint('SchedulePage: Start time: $_startTime');
    debugPrint('SchedulePage: End time: $_endTime');
    debugPrint('SchedulePage: Schedule days: $_scheduleDays');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleService.setContext(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final ThemeData theme = Theme.of(context);
    final TimeOfDay initialTime =
        isStartTime
            ? _startTime ?? TimeOfDay.now()
            : _endTime ?? TimeOfDay.now();

    // Convert to 24-hour format for display
    final initialHour = initialTime.hourOfPeriod == 12 ? (initialTime.period == DayPeriod.pm ? 12 : 0) : 
                       (initialTime.period == DayPeriod.pm ? initialTime.hourOfPeriod + 12 : initialTime.hourOfPeriod);
    final initialTime24 = TimeOfDay(hour: initialHour, minute: initialTime.minute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime24,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.scaffoldBackgroundColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodColor: theme.colorScheme.primaryContainer,
              dayPeriodTextColor: theme.colorScheme.onPrimaryContainer,
              hourMinuteColor: theme.colorScheme.primaryContainer,
              hourMinuteTextColor: theme.colorScheme.onPrimaryContainer,
              dialHandColor: theme.colorScheme.primary,
              dialBackgroundColor: theme.colorScheme.surfaceContainerHighest,
              hourMinuteTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              helpTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          debugPrint('SchedulePage: Start time set to ${picked.hour}:${picked.minute}');
        } else {
          _endTime = picked;
          debugPrint('SchedulePage: End time set to ${picked.hour}:${picked.minute}');
        }
      });

      // Update schedule immediately when time is changed
      _updateSchedule();
    }
  }

  void _updateSchedule() {
    debugPrint('SchedulePage: Updating schedule');
    debugPrint('SchedulePage: Enabled: $_isScheduleEnabled');
    debugPrint('SchedulePage: Start time: $_startTime');
    debugPrint('SchedulePage: End time: $_endTime');
    debugPrint('SchedulePage: Days: $_scheduleDays');

    final deviceCubit = context.read<DeviceCubit>();
    final updatedDevice = widget.device.copyWith(
      isScheduleEnabled: _isScheduleEnabled,
      scheduleStartTime: _startTime,
      scheduleEndTime: _endTime,
      scheduleDays: _scheduleDays,
    );

    // Update the device in the cubit
    deviceCubit.updateDevice(widget.device, updatedDevice);

    // Update the schedule service
    _scheduleService.stopScheduleCheck(); // Stop existing schedule
    if (_isScheduleEnabled) {
      _scheduleService.startScheduleCheck(updatedDevice); // Start new schedule
    }

    // Show save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isScheduleEnabled ? 'تم حفظ الجدول' : 'تم إلغاء تفعيل الجدول'),
        backgroundColor: _isScheduleEnabled ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required bool isStartTime,
    required String title,
    required IconData icon,
  }) {
    final time = isStartTime ? _startTime : _endTime;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Format time in 24-hour format
    String formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? colorScheme.surface
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectTime(context, isStartTime),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color:
                              theme.brightness == Brightness.dark
                                  ? colorScheme.onSurface.withOpacity(0.7)
                                  : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time != null ? formatTime(time) : 'اختر الوقت',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              time != null
                                  ? theme.brightness == Brightness.dark
                                      ? colorScheme.onSurface
                                      : Colors.black87
                                  : theme.brightness == Brightness.dark
                                  ? colorScheme.onSurface.withOpacity(0.5)
                                  : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color:
                      theme.brightness == Brightness.dark
                          ? colorScheme.onSurface.withOpacity(0.5)
                          : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Header(title: 'جدول الطاقة - ${widget.device.name}'),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              theme.brightness == Brightness.dark
                  ? theme.scaffoldBackgroundColor
                  : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enable Schedule Switch with animation
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          theme.brightness == Brightness.dark
                              ? colorScheme.surface
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تفعيل الجدول',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _isScheduleEnabled
                                                ? colorScheme.primary
                                                : theme.brightness ==
                                                    Brightness.dark
                                                ? colorScheme.onSurface
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isScheduleEnabled
                                          ? 'الجهاز سيعمل حسب الجدول المُحدد'
                                          : 'اضغط للتفعيل',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            theme.brightness == Brightness.dark
                                                ? colorScheme.onSurface
                                                    .withOpacity(0.7)
                                                : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isScheduleEnabled,
                                activeColor: colorScheme.primary,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isScheduleEnabled = value;
                                  });

                                  if (value) {
                                    _animationController.forward();
                                  } else {
                                    _animationController.reverse();
                                  }

                                  // Update schedule immediately when toggle is changed
                                  _updateSchedule();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated schedule settings
                  SizeTransition(
                    sizeFactor: _animation,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إعدادات الجدول',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.brightness == Brightness.dark
                                      ? colorScheme.onSurface
                                      : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time selection cards
                          _buildTimeSelector(
                            isStartTime: true,
                            title: 'وقت البدء',
                            icon: Icons.power_settings_new,
                          ),
                          _buildTimeSelector(
                            isStartTime: false,
                            title: 'وقت الانتهاء',
                            icon: Icons.power_off,
                          ),

                          const SizedBox(height: 24),

                          // Days selection
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  theme.brightness == Brightness.dark
                                      ? colorScheme.surface
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.brightness == Brightness.dark
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'أيام التشغيل',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _scheduleDays = List.filled(
                                                7,
                                                true,
                                              );
                                            });
                                          },
                                          child: Text(
                                            'اختيار الكل',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _scheduleDays = List.filled(
                                                7,
                                                false,
                                              );
                                            });
                                          },
                                          child: Text(
                                            'إلغاء الكل',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark
                                                      ? colorScheme.onSurface
                                                          .withOpacity(0.7)
                                                      : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Day selection chips with better layout
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 12.0,
                                  children: List.generate(7, (index) {
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.26,
                                      child: FilterChip(
                                        label: Text(
                                          _dayNames[index],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        selected: _scheduleDays[index],
                                        checkmarkColor:
                                            theme.brightness == Brightness.dark
                                                ? colorScheme.onPrimary
                                                : Colors.white,
                                        selectedColor: colorScheme.primary,
                                        backgroundColor:
                                            theme.brightness == Brightness.dark
                                                ? colorScheme
                                                    .surfaceContainerHighest
                                                : Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          side: BorderSide(
                                            color:
                                                _scheduleDays[index]
                                                    ? Colors.transparent
                                                    : theme.brightness ==
                                                        Brightness.dark
                                                    ? colorScheme.outline
                                                        .withOpacity(0.5)
                                                    : Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        labelStyle: TextStyle(
                                          color:
                                              _scheduleDays[index]
                                                  ? theme.brightness ==
                                                          Brightness.dark
                                                      ? colorScheme.onPrimary
                                                      : Colors.white
                                                  : theme.brightness ==
                                                      Brightness.dark
                                                  ? colorScheme.onSurface
                                                  : Colors.black87,
                                          fontWeight:
                                              _scheduleDays[index]
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 10,
                                        ),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _scheduleDays[index] = selected;
                                          });
                                        },
                                        showCheckmark: false,
                                        elevation: _scheduleDays[index] ? 2 : 0,
                                        pressElevation: 4,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save button
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isScheduleEnabled && _startTime != null && _endTime != null
                            ? () {
                                _updateSchedule();
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          disabledBackgroundColor:
                              theme.brightness == Brightness.dark
                                  ? colorScheme.onSurface.withOpacity(0.2)
                                  : Colors.grey.shade300,
                          disabledForegroundColor:
                              theme.brightness == Brightness.dark
                                  ? colorScheme.onSurface.withOpacity(0.5)
                                  : Colors.grey.shade500,
                        ),
                        child: const Text(
                          'حفظ الجدول',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
