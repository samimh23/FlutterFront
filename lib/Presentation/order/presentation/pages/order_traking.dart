import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:hanouty/Presentation/order/presentation/provider/delivery_tracking_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:hanouty/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  
  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver {
  final MapController mapController = MapController();
  final loc.Location location = loc.Location();
  bool _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  
  // Get the tracking service
  final DeliveryTrackingService _trackingService = DeliveryTrackingService();
  
  // Stream subscription for tracking updates
  StreamSubscription? _trackingSubscription;

  // A fixed market location for demonstration
  final LatLng marketLocation = LatLng(36.861415, 10.193522); // Tunis coordinates

  // Initialize with at least two points to avoid the empty list error
  List<Marker> markers = [];

  // Initialize with a default value to prevent empty list error
  List<LatLng> deliveryTrack = [
    LatLng(0, 0),
    LatLng(0, 0)
  ];

  // Set to true when we have valid route data
  bool hasValidRoute = false;

  // Delivery person position
  LatLng? deliveryPersonPosition;

  // Timer for refreshing order status
  Timer? refreshTimer;

  // Current delivery progress (0.0 to 1.0)
  double deliveryProgress = 0.0;

  // Delivery status
  String deliveryStatus = "Preparing order...";
  
  // Order status
  OrderStatus? currentOrderStatus;

  // Loading state
  bool isLoading = true;

  // Debug flag
  bool isDebugging = true;

  // OpenRouteService API key
  final String orsApiKey = "5b3ce3597851110001cf6248473d103a943b4556a5168184c250e907";

  // Client location
  LatLng? clientLocation;

  @override
  void initState() {
    super.initState();
    print("[OrderTrackingScreen] Initializing screen for order ${widget.orderId}");
    
    // Register observer for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    initLocation();
    
    // Set up periodic refresh of order status every 10 seconds
    refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) refreshOrderStatus();
    });
  }

  @override
  void dispose() {
    print("[OrderTrackingScreen] Disposing screen for order ${widget.orderId}");
    
    // Unregister observer for app lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    
    refreshTimer?.cancel();
    _trackingSubscription?.cancel();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called when the screen becomes visible again after navigation
    print("[OrderTrackingScreen] Dependencies changed, checking delivery status");
    checkAndResumeAnimation();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background
    if (state == AppLifecycleState.resumed) {
      print("[OrderTrackingScreen] App resumed, checking delivery status");
      checkAndResumeAnimation();
    }
  }
  
  // Check if animation should be running and resume it if needed
  void checkAndResumeAnimation() {
    if (!mounted) return;

    print("[OrderTrackingScreen] Checking if animation should be resumed");
    
    if (_trackingService.isTracking(widget.orderId)) {
      final state = _trackingService.getDeliveryState(widget.orderId);
      
      if (state != null && state.currentOrderStatus == OrderStatus.Delivering) {
        print("[OrderTrackingScreen] Auto-resuming delivery animation");
        _trackingService.startDeliveryAnimation(widget.orderId);
      }
    } else {
      print("[OrderTrackingScreen] No tracking state found");
      
      // If we have status info but no tracking state, initialize it
      if (currentOrderStatus == OrderStatus.Delivering && clientLocation != null) {
        print("[OrderTrackingScreen] Auto-initializing tracking for delivery");
        initializeTracking().then((_) {
          if (mounted && currentOrderStatus == OrderStatus.Delivering) {
            _trackingService.startDeliveryAnimation(widget.orderId);
          }
        });
      }
    }
  }
  
  // Initialize tracking independently from route fetching
  Future<void> initializeTracking() async {
    print("[OrderTrackingScreen] Initializing delivery tracking service");
    
    // Make sure we have client location
    if (clientLocation == null) {
      print("[OrderTrackingScreen] Cannot initialize tracking - no client location");
      return;
    }
    
    // Use whatever route data we have, even if it's just a straight line
    List<LatLng> route = deliveryTrack.length >= 2 ? deliveryTrack : [marketLocation, clientLocation!];
    
    // Get current order status if available, or use a default
    OrderStatus initialStatus = currentOrderStatus ?? OrderStatus.isProcessing;
    
    _trackingService.initializeTracking(
      widget.orderId, 
      initialStatus, 
      route,
      marketLocation,
      clientLocation!
    );
    
    // Subscribe to tracking updates
    _subscribeToTracking();
    
    // If already in delivering status, make sure animation starts
    if (initialStatus == OrderStatus.Delivering) {
      print("[OrderTrackingScreen] Starting animation for order in delivering status");
      _trackingService.startDeliveryAnimation(widget.orderId);
    }
  }
  
  // Subscribe to tracking updates
  void _subscribeToTracking() {
    print("[OrderTrackingScreen] Subscribing to tracking updates for order ${widget.orderId}");
    
    _trackingSubscription?.cancel();
    _trackingSubscription = _trackingService.getDeliveryStateStream(widget.orderId).listen(
      (deliveryState) {
        if (mounted) {
          print("[OrderTrackingScreen] Received tracking update: position=${deliveryState.deliveryPersonPosition}, progress=${deliveryState.animationProgress}");
          
          setState(() {
            deliveryPersonPosition = deliveryState.deliveryPersonPosition;
            deliveryProgress = _trackingService.getDeliveryProgress(widget.orderId);
            currentOrderStatus = deliveryState.currentOrderStatus;
            updateMarkersForStatus();
          });
        }
      },
      onError: (error) {
        print("[OrderTrackingScreen] ERROR in tracking stream: $error");
      }
    );
    
    print("[OrderTrackingScreen] Subscription established");
  }

  // Refresh order status from the database
  Future<void> refreshOrderStatus() async {
    try {
      print("[OrderTrackingScreen] Refreshing order status for ${widget.orderId}");
      
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orderDetails = await orderProvider.getOrderById(widget.orderId);
      
      if (orderDetails != null) {
        final oldStatus = currentOrderStatus;
        print("[OrderTrackingScreen] Retrieved order status: ${orderDetails.orderStatus}");
        
        if (mounted) {
          setState(() {
            currentOrderStatus = orderDetails.orderStatus;
            
            // Update the tracking service
            if (currentOrderStatus != null) {
              // Make sure tracking is initialized before updating status
              if (!_trackingService.isTracking(widget.orderId)) {
                print("[OrderTrackingScreen] Initializing tracking before updating status");
                initializeTracking();
              } else {
                _trackingService.updateOrderStatus(widget.orderId, currentOrderStatus!);
                
                // Check if we need to resume animation
                if (currentOrderStatus == OrderStatus.Delivering) {
                  checkAndResumeAnimation();
                }
              }
            }
            
            // Set progress and status based on current order status
            if (orderDetails.orderStatus == OrderStatus.isReceived) {
              deliveryStatus = "Order received!";
              deliveryProgress = 1.0;
            } else if (orderDetails.orderStatus == OrderStatus.Delivering) {
              deliveryStatus = "On the way to you...";
              deliveryProgress = _trackingService.getDeliveryProgress(widget.orderId);
            } else if (orderDetails.orderStatus == OrderStatus.isProcessing) {
              deliveryStatus = "Processing your order...";
              deliveryProgress = 0.4; // 40% progress when processing
            } else {
              deliveryStatus = "Order received";
              deliveryProgress = 0.2; // 20% initial progress
            }
            
            isLoading = false;
            
            // Update markers based on the current status
            updateMarkersForStatus();
          });
        }
      } else {
        print("[OrderTrackingScreen] No order details returned");
      }
    } catch (e) {
      print("[OrderTrackingScreen] Error refreshing order status: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh order status: $e')),
        );
      }
    }
    
    print("[OrderTrackingScreen] Current delivery position: $deliveryPersonPosition");
    _trackingService.debugPrintStatus(); // Debug info
  }

  Future<void> initLocation() async {
    try {
      print("[OrderTrackingScreen] Initializing location services");
      
      if (!kIsWeb) {
        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) return;
        }
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == loc.PermissionStatus.denied) {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted != loc.PermissionStatus.granted) return;
        }
        await location.changeSettings(
          accuracy: loc.LocationAccuracy.high,
        );
        _locationData = await location.getLocation();
        if (_locationData != null) {
          final userLocation = LatLng(
            _locationData!.latitude ?? 0,
            _locationData!.longitude ?? 0,
          );

          print("[OrderTrackingScreen] Got user location: $userLocation");
          clientLocation = userLocation; // Save client location
          updateBaseMarkers(userLocation, marketLocation);

          // First set the straight line as a fallback before API call
          setState(() {
            deliveryTrack = [marketLocation, userLocation]; // Market to user for delivery route
          });

          // Initialize tracking first with the basic route
          await initializeTracking();
          
          try {
            // Then try to get the actual route from market to client
            await getOrsDirections(marketLocation, userLocation);
          } catch (e) {
            print("[OrderTrackingScreen] Error getting route: $e");
            print("[OrderTrackingScreen] Continuing with straight line route");
          }
          
          // Now fetch the order status
          await refreshOrderStatus();
        }
      } else {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );
        final userLocation = LatLng(position.latitude, position.longitude);

        print("[OrderTrackingScreen] Got user location (web): $userLocation");
        clientLocation = userLocation; // Save client location
        updateBaseMarkers(userLocation, marketLocation);

        // First set the straight line as a fallback
        setState(() {
          deliveryTrack = [marketLocation, userLocation]; // Market to user for delivery route
        });

        // Initialize tracking first with the basic route
        await initializeTracking();
        
        try {
          // Then try to get the actual route from market to client
          await getOrsDirections(marketLocation, userLocation);
        } catch (e) {
          print("[OrderTrackingScreen] Error getting route: $e");
          print("[OrderTrackingScreen] Continuing with straight line route");
        }
        
        // Now fetch the order status
        await refreshOrderStatus();
      }
    } catch (e) {
      print("[OrderTrackingScreen] Error in initLocation: $e");
      // Make sure we have at least a straight line between points
      if (_locationData != null) {
        final userLocation = LatLng(
            _locationData!.latitude ?? 0,
            _locationData!.longitude ?? 0
        );
        clientLocation = userLocation;
        setState(() {
          deliveryTrack = [marketLocation, userLocation]; // Market to user for delivery route
        });
        
        // Still try to initialize tracking with basic route
        await initializeTracking();
        
        // Still try to fetch the order status
        await refreshOrderStatus();
      }
    }
  }

  Future<void> getOrsDirections(LatLng start, LatLng end) async {
    if (!mounted) return;
    
    try {
      print("[OrderTrackingScreen] Getting route directions from $start to $end");
      
      final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car/geojson');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': orsApiKey
        },
        body: jsonEncode({
          "coordinates": [
            [start.longitude, start.latitude],  // Market location (start of delivery)
            [end.longitude, end.latitude]      // Client location (end of delivery)
          ]
        }),
      );

      print("[OrderTrackingScreen] API Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse the GeoJSON format response
        if (data != null &&
            data['features'] != null &&
            data['features'].isNotEmpty &&
            data['features'][0]['geometry'] != null &&
            data['features'][0]['geometry']['coordinates'] != null) {

          final coordinates = data['features'][0]['geometry']['coordinates'] as List;

          if (coordinates.isNotEmpty) {
            final List<LatLng> routePoints = [];

            // Convert each coordinate to LatLng
            for (var coord in coordinates) {
              if (coord is List && coord.length >= 2) {
                // GeoJSON format has coordinates as [longitude, latitude]
                routePoints.add(LatLng(coord[1], coord[0]));
              }
            }

            if (routePoints.length >= 2) {
              print("[OrderTrackingScreen] Successfully parsed ${routePoints.length} route points");
              
              if (mounted) {
                setState(() {
                  deliveryTrack = routePoints;
                  hasValidRoute = true;
                });
              }

              // Safely update map if possible
              try {
                _fitMapToBounds(routePoints);
              } catch (e) {
                print("[OrderTrackingScreen] Cannot update map view yet: $e");
              }

              // Only update the route in tracking service if it's already initialized
              if (_trackingService.isTracking(widget.orderId)) {
                print("[OrderTrackingScreen] Updating route in tracking service");
                
                final currentState = _trackingService.getDeliveryState(widget.orderId);
                if (currentState != null) {
                  // Preserve the current state's properties but update the route
                  _trackingService.initializeTracking(
                    widget.orderId, 
                    currentState.currentOrderStatus,
                    routePoints,
                    marketLocation,
                    clientLocation!
                  );
                  
                  // Check if animation needs to be resumed
                  if (currentState.currentOrderStatus == OrderStatus.Delivering) {
                    checkAndResumeAnimation();
                  }
                }
              }
            }
          }
        } else {
          print("[OrderTrackingScreen] API response format not as expected");
          print("Response: ${response.body.substring(0, min(500, response.body.length))}");
        }
      } else {
        print("[OrderTrackingScreen] ORS API Error: ${response.statusCode}");
        print("Error body: ${response.body}");
      }
    } catch (e) {
      print("[OrderTrackingScreen] Error getting route: $e");
      throw e;
    }
  }
  
  // Helper method to fit map to route bounds
  void _fitMapToBounds(List<LatLng> points) {
    if (points.length < 2) return;
    
    try {
      print("[OrderTrackingScreen] Fitting map to route bounds");
      
      // Find the bounds of the route
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (final point in points) {
        minLat = min1(minLat, point.latitude);
        maxLat = max(maxLat, point.latitude);
        minLng = min1(minLng, point.longitude);
        maxLng = max(maxLng, point.longitude);
      }

      // Add padding to bounds to include both markers
      final paddingDegrees = 0.01; // About 1km padding
      minLat -= paddingDegrees;
      maxLat += paddingDegrees;
      minLng -= paddingDegrees;
      maxLng += paddingDegrees;

      // Create a bounding box
      final bounds = LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng)
      );

      // Center the map on the route with padding
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
      
      print("[OrderTrackingScreen] Map bounds updated");
    } catch (e) {
      print("[OrderTrackingScreen] Error fitting map bounds: $e");
    }
  }

  void updateBaseMarkers(LatLng userLocation, LatLng marketLocation) {
    if (!mounted) return;
    
    setState(() {
      markers = [
        Marker(
          width: 40,
          height: 40,
          point: userLocation,
          child: const Icon(
            Icons.person_pin_circle,
            size: 40,
            color: Colors.blue,
          ),
        ),
        Marker(
          width: 40,
          height: 40,
          point: marketLocation,
          child: const Icon(
            Icons.store,
            size: 40,
            color: Colors.red,
          ),
        ),
      ];
    });
  }

  void updateMarkersForStatus() {
    if (!mounted || clientLocation == null) {
      print("[OrderTrackingScreen] Cannot update markers - not mounted or client location is null");
      return;
    }
    
    List<Marker> updatedMarkers = [
      // User marker
      Marker(
        width: 40,
        height: 40,
        point: clientLocation!, // Client location
        child: const Icon(
          Icons.person_pin_circle,
          size: 40,
          color: Colors.blue,
        ),
      ),
      // Market marker
      Marker(
        width: 40,
        height: 40,
        point: marketLocation,
        child: const Icon(
          Icons.store,
          size: 40,
          color: Colors.red,
        ),
      ),
    ];
    
    // Only show delivery person if order is being delivered or received
    if ((currentOrderStatus == OrderStatus.Delivering || 
         currentOrderStatus == OrderStatus.isReceived) && 
        deliveryPersonPosition != null) {
      
      print("[OrderTrackingScreen] Adding delivery person marker at $deliveryPersonPosition");
      
      updatedMarkers.add(
        Marker(
          width: 60,
          height: 60,
          point: deliveryPersonPosition!,
          child: const Icon(
            Icons.delivery_dining,
            size: 40,
            color: Colors.green,
          ),
        ),
      );
    } else {
      print("[OrderTrackingScreen] Not adding delivery marker - status=${currentOrderStatus}, position=$deliveryPersonPosition");
    }
    
    setState(() {
      markers = updatedMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        backgroundColor: AppColors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshOrderStatus,
            tooltip: 'Refresh Order Status',
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            // Status bar showing delivery progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deliveryStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: currentOrderStatus == OrderStatus.isReceived ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: deliveryProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentOrderStatus == OrderStatus.isReceived ? Colors.green : AppColors.yellow,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDeliveryStages(),
                  const SizedBox(height: 4),
                  Text(
                    currentOrderStatus == OrderStatus.isReceived
                      ? 'Delivered'
                      : 'Estimated arrival: ${formatRemainingTime()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // The map
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: marketLocation,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    
                    enableMultiFingerGestureRace: true,
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    tileProvider: CancellableNetworkTileProvider(),
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Only show polyline if we have valid points
                  if (deliveryTrack.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: deliveryTrack,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              ),
            ),
          ],
        ),
      // No floating action button as requested
    );
  }
  
  Widget _buildDeliveryStages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStageIcon(
          icon: Icons.shopping_bag,
          label: 'Order\nReceived',
          isActive: true, // Always active
          isCompleted: true,
        ),
        _buildStageIcon(
          icon: Icons.inventory,
          label: 'Processing',
          isActive: currentOrderStatus == OrderStatus.isProcessing || 
                   currentOrderStatus == OrderStatus.Delivering || 
                   currentOrderStatus == OrderStatus.isReceived,
          isCompleted: currentOrderStatus == OrderStatus.Delivering || 
                      currentOrderStatus == OrderStatus.isReceived,
        ),
        _buildStageIcon(
          icon: Icons.local_shipping,
          label: 'Delivering',
          isActive: currentOrderStatus == OrderStatus.Delivering || 
                   currentOrderStatus == OrderStatus.isReceived,
          isCompleted: currentOrderStatus == OrderStatus.isReceived,
        ),
        _buildStageIcon(
          icon: Icons.home,
          label: 'Delivered',
          isActive: currentOrderStatus == OrderStatus.isReceived,
          isCompleted: currentOrderStatus == OrderStatus.isReceived,
        ),
      ],
    );
  }
  
  Widget _buildStageIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Icon(
            icon,
            color: isCompleted 
                ? Colors.green 
                : isActive 
                    ? AppColors.yellow 
                    : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String formatRemainingTime() {
    if (currentOrderStatus == OrderStatus.isReceived) return 'Delivered';

    int remainingSeconds = ((1.0 - deliveryProgress) * 300).round();
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Helper functions
int min(int a, int b) => a < b ? a : b;
double min1(double a, double b) => a < b ? a : b;
double max(double a, double b) => a > b ? a : b;