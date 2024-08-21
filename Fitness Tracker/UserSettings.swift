import Foundation

class UserSettings: ObservableObject {
    @Published var calorieTarget: Int = 0
    @Published var caloriesConsumed: Int = 0
    @Published var meals: [FoodMeal] = [] {
        didSet {
            saveMeals()
        }
    }

    init() {
        loadMeals()
    }
    
    // Save meals to UserDefaults
    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(encoded, forKey: "meals")
        }
    }
    
    // Load meals from UserDefaults
    private func loadMeals() {
        if let savedMeals = UserDefaults.standard.data(forKey: "meals"),
           let decodedMeals = try? JSONDecoder().decode([FoodMeal].self, from: savedMeals) {
            self.meals = decodedMeals
        }
    }
}
