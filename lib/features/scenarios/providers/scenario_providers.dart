import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/scenario.dart';
import '../../../domain/services/scenario_engine.dart';
import '../../../app/providers.dart';

// ===== SCENARIO ENGINE =====

final scenarioEngineProvider = Provider<ScenarioEngine>((ref) {
  final engine = ref.watch(financialEngineProvider);
  return ScenarioEngine(engine);
});

// ===== SCENARIOS LIST =====

final scenariosListProvider =
    StateNotifierProvider<ScenariosNotifier, List<Scenario>>((ref) {
  return ScenariosNotifier();
});

class ScenariosNotifier extends StateNotifier<List<Scenario>> {
  ScenariosNotifier() : super([]);

  void add(Scenario scenario) {
    state = [...state, scenario];
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void update(Scenario scenario) {
    state = state.map((s) => s.id == scenario.id ? scenario : s).toList();
  }

  void toggleFavorite(String id) {
    state = state.map((s) {
      if (s.id == id) return s.copyWith(isFavorite: !s.isFavorite);
      return s;
    }).toList();
  }
}
