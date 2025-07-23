import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateCarousel extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateCarousel({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateCarousel> createState() => _DateCarouselState();
}

class _DateCarouselState extends State<DateCarousel> {
  late PageController _pageController;
  late List<DateTime> _dates;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateDates();
    _currentIndex = _dates.indexWhere(
      (date) => DateUtils.isSameDay(date, widget.selectedDate),
    );
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex, viewportFraction: 0.2);
  }

  void _generateDates() {
    _dates = [];
    final now = DateTime.now();
    for (int i = -2; i <= 10; i++) {
      _dates.add(now.add(Duration(days: i)));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          widget.onDateSelected(_dates[index]);
        },
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

          return GestureDetector(
            onTap: isPast
                ? null
                : () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              widget.onDateSelected(date);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black
                    : isPast
                        ? Colors.grey.shade200
                        : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Colors.black
                      : isToday
                          ? Colors.orange
                          : Colors.grey.shade300,
                  width: isSelected || isToday ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isPast
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isPast
                              ? Colors.grey.shade400
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}