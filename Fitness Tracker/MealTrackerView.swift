import SwiftUI

struct MealTrackerView: View {
    @ObservedObject var userSettings: UserSettings
    @State private var name: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var calories: String = ""
    @State private var fat: String = ""
    @State private var protein: String = ""
    @State private var carbohydrates: String = ""
    @State private var date: Date = Date()
    @State private var searchResults: [FoodItem] = [] // Store search results
    @State private var isSearching = false // Track if searching

    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    private let foodSearchService = FoodSearchService()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Daily Calorie Goal: \(userSettings.calorieTarget)")) {
                    Text("Calories Remaining: \(userSettings.calorieTarget - userSettings.caloriesConsumed)")
                }

                Section(header: Text("Meal Details")) {
                    VStack {
                        TextField("Meal Name", text: $name, onEditingChanged: { isEditing in
                            if isEditing {
                                search()
                            }
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, isSearching ? 0 : 10)
                        
                        if isSearching && !searchResults.isEmpty {
                            List(searchResults) { food in
                                Button(action: {
                                    selectFood(food)
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(food.description)
                                            .font(.headline)
                                        Text("\(food.calories, specifier: "%.0f") kcal")
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .frame(height: 200) // Adjust the height of the results list
                        }
                    }
                    
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

    private func search() {
        isSearching = true
        foodSearchService.searchFood(query: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let foods):
                    searchResults = foods
                case .failure(let error):
                    print("Error searching for food: \(error)")
                    searchResults = []
                }
            }
        }
    }

    private func selectFood(_ food: FoodItem) {
        // Autofill the nutritional information
        name = food.description
        calories = String(Int(food.calories))
        fat = String(food.fat)
        protein = String(food.protein)
        carbohydrates = String(food.carbohydrates)
        searchResults = []
        isSearching = false
    }

    private func addMeal() {
        let newMeal = FoodMeal(
            name: name,
            mealType: mealType,
            calories: Int(calories) ?? 0,
            fat: Double(fat) ?? 0.0,
            protein: Double(protein) ?? 0.0,
            carbohydrates: Double(carbohydrates) ?? 0.0,
            date: date
        )
        
        // Save the meal to UserSettings
        userSettings.meals.append(newMeal)
        userSettings.caloriesConsumed += newMeal.calories
        
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
        searchResults = []
        isSearching = false
    }
}

struct MealTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MealTrackerView(userSettings: UserSettings())
    }
}
