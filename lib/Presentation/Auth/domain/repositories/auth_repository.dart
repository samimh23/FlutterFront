import '../../data/models/create_user_dto.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
  Future<User> registerUser(CreateUserDto createUserDto);




}