import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/game_session.dart';
import '../../../sessions/providers/session_provider.dart';
import '../../../../core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AddSessionSheet extends StatefulWidget {
  const AddSessionSheet({super.key});

  @override
  State<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<AddSessionSheet> {
  DateTime _dateTime = DateTime.now();
  final TextEditingController _minutesCtrl = TextEditingController();
  GameMood _mood = GameMood.neutral;
  final TextEditingController _notesCtrl = TextEditingController();
  TimeOfDay? _reminderTime;

  @override
  void dispose() {
    _minutesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Add gaming session',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Date & time',
              child: OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('MMM d, HH:mm').format(_dateTime)),
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Minutes',
              child: TextField(
                controller: _minutesCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'e.g. 45'),
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Mood',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 360;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<GameMood>(
                      segments: const [
                        ButtonSegment(
                          value: GameMood.great,
                          icon: Icon(Icons.sentiment_very_satisfied),
                          label: Text('Great'),
                        ),
                        ButtonSegment(
                          value: GameMood.good,
                          icon: Icon(Icons.sentiment_satisfied),
                          label: Text('Good'),
                        ),
                        ButtonSegment(
                          value: GameMood.neutral,
                          icon: Icon(Icons.sentiment_neutral),
                          label: Text('OK'),
                        ),
                        ButtonSegment(
                          value: GameMood.tired,
                          icon: Icon(Icons.sentiment_dissatisfied),
                          label: Text('Tired'),
                        ),
                        ButtonSegment(
                          value: GameMood.stressed,
                          icon: Icon(Icons.sentiment_very_dissatisfied),
                          label: Text('Stress'),
                        ),
                      ],
                      selected: {_mood},
                      onSelectionChanged: (s) =>
                          setState(() => _mood = s.first),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Notes',
              child: TextField(
                controller: _notesCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Optional'),
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Daily reminder (optional)',
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickReminder,
                    icon: const Icon(Icons.alarm),
                    label: Text(
                      _reminderTime == null
                          ? 'Set time'
                          : _reminderTime!.format(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_reminderTime != null)
                    TextButton(
                      onPressed: () async {
                        await NotificationService.instance.cancel(1001);
                        setState(() => _reminderTime = null);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickReminder() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() => _reminderTime = time);
    await NotificationService.instance.scheduleDailyReminder(
      id: 1001,
      scheduleBuilder: (now) => tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    final minutes = int.tryParse(_minutesCtrl.text.trim());
    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter minutes > 0')));
      return;
    }
    final session = GameSession(
      startedAt: _dateTime,
      minutes: minutes,
      mood: _mood,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await context.read<SessionProvider>().addSession(session);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
