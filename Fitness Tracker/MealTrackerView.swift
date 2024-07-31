import SwiftUI

struct MealTrackerView: View {
    
    
    @State private var meals: [Meal] = []
    @State private var name: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var calories: String = ""
    @State private var fat: String = ""
    @State private var protein: String = ""
    @State private var carbohydrates: String = ""
    @State private var date: Date = Date()

    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Details")) {
                    TextField("Meal Name", text: $name)
                    
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Fat (grams)", text: $fat)
                        .keyboardType(.decimalPad)
                    TextField("Protein (grams)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Carbohydrates (grams)", text: $carbohydrates)
                        .keyboardType(.decimalPad)
                }

                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Button("Add Meal") {
                    addMeal()
                }
            }
            .navigationTitle("Meal Tracker")
        }
    }

    private func addMeal() {
        let newMeal = Meal(
            name: name,
            mealType: mealType,
            calories: Int(calories) ?? 0,
            fat: Double(fat) ?? 0.0,
            protein: Double(protein) ?? 0.0,
            carbohydrates: Double(carbohydrates) ?? 0.0,
            date: date
        )
        meals.append(newMeal)
        clearForm()
    }

    private func clearForm() {
        name = ""
        mealType = "Breakfast"
        calories = ""
        fat = ""
        protein = ""
        carbohydrates = ""
        date = Date()
    }
}

struct MealTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MealTrackerView()
    }
}
