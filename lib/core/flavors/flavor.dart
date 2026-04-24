import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Flavor { dev, staging, prod }

final currentFlavorProvider = Provider<Flavor>((ref) => throw UnimplementedError());