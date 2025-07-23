import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/delivery_model.dart';
import '../services/api_service.dart';

class ReschedulePopup extends StatefulWidget {
  final Function(List<Delivery>) onRescheduled;

  const ReschedulePopup({
    super.key,
    required this.onRescheduled,
  });

  @override
  State<ReschedulePopup> createState() => _ReschedulePopupState();
}

class _ReschedulePopupState extends State<ReschedulePopup> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  Location? _selectedLocation;
  List<String> _availableTimeSlots = [];
  List<Location> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadTimeSlots();
    await _loadLocations();
  }

  Future<void> _loadTimeSlots() async {
    try {
      final slots = await ApiService.getTimeSlots(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      setState(() {
        _availableTimeSlots = slots;
        _selectedTimeSlot = slots.isNotEmpty ? slots.first : null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load time slots: ${e.toString()}';
      });
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await ApiService.getLocations();
      setState(() {
        _locations = locations;
        _selectedLocation = locations.isNotEmpty ? locations.first : null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load locations: ${e.toString()}';
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadTimeSlots();
    }
  }

  Future<void> _reschedule() async {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      setState(() {
        _errorMessage = 'Please select both date and time slot';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rescheduledDeliveries = await ApiService.rescheduleDeliveries(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        timeSlot: _selectedTimeSlot!,
        location: _selectedLocation?.name,
      );

      widget.onRescheduled(rescheduledDeliveries);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deliveries rescheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Reschedule Delivery',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Date Selection
            const Text(
              'Select Reschedule Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                          : 'Select date',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time Slot Selection
            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedTimeSlot,
                hint: const Text('Select time slot'),
                isExpanded: true,
                underline: const SizedBox(),
                items: _availableTimeSlots.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeSlot = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Location Selection
            const Text(
              'Select Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<Location>(
                value: _selectedLocation,
                hint: const Text('Select location'),
                isExpanded: true,
                underline: const SizedBox(),
                items: _locations.map((location) {
                  return DropdownMenuItem<Location>(
                    value: location,
                    child: Text(location.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _reschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Reschedule',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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