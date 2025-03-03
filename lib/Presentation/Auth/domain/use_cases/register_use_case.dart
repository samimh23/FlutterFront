


import '../../data/models/create_user_dto.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _registerRepository;

  RegisterUseCase(this._registerRepository);

  Future<User> execute({
    required String name,
    required String email,
    required List<int> phoneNumbers,
    required String password,
    int? cin,
    String? profilePicture,
    String? patentImage,
  }) async {
    final createUserDto = CreateUserDto(
      name: name,
      email: email,
      phoneNumbers: phoneNumbers,
      password: password,
      cin: cin,
      profilePicture: profilePicture,
      patentImage: patentImage,
    );

    return await _registerRepository.registerUser(createUserDto);
  }
}