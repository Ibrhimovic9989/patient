import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapist/provider/auth_provider.dart';
import 'package:therapist/presentation/auth/edit_profile_screen.dart';
import 'widgets/profile_option.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.purple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EAF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: const BoxConstraints(minHeight: 160),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/rohit.png'),
                    ),
                    const SizedBox(width: 10),

                    /// **Wrap Column with Expanded to prevent overflow**
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Mohammed Mohsin",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // Prevents text overflow
                          ),
                          Text(
                            "mohsin@gmail.com",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "+91 1234567890",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// **Ensure the rest of the content fits properly**
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      ProfileOption(title: "About Us"),
                      ProfileOption(title: "Terms & Conditions"),
                      ProfileOption(title: "Privacy Policy"),
                      ProfileOption(title: "Contact Admin"),
                      ProfileOption(title: "Log Out", isLogout: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
