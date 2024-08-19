import SwiftUI

struct FoodLogView: View {
    @ObservedObject var userSettings: UserSettings
    @State private var selectedDate: Date = Date() // State property to hold the selected date
    
    var body: some View {
        NavigationView {
            VStack {
                // DatePicker for selecting the date
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle()) // or .compactDatePickerStyle() for a more compact view
                    .padding()
                
                if let mealsForSelectedDate = mealsForSelectedDate(), !mealsForSelectedDate.isEmpty {
                    List {
                        ForEach(mealsForSelectedDate.keys.sorted(), id: \.self) { mealType in
                            Section(header: Text(mealType)) {
                                ForEach(mealsForSelectedDate[mealType] ?? []) { meal in
                                    MealRowView(meal: meal, mealType: mealType)
                                }
                            }
                        }
                    }
                } else {
                    // Placeholder if no meals are logged for the selected date
                    VStack {
                        Text("No meals logged for this date")
                            .font(.headline)
                            .padding()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Food Log")
        }
    }

    // Filter the meals for the selected date and group by meal type
    private func mealsForSelectedDate() -> [String: [FoodMeal]]? {
        let calendar = Calendar.current
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        
        // Filter meals to those matching the selected date
        let mealsForDate = userSettings.meals.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDayStart)
        }
        
        // Group the filtered meals by meal type
        let groupedMeals = Dictionary(grouping: mealsForDate, by: { $0.mealType })
        return groupedMeals.isEmpty ? nil : groupedMeals
    }
}

// Separate view for displaying a meal row
struct MealRowView: View {
    let meal: FoodMeal
    let mealType: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.headline)
                Text("\(meal.calories) kcal")
                    .font(.subheadline)
            }
            Spacer()
            Text(mealType)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct FoodLogView_Previews: PreviewProvider {
    static var previews: some View {
        let userSettings = UserSettings()
        return FoodLogView(userSettings: userSettings)
    }
}
