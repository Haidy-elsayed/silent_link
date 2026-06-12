import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_link/core/constants/app_colors.dart';
import 'package:silent_link/providers/user_provider.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;

  const ProfilePictureWidget({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    
    final userProv = Provider.of<UserProvider>(context);
    
  
    String firstLetter = userProv.name.isNotEmpty 
        ? userProv.name.trim().substring(0, 1).toUpperCase() 
        : "U";

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
       
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              
              color: imageUrl == null || imageUrl!.isEmpty 
                  ? AppColors.primary.withOpacity(0.2) 
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              image: imageUrl != null && imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
           
            child: imageUrl == null || imageUrl!.isEmpty
                ? Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary, 
                      ),
                    ),
                  )
                : null,
          ),


          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}