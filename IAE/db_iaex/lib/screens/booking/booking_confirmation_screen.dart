import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/buttons.dart';

/// Booking confirmation screen — date/time select, summary, confirm
class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});
  @override State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationHours = 2;

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _confirm(BuildContext context, BookingProvider prov) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
      return;
    }
    final venue = prov.selectedBooking!;
    final success = await prov.confirmBooking({
      'venue_id': venue.venueId,
      'date': '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
      'time': '${_selectedTime!.hour}:${_selectedTime!.minute}',
      'duration': _durationHours,
    });
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
      context.go('/home'); // Or go back to activity create
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BookingProvider>();
    final venue = prov.selectedBooking;

    if (venue == null) return const Scaffold(backgroundColor: AppColors.background);

    final total = venue.pricePerHour * _durationHours;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirm Booking'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Venue Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(venue.venueName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(venue.address ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 24),

          // Date & Time Select
          const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _pickerBox(Icons.calendar_today_rounded, _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'Select Date', _pickDate)),
            const SizedBox(width: 12),
            Expanded(child: _pickerBox(Icons.access_time_rounded, _selectedTime != null ? _selectedTime!.format(context) : 'Select Time', _pickTime)),
          ]),
          const SizedBox(height: 16),
          const Text('Duration (Hours)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline_rounded), onPressed: () { if (_durationHours > 1) setState(() => _durationHours--); }),
            Text('$_durationHours', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            IconButton(icon: const Icon(Icons.add_circle_outline_rounded), onPressed: () => setState(() => _durationHours++)),
          ]),
          const SizedBox(height: 32),

          // Payment Summary
          const Text('Payment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _summaryRow('Court Rate', 'Rp ${venue.pricePerHour.toStringAsFixed(0)} / hr'),
              const SizedBox(height: 8),
              _summaryRow('Duration', '$_durationHours hours'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: AppColors.border, height: 1)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ]),
            ]),
          ),
          const SizedBox(height: 32),
          PrimaryButton(label: 'Confirm & Pay', isLoading: prov.isLoading, onPressed: () => _confirm(context, prov)),
        ]),
      ),
    );
  }

  Widget _pickerBox(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]);
  }
}
