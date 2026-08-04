import 'package:flutter/material.dart';

/// Bottom navigation shared by admin / teacher / parent shells.
class RoleNavigationBar extends StatelessWidget {
  const RoleNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 72,
          destinations: destinations,
        ),
      ),
    );
  }
}
