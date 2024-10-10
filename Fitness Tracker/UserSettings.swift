import Foundation

class UserSettings: ObservableObject {
    @Published var calorieTarget: Int = 0 {
        didSet {
            saveCalorieTarget() // Save calorie target when it's updated
        }
    }
    @Published var caloriesConsumed: Int = 0
    @Published var meals: [FoodMeal] = [] {
        didSet {
            saveMeals()
        }
    }

    init() {
        loadCalorieTarget() // Load calorie target when the app starts
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

    // Save calorie target to UserDefaults
    private func saveCalorieTarget() {
        UserDefaults.standard.set(calorieTarget, forKey: "calorieTarget")
    }
    
    // Load calorie target from UserDefaults
    private func loadCalorieTarget() {
        if let savedCalorieTarget = UserDefaults.standard.value(forKey: "calorieTarget") as? Int {
            self.calorieTarget = savedCalorieTarget
        }
    }
}
