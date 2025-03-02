import 'package:flutter/material.dart';
import 'package:hanouty/responsive/responsive_layout.dart';

import '../widgets/AlreadyMembersignin.dart';
import '../widgets/Signup_Fom.dart';
import '../widgets/Signupbenift.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [

                  if (!ResponsiveLayout.isMobile(context))
                    Expanded(
                      flex: ResponsiveLayout.isDesktop(context) ? 2 : 1,
                      child: const SignupBenefits(),
                    ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(), // Pushes sign-in button to the right
                            const AlreadyMemberSignin(),
                          ],
                        ),
                        const SizedBox(height: 20), // Add some spacing
                        const Expanded(
                          flex: 5,
                          child: SignupForm(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
