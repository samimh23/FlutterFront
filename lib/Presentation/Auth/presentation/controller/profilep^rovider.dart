import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/profileservice.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Utils/secure_storage.dart';
import '../../../../Core/Utils/uploadservice.dart';
import '../../../../Core/api/api_exceptions.dart';
import '../../../Subscription/presentation/manager/subsservice.dart';
import '../../data/models/user.dart';



enum ProfileStatus {
  initial,
  loading,
  loaded,
  uploading,
  error,
  subscribing,
}




class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  final UploadService _uploadService;
  final SubscriptionService _subscriptionService;

  ProfileStatus _status = ProfileStatus.initial;
  User? _user;
  String? _errorMessage;
  double _uploadProgress = 0.0;
  String? _subscriptionUrl;

  ProfileStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  String? get subscriptionUrl => _subscriptionUrl;

  ProfileProvider({
    ProfileService? profileService,
    UploadService? uploadService,
    SubscriptionService? subscriptionService,
  }) :
        _profileService = profileService ?? ProfileService(baseUrl: ApiEndpoints.baseUrl),
        _uploadService = uploadService ?? UploadService(),
        _subscriptionService = subscriptionService?? SubscriptionService();

  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _profileService.getProfile();
      _user = user;
      _status = ProfileStatus.loaded;
    } on ApiException catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'An unexpected error occurred';
    }

    notifyListeners();
  }

  Future<void> initiateSubscription(SubscriptionType subscriptionType) async {
    _status = ProfileStatus.subscribing;
    _errorMessage = null;
    notifyListeners();

    try {
      final checkoutResponse = await _subscriptionService.createCheckoutSession(subscriptionType);
      _subscriptionUrl = checkoutResponse.url;

      // Launch the URL to redirect user to Stripe checkout
      if (await canLaunch(_subscriptionUrl!)) {
        await launch(_subscriptionUrl!);
      } else {
        throw ApiException('Could not launch payment URL');
      }

      // After launching the URL, we'll keep the status as subscribing
      // until the user returns to the app and we can refresh the profile
      notifyListeners();
    } on ApiException catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'An unexpected error occurred while initiating subscription';
      notifyListeners();
    }
  }

  // Add this method to your ProfileProvider
  Future<void> verifySubscriptionPayment(String sessionId) async {
    try {
      _status = ProfileStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Call the backend to verify the session status
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/payments/check-session?session_id=$sessionId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Reload the profile to get updated role and subscription information
          await loadProfile();
          return;
        } else {
          throw ApiException(responseData['message'] ?? 'Payment verification failed');
        }
      } else {
        throw ApiException('Failed to verify payment: ${response.statusCode}');
      }
    } on ApiException catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = 'Payment verification error: ${e.toString()}';
      notifyListeners();
    }
  }

// Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SecureStorageService().getAccessToken();
    if (token == null) {
      throw ApiException('Authentication required');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Call this when returning from the payment flow
  void clearSubscriptionState() {
    _subscriptionUrl = null;
    _status = ProfileStatus.loaded;
    notifyListeners();
  }

  Future<bool> uploadProfileImage(dynamic imageSource) async {
    // Handle both File and Uint8List image sources
    if (kIsWeb && imageSource is! Uint8List) {
      throw ApiException('Web platform requires Uint8List for image upload');
    } else if (!kIsWeb && imageSource is! File) {
      throw ApiException('Mobile platform requires File for image upload');
    }

    // Store previous state to restore if failed
    final previousState = _status;
    final previousUser = _user;

    _status = ProfileStatus.uploading;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate upload progress
      _simulateUploadProgress();

      // Upload the image based on platform
      String pictureUrl;
      if (kIsWeb) {
        pictureUrl = await _uploadService.uploadProfilePictureWeb(
            imageSource as Uint8List,
            'profile_image.jpg'
        );
      } else {
        pictureUrl = await _uploadService.uploadProfilePicture(imageSource as File);
      }

      // Update the user model with the new picture URL
      if (_user != null) {
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          phonenumbers: _user!.phonenumbers,
          profilepicture: pictureUrl,
          role: _user!.role,
        );
      }

      _status = ProfileStatus.loaded;
      _uploadProgress = 1.0;
      notifyListeners();
      return true;
    } catch (e) {
      _status = previousState;
      _user = previousUser;
      _errorMessage = e is ApiException
          ? e.message
          : 'Failed to upload profile picture: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void _simulateUploadProgress() {
    // This is a simplified progress simulation
    Future.delayed(Duration.zero, () {
      _uploadProgress = 0.1;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 300), () {
        _uploadProgress = 0.3;
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 300), () {
          _uploadProgress = 0.7;
          notifyListeners();
        });
      });
    });
  }

  void reset() {
    _status = ProfileStatus.initial;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}