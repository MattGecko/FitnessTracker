import SwiftUI

struct FoodLogView: View {
    @ObservedObject var userSettings: UserSettings
    @State private var selectedDate: Date = Date() // State property to hold the selected date
    @State private var showDatePicker: Bool = false // State to show/hide the DatePicker
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        // Move to the previous day
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Button(action: {
                        // Show the full date picker
                        showDatePicker.toggle()
                    }) {
                        Text(formattedDate(selectedDate))
                            .font(.headline)
                            .padding()
                    }
                    .sheet(isPresented: $showDatePicker) {
                        VStack {
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                            Button("Done") {
                                showDatePicker = false
                            }
                            .padding()
                        }
                    }
                    
                    Button(action: {
                        // Move to the next day
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                
                if let mealsForSelectedDate = mealsForSelectedDate(), !mealsForSelectedDate.isEmpty {
                    List {
                        ForEach(mealsForSelectedDate.keys.sorted(), id: \.self) { mealType in
                            Section(header: Text(mealType)) {
                                ForEach(mealsForSelectedDate[mealType] ?? []) { meal in
                                    MealRowView(meal: meal, mealType: mealType)
                                }
                                .onDelete { indexSet in
                                    deleteMeal(at: indexSet, in: mealType, from: mealsForSelectedDate[mealType] ?? [])
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

    // Format the selected date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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

    // Delete the meal from the list and UserSettings
    private func deleteMeal(at offsets: IndexSet, in mealType: String, from meals: [FoodMeal]) {
        let mealsToDelete = offsets.map { meals[$0] }
        
        for meal in mealsToDelete {
            if let index = userSettings.meals.firstIndex(where: { $0.id == meal.id }) {
                userSettings.meals.remove(at: index)
            }
        }
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
