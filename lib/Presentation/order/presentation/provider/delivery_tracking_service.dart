import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';

/// Class to manage the state of a delivery animation
class DeliveryState {
  final String orderId;
  List<LatLng> deliveryTrack; // Non-final to allow updates
  final LatLng marketLocation;
  final LatLng clientLocation;
  OrderStatus currentOrderStatus;
  LatLng deliveryPersonPosition;
  double animationProgress;
  bool isAnimating;
  
  DeliveryState({
    required this.orderId,
    required this.deliveryTrack,
    required this.marketLocation,
    required this.clientLocation,
    required this.currentOrderStatus,
    required this.deliveryPersonPosition,
    required this.animationProgress,
    required this.isAnimating,
  });
}

/// Service to track delivery animation across multiple screens
class DeliveryTrackingService {
  // Singleton pattern
  static final DeliveryTrackingService _instance = DeliveryTrackingService._internal();
  factory DeliveryTrackingService() => _instance;
  DeliveryTrackingService._internal();

  // Private fields for tracking state
  final Map<String, DeliveryState> _deliveryStates = {};
  
  // Animation timers for each order
  final Map<String, Timer> _animationTimers = {};
  
  // Stream controllers for each order
  final Map<String, StreamController<DeliveryState>> _controllers = {};

  // Enable verbose logging for debugging
  bool verbose = true;

  // Get or create a stream for a specific order
  Stream<DeliveryState> getDeliveryStateStream(String orderId) {
    if (!_controllers.containsKey(orderId)) {
      _controllers[orderId] = StreamController<DeliveryState>.broadcast();
    }
    return _controllers[orderId]!.stream;
  }

  // Initialize tracking for an order
  void initializeTracking(
    String orderId,
    OrderStatus orderStatus,
    List<LatLng> route,
    LatLng marketLocation,
    LatLng clientLocation,
  ) {
    
    // Only initialize if not already tracking this order
    if (!_deliveryStates.containsKey(orderId)) {
      
      _deliveryStates[orderId] = DeliveryState(
        orderId: orderId,
        animationProgress: 0.0,
        currentOrderStatus: orderStatus,
        deliveryTrack: List<LatLng>.from(route), // Create a copy to avoid reference issues
        marketLocation: marketLocation,
        clientLocation: clientLocation,
        deliveryPersonPosition: marketLocation,
        isAnimating: false,
      );
      
      // If the order is already in delivering status, start the animation
      if (orderStatus == OrderStatus.Delivering) {
        startDeliveryAnimation(orderId);
      } else {
        _log("Order $orderId is in ${orderStatus.toString()} status, not starting animation yet");
      }
      
      // Immediately notify listeners of the initial state
      _notifyListeners(orderId);
    } else {
      _log("Already tracking order $orderId - updating route");
      // Update the route if it changed
      final state = _deliveryStates[orderId]!;
      state.deliveryTrack = List<LatLng>.from(route);
      
      // If status has changed to Delivering, start animation
      if (orderStatus == OrderStatus.Delivering && state.currentOrderStatus != OrderStatus.Delivering) {
        state.currentOrderStatus = orderStatus;
        startDeliveryAnimation(orderId);
      } else {
        state.currentOrderStatus = orderStatus;
        _notifyListeners(orderId);
      }
    }
    
    // Debug log the current state
    debugPrintStatus();
  }

  // Update order status
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    
    if (_deliveryStates.containsKey(orderId)) {
      final state = _deliveryStates[orderId]!;
      
      
      // Handle status change
      if (state.currentOrderStatus != newStatus) {
        state.currentOrderStatus = newStatus;
        
        if (newStatus == OrderStatus.isReceived) {
          // If received, move delivery person to client location
          stopDeliveryAnimation(orderId);
          state.deliveryPersonPosition = state.clientLocation;
          state.animationProgress = 1.0;
          _notifyListeners(orderId);
        } else if (newStatus == OrderStatus.Delivering) {
          // If delivering, start animation if not already
          _log("Order $orderId is now delivering");
          if (!state.isAnimating) {
            startDeliveryAnimation(orderId);
          } else {
            _log("Animation already in progress for order $orderId");
          }
        } else {
          // For other statuses, stop animation
          stopDeliveryAnimation(orderId);
          _notifyListeners(orderId);
        }
      } else {
        _log("Status remains ${newStatus.toString()} for order $orderId");
      }
    } else {
      _log("WARNING: Attempted to update status for non-existent order $orderId");
    }
    
    // Debug log the current state
    debugPrintStatus();
  }

  // Start delivery animation - detailed debugging
  void startDeliveryAnimation(String orderId) {
    if (!_deliveryStates.containsKey(orderId)) {
      _log("ERROR: Cannot start animation - no tracking state for order $orderId");
      return;
    }
    
    // Stop any existing animation first
    stopDeliveryAnimation(orderId);
    
    final state = _deliveryStates[orderId]!;
    
    
    // Reset animation progress to start from market if needed
    if (state.animationProgress <= 0.0) {
      state.animationProgress = 0.0;
      state.deliveryPersonPosition = state.marketLocation;
    } else {
      _log("Continuing animation from progress ${state.animationProgress}");
    }
    
    state.isAnimating = true;
    
    // For debugging - make the animation faster
    final double progressIncrement = 0.002; // 0.2% progress per 100ms
    
    // Create a timer for animation with a more reasonable speed for testing
    _animationTimers[orderId] = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_deliveryStates.containsKey(orderId)) {
        timer.cancel();
        _animationTimers.remove(orderId);
        return;
      }
      
      final state = _deliveryStates[orderId]!;
      
      if (!state.isAnimating || state.currentOrderStatus != OrderStatus.Delivering) {
        timer.cancel();
        _animationTimers.remove(orderId);
        return;
      }
      
      // Update animation progress
      state.animationProgress += progressIncrement;
      
      // Debug info every 5% progress
      if ((state.animationProgress * 20).floor() != ((state.animationProgress - progressIncrement) * 20).floor()) {
        _log("Order $orderId animation: ${(state.animationProgress * 100).toStringAsFixed(1)}%");
      }
      
      // When we reach the client location (100%), finish the animation
      if (state.animationProgress >= 1.0) {
        state.animationProgress = 1.0;
        state.deliveryPersonPosition = state.clientLocation;
        timer.cancel();
        _animationTimers.remove(orderId);
        state.isAnimating = false;
      } else {
        // Update delivery person position along the route
        _updateDeliveryPosition(orderId);
      }
      
      // Notify listeners of the updated state
      _notifyListeners(orderId);
    });
    
    _notifyListeners(orderId);
  }
  
  // Stop delivery animation
  void stopDeliveryAnimation(String orderId) {
    if (_animationTimers.containsKey(orderId)) {
      _animationTimers[orderId]!.cancel();
      _animationTimers.remove(orderId);
      
      if (_deliveryStates.containsKey(orderId)) {
        _deliveryStates[orderId]!.isAnimating = false;
      }
    } else {
      _log("No animation to stop for order $orderId");
    }
  }
  
  // Update delivery person position based on animation progress
  void _updateDeliveryPosition(String orderId) {
    if (!_deliveryStates.containsKey(orderId)) {
      return;
    }
    
    final state = _deliveryStates[orderId]!;
    
    if (state.deliveryTrack.length < 2) {
      return;
    }
    
    // Get the position based on animation progress
    int pointCount = state.deliveryTrack.length;
    
    // Calculate the index in the route array
    int index = (state.animationProgress * (pointCount - 1)).floor();
    index = index.clamp(0, pointCount - 2);

    LatLng point1 = state.deliveryTrack[index];
    LatLng point2 = state.deliveryTrack[index + 1];

    // Calculate position between the two points
    double segmentProgress = (state.animationProgress * (pointCount - 1)) - index;

    double lat = point1.latitude + (point2.latitude - point1.latitude) * segmentProgress;
    double lng = point1.longitude + (point2.longitude - point1.longitude) * segmentProgress;

    // Update delivery person position
    LatLng newPosition = LatLng(lat, lng);
    
    // Log position change occasionally
    if ((state.animationProgress * 20).floor() != ((state.animationProgress - 0.002) * 20).floor()) {
      _log("Moved delivery person to $newPosition (index=$index, segment=$segmentProgress)");
    }
    
    state.deliveryPersonPosition = newPosition;
  }
  
  // Notify listeners of state changes
  void _notifyListeners(String orderId) {
    if (_controllers.containsKey(orderId) && _deliveryStates.containsKey(orderId)) {
      try {
        _controllers[orderId]!.add(_deliveryStates[orderId]!);
        if (verbose) _log("Notified listeners for order $orderId");
      } catch (e) {
        _log("ERROR: Failed to notify listeners: $e");
      }
    } else {
      _log("WARNING: Cannot notify listeners - controller or state missing for order $orderId");
    }
  }
  
  // Get current delivery progress (0.0 to 1.0)
  double getDeliveryProgress(String orderId) {
    if (!_deliveryStates.containsKey(orderId)) return 0.0;
    
    final state = _deliveryStates[orderId]!;
    
    if (state.currentOrderStatus == OrderStatus.isReceived) {
      return 1.0; // Complete
    } else if (state.currentOrderStatus == OrderStatus.Delivering) {
      return 0.2 + (state.animationProgress * 0.8); // 20% to 100%
    } else if (state.currentOrderStatus == OrderStatus.isProcessing) {
      return 0.4; // 40%
    } else {
      return 0.2; // Initial 20%
    }
  }
  
  // Get specific state for testing/debugging
  DeliveryState? getDeliveryState(String orderId) {
    return _deliveryStates[orderId];
  }
  
  // Force set position for testing
  void debugSetPosition(String orderId, LatLng position) {
    if (_deliveryStates.containsKey(orderId)) {
      _deliveryStates[orderId]!.deliveryPersonPosition = position;
      _notifyListeners(orderId);
    }
  }
  
  // Manually trigger animation step for testing
  void debugStepAnimation(String orderId) {
    if (_deliveryStates.containsKey(orderId)) {
      final state = _deliveryStates[orderId]!;
      state.animationProgress += 0.05;
      if (state.animationProgress > 1.0) state.animationProgress = 1.0;
      _updateDeliveryPosition(orderId);
      _notifyListeners(orderId);
    }
  }
  
  // Check if an order is currently being tracked
  bool isTracking(String orderId) {
    return _deliveryStates.containsKey(orderId);
  }
  
  // Get all currently tracked order IDs
  List<String> getTrackedOrderIds() {
    return _deliveryStates.keys.toList();
  }
  
  // Dispose of resources for an order
  void dispose(String orderId) {
    stopDeliveryAnimation(orderId);
    if (_controllers.containsKey(orderId)) {
      _controllers[orderId]!.close();
      _controllers.remove(orderId);
    }
    _deliveryStates.remove(orderId);
  }
  
  // Dispose of all resources
  void disposeAll() {
    for (final orderId in _deliveryStates.keys.toList()) {
      dispose(orderId);
    }
  }
  
  // For debugging: print the current state of all tracked orders
  void debugPrintStatus() {
    
    for (final entry in _deliveryStates.entries) {
      final state = entry.value;
      
    }
    
  }
  
  // Helper method for logging
  void _log(String message) {
    if (verbose) print("[DeliveryTrackingService] $message");
  }
}