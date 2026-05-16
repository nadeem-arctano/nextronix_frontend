import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'section_header.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final Widget child;

  const SettingsCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            description: description,
            icon: icon,
            color: color,
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
