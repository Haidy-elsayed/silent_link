import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(icon, width: 22, height: 22),

      title: Text(title, style: const TextStyle(fontSize: 16)),

      trailing: trailing,
    );
  }
}
