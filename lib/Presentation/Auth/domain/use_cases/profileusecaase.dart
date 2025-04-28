
import '../../../../Core/Utils/Api_EndPoints.dart';
import '../../presentation/controller/profileservice.dart';

class GetProfileUseCase {
  final ProfileService _profileService;

  GetProfileUseCase({
    ProfileService? profileService,
  }) : _profileService = profileService ?? ProfileService(baseUrl: ApiEndpoints.baseUrl);

  Future<Map<String, dynamic>> execute() async {
    final user = await _profileService.getProfile();
    return user.toJson();
  }
}