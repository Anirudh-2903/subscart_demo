import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'models/delivery_model.dart';
import 'services/api_service.dart';
import 'widgets/date_carousel.dart';
import 'widgets/delivery_card.dart';
import 'widgets/reschedule_popup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return Colors.grey.shade300;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return Colors.grey.shade400;
          }),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const MealPlanScreen(),
    );
  }
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Delivery> _deliveries = [];
  List<Delivery> _originalDeliveries = [];
  String? _selectedLocation;
  String? _selectedTimeSlot;
  bool _isLoading = true;
  bool _isPaused = false;
  String? _errorMessage;
  List<Location> _locations = [];
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final deliveries = await ApiService.getDeliveries(date: dateString);
      final locations = await ApiService.getLocations();
      final slots = await ApiService.getTimeSlots(date: dateString);

      setState(() {
        _originalDeliveries = deliveries;
        _deliveries = deliveries;
        _locations = locations;
        _timeSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = null;
      _selectedTimeSlot = null;
      _deliveries = _originalDeliveries;
    });
  }

  void _filterDeliveries() {
    List<Delivery> filteredDeliveries = _originalDeliveries;

    // Filter by location if selected
    if (_selectedLocation != null) {
      filteredDeliveries = filteredDeliveries
          .where((delivery) => delivery.location.toString() == _selectedLocation)
          .toList();
    }

    // Filter by time slot if selected
    if (_selectedTimeSlot != null) {
      filteredDeliveries = filteredDeliveries
          .where((delivery) => delivery.timeSlot.toString() == _selectedTimeSlot)
          .toList();
    }

    setState(() {
      _deliveries = filteredDeliveries;
    });
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
    });
    await _loadData();
  }

  Future<void> _skipDelivery(Delivery delivery) async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery skipped successfully!'),
          backgroundColor: Colors.black,
        ),
      );
  }

  Future<void> _swapDelivery(Delivery delivery) async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deliveries swapped successfully!'),
          backgroundColor: Colors.black,
        ),
      );
  }

  Future<void> _moveDelivery(Delivery delivery) async {
    final currentIndex = _deliveries.indexWhere((d) => d.id == delivery.id);
    final direction = currentIndex > 0 ? 'up' : 'down';

    try {
      final updatedDeliveries = await ApiService.moveDelivery(delivery.id, direction);
      setState(() {
        _deliveries = updatedDeliveries;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery moved successfully!'),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to move delivery: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReschedulePopup() {
    showDialog(
      context: context,
      builder: (context) => ReschedulePopup(
        onRescheduled: (updatedDeliveries) {
          setState(() {
            _deliveries = updatedDeliveries;
          });
        },
      ),
    );
  }

  Future<void> _togglePause() async {
    try {
      setState(() {
        _isPaused = !_isPaused;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPaused ? 'Subscription paused' : 'Subscription resumed'),
          backgroundColor: _isPaused ? Colors.orange : Colors.green,
        ),
  );
    } catch (e) {
      setState(() {
        _isPaused = !_isPaused; // Revert on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update subscription: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Open drawer or navigation menu
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu coming soon!'),
                backgroundColor: Colors.blue,
              ),
            );
          },
        ),
        title: const Text(
          'Subscriptions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Your meal plan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Date Carousel
          DateCarousel(
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),

          // Pause Section
          Padding (
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
           child : Container(
            decoration: BoxDecoration(
              color: Colors.white, // Light grey background
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Text(
                  'Pause',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isPaused,
                  onChanged: (value) => _togglePause(),
                  activeColor: Colors.orange,
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                     if (states.contains(MaterialState.selected)) {
                        return const Icon(Icons.play_arrow);
                      }
                      return const Icon(Icons.pause); // All other states will use the default thumbIcon.
                    }),
                  thumbColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey.shade400;
                      } else if (states.contains(MaterialState.selected)) {
                        return Colors.white;
                      }
                      return Colors.grey.shade200;
                    },
                  ),
                ),
              ],
            ),
          )
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
            child : Container(
            decoration: BoxDecoration(
            color: Colors.white, // Light grey background
            borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedLocation,
                    hint: const Text('Location'),
                    items: _locations
                        .map((loc) => DropdownMenuItem<String>(
                      value: loc.name,
                      child: Text(loc.name),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() { _selectedLocation = val;_filterDeliveries(); }),
                  ),
                ),
                const SizedBox(width: 8),

                // --- Time Slot Dropdown ---
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTimeSlot,
                    hint: const Text('Time Slot'),
                    items: _timeSlots
                        .map((slot) => DropdownMenuItem<String>(
                      value: slot,
                      child: Text(slot),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() { _selectedTimeSlot = val;_filterDeliveries(); }),
                  ),
                ),
                const SizedBox(width: 8),

                if (_selectedLocation != null || _selectedTimeSlot != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16)
                    ),
                    child: const Text("Reset"),
                    onPressed: _resetFilters,
                  ),
                const SizedBox(width: 8),

                // --- Black Reschedule Button ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16)
                  ),
                  child: const Text("Reschedule"),
                  onPressed: _showReschedulePopup,
                ),
              ],
            ),
            ),
          ),

          // Deliveries Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _deliveries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.no_meals,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No deliveries scheduled for ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _deliveries.length,
                            itemBuilder: (context, index) {
                              final delivery = _deliveries[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DeliveryCard(
                                  delivery: delivery,
                                  onSkip: () => _skipDelivery(delivery),
                                  onSwap: () => _swapDelivery(delivery),
                                  onMove: () => _moveDelivery(delivery),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}