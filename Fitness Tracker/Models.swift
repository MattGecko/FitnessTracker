import Foundation

import Foundation

struct Meal: Codable, Identifiable {
    var id = UUID()
    var name: String
    var mealType: String
    var calories: Int
    var fat: Double
    var protein: Double
    var carbohydrates: Double
    var date: Date
}


struct WeightEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var weight: Double
}
