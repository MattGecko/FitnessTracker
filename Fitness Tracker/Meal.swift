import Foundation

struct FoodMeal: Identifiable {
    let id = UUID() // Unique ID for each meal
    let name: String
    let mealType: String
    let calories: Int
    let fat: Double
    let protein: Double
    let carbohydrates: Double
    let date: Date
}
