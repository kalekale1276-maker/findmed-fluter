import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/booking_models.dart';
import 'services/booking_services.dart';
import 'widgets/booking_widgets.dart';

/// Booking Page - Facility appointment booking
class BookingPage extends StatefulWidget {
  final String facilityId;
  final String facilityName;

  const BookingPage({
    Key? key,
    required this.facilityId,
    required this.facilityName,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  BookingState _state = const BookingState();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // State management
  void _updateState(BookingState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  // Date and time selection
  Future<void> _selectDate() async {
    _clearError();
    
    final DateTime? picked = await BookingServices.showDatePicker(context);
    if (picked != null && picked != _state.selectedDate) {
      _updateState(_state.copyWith(selectedDate: picked));
      
      // Clear time if it's no longer valid for the new date
      if (_state.selectedTime != null && 
          BookingServices.isTimeInPast(_state.selectedTime!, picked)) {
        _updateState(_state.copyWith(selectedTime: null));
      }
    }
  }

  Future<void> _selectTime() async {
    _clearError();
    
    if (_state.selectedDate == null) {
      _setError('Please select a date first');
      return;
    }
    
    final TimeOfDay? picked = await BookingServices.showTimePicker(context);
    if (picked != null) {
      // Check if time is in the past for today
      if (BookingServices.isTimeInPast(picked, _state.selectedDate!)) {
        _setError('Please select a future time');
        return;
      }
      
      _updateState(_state.copyWith(selectedTime: picked));
    }
  }

  // Booking submission
  Future<void> _submitBooking() async {
    // Create booking data
    final bookingData = _state.selectedDate != null && _state.selectedTime != null
        ? BookingData(
            facilityId: widget.facilityId,
            facilityName: widget.facilityName,
            date: _state.selectedDate!,
            time: _state.selectedTime!,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          )
        : null;

    // Validate booking
    final validation = BookingServices.validateBooking(bookingData);
    if (!validation.isValid) {
      _setError(validation.errorMessage!);
      return;
    }

    _setLoading(true);

    try {
      final result = await BookingServices.createBooking(bookingData!);
      
      if (result.success) {
        _showSuccessMessage(result.message!);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Book ${widget.facilityName}',
        style: TextStyle(
          fontSize: context.responsiveTextLg,
          fontWeight: FontWeight.bold,
          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
        size: context.isMobile ? 22.w : 24.w,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.responsiveGap),
            BookingWidgets.buildFacilityInfoCard(
              context: context,
              facilityName: widget.facilityName,
            ),
            BookingWidgets.buildSpacing(height: 24),
            BookingWidgets.buildDateTimeSelectionRow(
              context: context,
              selectedDate: _state.selectedDate,
              selectedTime: _state.selectedTime,
              onDatePressed: _selectDate,
              onTimePressed: _selectTime,
            ),
            BookingWidgets.buildSpacing(height: 24),
            BookingWidgets.buildNotesField(
              controller: _notesController,
              context: context,
            ),
            BookingWidgets.buildSpacing(height: 32),
            if (_state.error != null) ...[
              BookingWidgets.buildErrorMessage(
                context: context,
                message: _state.error!,
              ),
              BookingWidgets.buildSpacing(),
            ],
            BookingWidgets.buildSubmitButton(
              context: context,
              onPressed: _submitBooking,
              isLoading: _state.isLoading,
            ),
            BookingWidgets.buildSpacing(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }
}
