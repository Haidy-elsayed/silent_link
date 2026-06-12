import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/user_provider.dart';
import '../profile_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        },
        borderRadius: BorderRadius.circular(20), 
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), 
                blurRadius: 15, 
                offset: const Offset(0, 5), 
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back", 
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                    ),
                    const SizedBox(height: 5),
                    Consumer<UserProvider>(
                      builder: (context, userProv, child) {
                        if (userProv.isLoading && userProv.name.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        // 🚀 التعديل السحري هنا: القراءة من userProv.name مباشرة عشان يطابق البروفايل بالظبط
                        String displayName = userProv.name.isNotEmpty ? userProv.name : "User";
                        String displayCountry = userProv.country.isNotEmpty ? userProv.country : "Egypt";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName, 
                              style: const TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.bold, 
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  displayCountry, 
                                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded, 
                color: Colors.grey, 
                size: 18
              ),
            ],
          ),
        ),
      ),
    );
  }
}