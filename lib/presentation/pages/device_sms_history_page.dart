import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:agrosys/controllers/sms_controller.dart';

class DeviceSmsHistoryPage extends StatefulWidget {
  final Device device;

  const DeviceSmsHistoryPage({
    super.key,
    required this.device,
  });

  @override
  State<DeviceSmsHistoryPage> createState() => _DeviceSmsHistoryPageState();
}

class _DeviceSmsHistoryPageState extends State<DeviceSmsHistoryPage> {
  final SmsQuery _query = SmsQuery();
  final SMSController _smsController = SMSController();
  List<SmsMessage> _messages = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _showToggle = true;
  double _lastScrollPosition = 0;
  double _pulseDuration = 10.0; // Default duration
  bool _isSettingDuration = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _lastScrollPosition) {
      // Scrolling down
      if (_showToggle) {
        setState(() {
          _showToggle = false;
        });
      }
    } else {
      // Scrolling up
      if (!_showToggle) {
        setState(() {
          _showToggle = true;
        });
      }
    }
    _lastScrollPosition = _scrollController.position.pixels;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var permission = await Permission.sms.status;
      if (!permission.isGranted) {
        permission = await Permission.sms.request();
      }

      if (!permission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يجب السماح بالوصول إلى الرسائل'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final deviceNumber = widget.device.phoneNumber
          .replaceAll('+', '')
          .replaceAll(' ', '');

      // Get both sent and received messages
      final inboxMessages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 100,
      );
      final sentMessages = await _query.querySms(
        kinds: [SmsQueryKind.sent],
        count: 100,
      );

      // Combine and filter messages
      final allMessages = [...inboxMessages, ...sentMessages];
      final filteredMessages = allMessages.where((message) {
        final sender = message.address?.replaceAll('+', '').replaceAll(' ', '') ?? '';
        return sender.contains(deviceNumber);
      }).toList();

      // Sort messages by date
      filteredMessages.sort((a, b) => b.date!.compareTo(a.date!));

      if (mounted) {
        setState(() {
          _messages = filteredMessages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setPulseDuration(double duration) async {
    setState(() {
      _isSettingDuration = true;
    });

    // Convert duration to GOT code (multiply by 2 and round to nearest integer)
    final gotValue = (duration * 2).round();
    final command = '${widget.device.passWord}#GOT$gotValue#';

    await _smsController.sendCommandWithResponse(
      context: context,
      phoneNumber: widget.device.phoneNumber,
      command: command,
      onMessage: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onResult: (success, response) {
        setState(() {
          _isSettingDuration = false;
        });

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في تعيين مدة النبضة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'أمس ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showToggle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 74,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'مدة تفعيل التبديل',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: _pulseDuration,
                                    min: 0,
                                    max: 49.5,
                                    divisions: 99,
                                    label: '${_pulseDuration.toStringAsFixed(1)} ثانية',
                                    onChanged: _isSettingDuration
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _pulseDuration = value;
                                            });
                                          },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: _isSettingDuration
                                      ? null
                                      : () => _setPulseDuration(_pulseDuration),
                                  icon: _isSettingDuration
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send, size: 20),
                                  tooltip: 'تعيين المدة',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageCard(message);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(SmsMessage message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Align(
      alignment: message.kind == SmsMessageKind.received ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: message.kind == SmsMessageKind.received ? 50 : 8,
          right: message.kind == SmsMessageKind.received ? 8 : 50,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.kind == SmsMessageKind.received
              ? (isDark ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1))
              : (isDark ? theme.colorScheme.secondary : theme.colorScheme.secondary.withOpacity(0.1)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.kind == SmsMessageKind.received ? 16 : 4),
            bottomRight: Radius.circular(message.kind == SmsMessageKind.received ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.body ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: message.kind == SmsMessageKind.received
                    ? (isDark ? Colors.white : theme.colorScheme.primary)
                    : (isDark ? Colors.white : theme.colorScheme.secondary),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  message.kind == SmsMessageKind.received ? Icons.download : Icons.upload,
                  size: 12,
                  color: message.kind == SmsMessageKind.received
                      ? (isDark ? Colors.white70 : theme.colorScheme.primary.withOpacity(0.7))
                      : (isDark ? Colors.white70 : theme.colorScheme.secondary.withOpacity(0.7)),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(message.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: message.kind == SmsMessageKind.received
                        ? (isDark ? Colors.white70 : theme.colorScheme.primary.withOpacity(0.7))
                        : (isDark ? Colors.white70 : theme.colorScheme.secondary.withOpacity(0.7)),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 