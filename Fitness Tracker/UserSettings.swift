import Foundation

class UserSettings: ObservableObject {
    @Published var calorieTarget: Int = 0
    @Published var caloriesConsumed: Int = 0
    
//    var caloriesLeft: Int {
     //   calorieTarget - caloriesConsumed
   // }
}
