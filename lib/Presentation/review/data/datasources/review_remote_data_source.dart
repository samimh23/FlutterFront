import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/Presentation/review/data/models/review_model.dart';
import 'package:http/http.dart' as http;

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> getReviewById(String id);
  Future<ReviewModel> createReview(ReviewModel review, String idUser);
  Future<ReviewModel> updateReview(
      String reviewId, ReviewModel review);
  Future<Unit> deleteReview(String id);
  Future<List<ReviewModel>> getReviewsByProductId(String productId);
  Future<List<ReviewModel>> getReviewsByUserId(String userId);
}

const BASE_URL = "http://127.0.0.1:3000/review";

class ReviewRemoteDataSourceImpl extends ReviewRemoteDataSource {
  final http.Client client;

  ReviewRemoteDataSourceImpl({required this.client});

  @override
  Future<ReviewModel> getReviewById(String id) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/$id'),
      headers: {"Content-Type": "application/json"},
    );
    // Check if the response status code is 200, indicating a successful request
    // and return the decoded Jso
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return ReviewModel.fromJson(decodedJson);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ReviewModel> createReview(ReviewModel review, String userId) async {
    final body = json.encode(review.toJson());
    final response = await client.post(
      Uri.parse('$BASE_URL/$userId'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print('*******************${response.body}');
    if (response.statusCode == 201) {
      final decodedJson = json.decode(response.body);
      return ReviewModel.fromJson(decodedJson);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ReviewModel> updateReview(String reviewId, ReviewModel review) async {

final storage = SecureStorageService();
String? token = await storage.getAccessToken();
    final body = json.encode({
      ...review.toJson(), // Include user ID in the request body
    });
    print('Review:$review');
    print('Review ID:$reviewId');
    
    // Ensure reviewId is appended to the URL
    final response = await client.patch(
      Uri.parse('$BASE_URL/update/$reviewId'), // Corrected endpoint
      headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer $token"
},
      body: body,
    );
    print('Response:${response.body}');
    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return ReviewModel.fromJson(decodedJson); // Ensure the response is correctly parsed
    } else {
      print('Error:${response.statusCode}');
      throw ServerException();
    }
  }

  @override
  Future<Unit> deleteReview(String id) async {
    final response = await client.delete(
      Uri.parse('$BASE_URL/$id'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByProductId(String productId) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/product/$productId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body) as List;
      return decodedJson.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsByUserId(String userId) async {
    final response = await client.get(
      Uri.parse('$BASE_URL/findReviewByUser/$userId'),
      headers: {"Content-Type": "application/json"},
    );
    // Check if the response status code is 200, indicating a successful request
    // and return the decoded Jso
    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body) as List;
      return decodedJson.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }
}
