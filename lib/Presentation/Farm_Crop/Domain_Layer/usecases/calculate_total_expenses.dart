import '../entities/farm_crop.dart';

class CalculateTotalExpenses {
  double call(FarmCrop farmCrop) {
    return farmCrop.expenses.fold(0.0, (sum, expense) => sum + expense.value);
  }
}
