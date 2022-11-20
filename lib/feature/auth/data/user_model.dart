import 'package:focus50/feature/auth/data/user_private_model.dart';
import 'package:focus50/feature/auth/data/user_public_model.dart';

class UserModel {
  UserModel(this.userPublicModel, this.userPrivateModel);

  final UserPublicModel? userPublicModel;
  final UserPrivateModel? userPrivateModel;
}
