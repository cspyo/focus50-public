import 'package:focus42/models/user_private_model.dart';
import 'package:focus42/models/user_public_model.dart';

class UserModel {
  UserModel(this.userPublicModel, this.userPrivateModel);

  final UserPublicModel? userPublicModel;
  final UserPrivateModel? userPrivateModel;
}
