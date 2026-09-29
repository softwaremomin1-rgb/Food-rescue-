import '../models/food_result.dart';

class LocalAIService {
  // Offline heuristic engine. This is a real local fallback, not a fake
  // network success. Replace/augment it with a model/API in production.
  FoodResult analyze({String? fileName, String storage = 'refrigerated'}) {
    final n = (fileName ?? '').toLowerCase();

    String food = 'Mixed food';
    String category = 'Prepared food';
    int confidence = 72;
    int days = storage == 'refrigerated' ? 3 : 1;

    if (n.contains('milk')) {
      food = 'Milk'; category = 'Dairy'; confidence = 92; days = storage == 'refrigerated' ? 4 : 1;
    } else if (n.contains('bread')) {
      food = 'Bread'; category = 'Bakery'; confidence = 90; days = storage == 'refrigerated' ? 7 : 3;
    } else if (n.contains('rice')) {
      food = 'Cooked rice'; category = 'Prepared food'; confidence = 88; days = storage == 'refrigerated' ? 3 : 1;
    } else if (n.contains('pizza')) {
      food = 'Pizza'; category = 'Prepared food'; confidence = 89; days = storage == 'refrigerated' ? 3 : 1;
    } else if (n.contains('fruit') || n.contains('apple')) {
      food = 'Fruit'; category = 'Produce'; confidence = 80; days = 5;
    }

    return FoodResult(
      name: food,
      category: category,
      confidence: confidence,
      daysLeft: days,
      advice: days <= 1 ? 'Use or donate immediately and check smell/appearance.' : 'Keep stored safely and use before the estimate expires.',
    );
  }
}
