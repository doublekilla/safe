import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/sport_categories.dart';
import '../../providers/activities_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/search_and_chips.dart';

/// Edit activity screen
class EditActivityScreen extends StatefulWidget {
  const EditActivityScreen({super.key});
  @override State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _locationCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();
  final _quotaCtl = TextEditingController();
  final _costCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  String _sportType = 'badminton';
  String _activityType = 'fun_match';
  String _skillLevel = 'beginner';
  bool _connectBooking = false;
  int? _activityId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final act = context.read<ActivitiesProvider>().selectedActivity;
      if (act != null) {
        _activityId = act.id;
        _nameCtl.text = act.title;
        _locationCtl.text = act.location ?? '';
        if (act.date != null) {
          try {
            final d = DateTime.parse(act.date!).toLocal();
            _dateCtl.text = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          } catch (_) {
            _dateCtl.text = act.date!.length >= 10 ? act.date!.substring(0, 10) : '';
          }
        }
        _timeCtl.text = act.time ?? '';
        _quotaCtl.text = act.quota.toString();
        _costCtl.text = act.cost.toStringAsFixed(0);
        _notesCtl.text = act.notes ?? '';
        setState(() {
          _sportType = act.sportType;
          _activityType = act.activityType ?? 'fun_match';
          _skillLevel = act.skillLevel ?? 'beginner';
        });
      }
    });
  }

  @override
  void dispose() { _nameCtl.dispose(); _locationCtl.dispose(); _dateCtl.dispose(); _timeCtl.dispose(); _quotaCtl.dispose(); _costCtl.dispose(); _notesCtl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null) {
      _dateCtl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      if (_timeCtl.text.isNotEmpty) {
        try {
          final selectedDate = DateTime.parse('${_dateCtl.text} ${_timeCtl.text}:00');
          if (selectedDate.isBefore(DateTime.now())) {
            _timeCtl.text = '';
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time is in the past for this date. Please pick again.'), backgroundColor: Colors.red));
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _pickTime() async {
    if (_dateCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date first.')));
      return;
    }
    
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      try {
        final newDateTime = DateTime.parse('${_dateCtl.text} $timeStr:00');
        if (newDateTime.isBefore(DateTime.now())) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot select a past time.'), backgroundColor: Colors.red));
          return;
        }
      } catch (_) {}
      
      _timeCtl.text = timeStr;
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _activityId == null) return;
    
    if (_dateCtl.text.isNotEmpty && _timeCtl.text.isNotEmpty) {
      try {
        final selectedDate = DateTime.parse('${_dateCtl.text} ${_timeCtl.text}:00');
        if (selectedDate.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cannot set an activity time in the past.'),
            backgroundColor: Colors.red,
          ));
          return;
        }
      } catch (_) {}
    }
    final prov = context.read<ActivitiesProvider>();
    final success = await prov.updateActivity(_activityId!, {
      'title': _nameCtl.text.trim(), 'sport_type': _sportType, 'activity_type': _activityType,
      'location': _locationCtl.text.trim(), 'date': _dateCtl.text, 'time': _timeCtl.text,
      'quota': int.tryParse(_quotaCtl.text) ?? 10, 'cost': double.tryParse(_costCtl.text) ?? 0,
      'skill_level': _skillLevel, 'notes': _notesCtl.text.trim(),
    });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity updated!')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ActivitiesProvider>();
    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(backgroundColor: AppColors.cardSurface, title: const Text('Edit Activity'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Activity Name'),
          TextFormField(controller: _nameCtl, decoration: const InputDecoration(hintText: 'e.g. Mabar Badminton Senayan'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          const SizedBox(height: 14),
          _label('Sport Type'),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: SportCategory.values.where((s) => s != SportCategory.all).map((s) => CategoryChip(label: s.label, icon: s.icon, isSelected: _sportType == s.value, onTap: () => setState(() => _sportType = s.value))).toList()),
          const SizedBox(height: 14),
          _label('Activity Type'),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: ActivityType.values.map((t) => CategoryChip(label: t.label, isSelected: _activityType == t.value, onTap: () => setState(() => _activityType = t.value))).toList()),
          const SizedBox(height: 14),
          _label('Location'),
          TextFormField(controller: _locationCtl, decoration: const InputDecoration(hintText: 'Venue or location name', prefixIcon: Icon(Icons.location_on_outlined, size: 20)), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Date'),
              TextFormField(controller: _dateCtl, readOnly: true, onTap: _pickDate, decoration: const InputDecoration(hintText: 'Select date', prefixIcon: Icon(Icons.calendar_today_rounded, size: 18))),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Time'),
              TextFormField(controller: _timeCtl, readOnly: true, onTap: _pickTime, decoration: const InputDecoration(hintText: 'Select time', prefixIcon: Icon(Icons.access_time_rounded, size: 18))),
            ])),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Quota'),
              TextFormField(
                controller: _quotaCtl, 
                keyboardType: TextInputType.number, 
                decoration: const InputDecoration(hintText: '10'),
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val < 2) return 'Min 2';
                  return null;
                },
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Cost (IDR)'),
              TextFormField(controller: _costCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '0 = Free')),
            ])),
          ]),
          const SizedBox(height: 14),
          _label('Skill Level'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)),
            child: Row(children: SkillLevel.values.map((l) {
              final sel = _skillLevel == l.value;
              return Expanded(child: GestureDetector(onTap: () => setState(() => _skillLevel = l.value), child: AnimatedContainer(
                duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: sel ? AppColors.buttonPrimary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(l.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary))),
              )));
            }).toList()),
          ),
          const SizedBox(height: 14),
          _label('Notes'),
          TextFormField(controller: _notesCtl, maxLines: 3, decoration: const InputDecoration(hintText: 'Additional information...')),
          const SizedBox(height: 16),
          // Connect to booking toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.sports_tennis_rounded, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Connect to Court Booking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('Book a venue for this activity', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Switch.adaptive(value: _connectBooking, onChanged: (v) => setState(() => _connectBooking = v), activeTrackColor: AppColors.buttonPrimary),
            ]),
          ),
          if (_connectBooking) ...[
            const SizedBox(height: 12),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: const Text('Venue integration coming soon...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center)),
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Update Activity',
            isLoading: prov.isLoading,
            onPressed: _update,
          ),
          const SizedBox(height: 32),
        ])),
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
}
