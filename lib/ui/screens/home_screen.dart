import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/flavors/flavor.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(currentFlavorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('DocuMink')),
      body: Center(
        child: Text('Current Flavor: ${flavor.name}', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}