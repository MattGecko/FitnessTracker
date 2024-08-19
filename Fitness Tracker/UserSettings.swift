import Foundation

class UserSettings: ObservableObject {
    @Published var calorieTarget: Int = 0
    @Published var caloriesConsumed: Int = 0
    @Published var meals: [FoodMeal] = [] // Add this to store the list of meals
    
   // init() {
        // Sample data for testing
       // meals = [
        //    FoodMeal(name: "Sample Breakfast", mealType: "Breakfast", calories: 300, fat: 10, protein: 20, carbohydrates: 40, date: Date()),
       //     FoodMeal(name: "Sample Lunch", mealType: "Lunch", calories: 600, fat: 20, protein: 30, carbohydrates: 60, date: Date()),
        //]
        
        
   // }
}
