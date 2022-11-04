// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:focus42/models/user_model.dart';
// import 'package:focus42/models/user_private_model.dart';
// import 'package:focus42/models/user_public_model.dart';
// import 'package:focus42/top_level_providers.dart';

// class Onboarding extends ConsumerStatefulWidget {
//   @override
//   _OnboardingState createState() => _OnboardingState();
// }

// class _OnboardingState extends ConsumerState<Onboarding> {
//   bool? onboardingWatched = false;
//   @override
//   void initState() {
//     super.initState();
//     final database = ref.watch(databaseProvider);
//     final user = await database.getUserPublic();
//     onboardingWatched = user.onboardingWatched;
//   }

//   void _updateOnboarding(bool onboardingWatched) async {
//     final database = ref.read(databaseProvider);
//     UserPublicModel userPublic = UserPublicModel(
//       onboardingWatched: onboardingWatched,
//     );
//     UserPrivateModel userPrivate = UserPrivateModel();
//     UserModel updateUser = UserModel(userPublic, userPrivate);
//     await database.updateUser(updateUser);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// Class Onboarding{
//   Future<dynamic>? _popupOnboarding() async {
//     final database = ref.watch(databaseProvider);
//     final user = await database.getUserPublic();
//     bool? onboardingWatched = user.onboardingWatched;
//     final authViewModel = ref.read(authViewModelProvider);
//     if (onboardingWatched != null && onboardingWatched ||
//         !(await authViewModel.isSignedUp())) {
//       return null;
//     } else {
//       return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Container(
//               child: Text('hi'),
//             ),
//           );
//         },
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/auth/auth_view_model.dart';
import 'package:focus42/feature/jitsi/presentation/text_style.dart';
import 'package:focus42/top_level_providers.dart';

class Onboarding {
  Future<dynamic>? popupOnboardingStart(
      WidgetRef ref, BuildContext context, showTutorial()) async {
    final database = ref.watch(databaseProvider);
    final user = await database.getUserPublic();
    bool? onboardingWatched = user.onboardingWatched;
    final authViewModel = ref.read(authViewModelProvider);
    if (onboardingWatched != null && onboardingWatched ||
        !(await authViewModel.isSignedUp())) {
      return null;
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '안녕하세요 ',
                      style: MyTextStyle.CbS26W400,
                    ),
                    Text(
                      '${user.nickname}',
                      style: MyTextStyle.CbS26W600,
                    ),
                    Text(
                      '님!',
                      style: MyTextStyle.CbS26W400,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '세상에서 가장 집중이 잘되는 공간,\nFocus50에 오신 걸 환영합니다.',
                  style: MyTextStyle.CbS20W400,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showTutorial();
                    },
                    child: Text('튜토리얼 따라가기'))
              ],
            ),
          );
        },
      );
    }
  }
}
