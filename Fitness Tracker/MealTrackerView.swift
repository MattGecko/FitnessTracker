import SwiftUI
import Combine

struct MealTrackerView: View {
    @ObservedObject var userSettings: UserSettings
    @State private var name: String = ""
    @State private var mealType: String = "Breakfast"
    @State private var calories: String = ""
    @State private var fat: String = ""
    @State private var protein: String = ""
    @State private var carbohydrates: String = ""
    @State private var date: Date = Date()
    @State private var searchResults: [FoodItem] = []
    @State private var isSearching = false
    @State private var isLoading = false  // New state to handle loading state
    @State private var cancellable: AnyCancellable?

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
                        TextField("Meal Name", text: $name)
                            .onChange(of: name) { newValue in
                                performSearch(query: newValue)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, isSearching ? 0 : 10)
                        
                        // Show loading indicator if search is in progress
                        if isLoading {
                            ProgressView("Searching...")
                        }

                        // Show search results if available
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
                        } else if isSearching && searchResults.isEmpty && !isLoading {
                            // Show "No results found" message
                            Text("No results found.")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(mealTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    TextField("Calories", text: $calories)
                        .keyboardType(.decimalPad)
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

    private func performSearch(query: String) {
        // Clear results and reset state if the query is too short
        if query.isEmpty || query.count < 2 {
            isSearching = false
            searchResults = []
            isLoading = false
            return
        }
        
        // Start the search process
        isSearching = true
        isLoading = true  // Show loading indicator

        print("Searching for: \(query)")

        cancellable?.cancel()
        cancellable = Just(query)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // Increased debounce time
            .sink(receiveValue: { debouncedQuery in
                print("Debounced search for: \(debouncedQuery)")
                self.foodSearchService.searchFood(query: debouncedQuery) { result in
                    DispatchQueue.main.async {
                        isLoading = false  // Stop loading once the search completes
                        switch result {
                        case .success(let foods):
                            self.searchResults = foods
                            print("Search results: \(foods.count) items found")
                        case .failure(let error):
                            print("Error searching for food: \(error)")
                            self.searchResults = []
                        }
                    }
                }
            })
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
