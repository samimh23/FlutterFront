
import '../../presentation/controller/profileservice.dart';

class GetProfileUseCase {
  final ProfileService _profileService;

  GetProfileUseCase({
    ProfileService? profileService,
  }) : _profileService = profileService ?? ProfileService(baseUrl: 'http://localhost:3000');

  Future<Map<String, dynamic>> execute() async {
    final user = await _profileService.getProfile();
    return user.toJson();
  }
}