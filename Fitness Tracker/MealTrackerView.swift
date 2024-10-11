import SwiftUI
import Combine

struct MealTrackerView: View {
    @ObservedObject var userSettings: UserSettings
    @State private var name: String = ""
    @State private var selectedFood: FoodItem? // Hold the selected food item
    @State private var mealType: String = "Breakfast"
    @State private var calories: String = ""
    @State private var fat: String = ""
    @State private var protein: String = ""
    @State private var carbohydrates: String = ""
    @State private var portion: Double = 1.0 // Portion size tracking
    @State private var date: Date = Date()
    @State private var searchResults: [FoodItem] = []
    @State private var isSearching = false
    @State private var isLoading = false
    @State private var pageNumber = 1 // Track the current page number
    @State private var cancellable: AnyCancellable?
    @State private var searchTimer: Timer?  // Timer to handle search debounce

    private let foodSearchService = FoodSearchService()
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

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
                                resetSearch()
                                scheduleSearch(query: newValue)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, isSearching ? 0 : 10)

                        if isLoading {
                            ProgressView("Searching...")
                        }

                        if isSearching && !searchResults.isEmpty {
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    ForEach(searchResults) { food in
                                        Button(action: {
                                            selectFood(food)
                                        }) {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(food.description)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text("\(max(0, food.calories), specifier: "%.0f") kcal")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        }
                                        Divider()
                                    }

                                    if !isLoading {
                                        Button("Load more results...") {
                                            loadMoreResults(query: name)
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 300)
                        } else if isSearching && searchResults.isEmpty && !isLoading {
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

                    // Portion selector using Stepper
                    HStack {
                        Text("Portion Size:")
                        Spacer()
                        Stepper(value: $portion, in: 0.25...10, step: 0.25) {
                            Text("\(portion, specifier: "%.2f")x")
                        }
                        .onChange(of: portion) { _ in
                            updateNutritionalValues()
                        }
                    }
                    .padding(.vertical)

                    // Display updated nutritional info based on portion size
                    TextField("Calories", text: $calories)
                        .keyboardType(.decimalPad)
                    TextField("Fat", text: $fat)
                        .keyboardType(.decimalPad)
                    TextField("Protein", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Carbohydrates", text: $carbohydrates)
                        .keyboardType(.decimalPad)
                }

                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Button("Add Food") {
                    addMeal()
                }
            }
            .navigationTitle("Meal Tracker")
        }
    }

    // Function to reset the search results and page number when a new search begins
    private func resetSearch() {
        pageNumber = 1
        searchResults = []
        searchTimer?.invalidate() // Invalidate the timer when the search changes
    }

    // Schedule the search using a timer (2-second delay after typing stops)
    private func scheduleSearch(query: String) {
        searchTimer?.invalidate()
        guard query.count >= 3 else {
            isSearching = false
            isLoading = false
            searchResults = []
            return
        }

        searchTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.performSearch(query: query)
        }
    }

    // Perform search and load results
    private func performSearch(query: String) {
        isSearching = true
        isLoading = true

        cancellable?.cancel()

        self.foodSearchService.searchFood(query: query, pageNumber: self.pageNumber) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let foods):
                    if foods.isEmpty && self.pageNumber == 1 {
                        self.isSearching = false
                        self.searchResults = []
                    } else {
                        self.searchResults.append(contentsOf: foods)
                    }
                case .failure(let error):
                    self.isSearching = false
                    self.searchResults = []
                }
            }
        }
    }

    // Load more results when the user scrolls to the bottom
    private func loadMoreResults(query: String) {
        pageNumber += 1
        performSearch(query: query)
    }

    // Select the food and autofill the nutritional info
    private func selectFood(_ food: FoodItem) {
        selectedFood = food // Store the selected food item
        name = "" // Clear the search bar
        portion = 1.0 // Reset portion to 1 when selecting a new food

        updateNutritionalValues() // Initial call to set nutritional values

        searchResults = []
        isSearching = false
    }

    // Update the nutritional values based on the portion size
    private func updateNutritionalValues() {
        guard let food = selectedFood else { return }

        calories = "\(Int(food.calories * portion)) kcal"
        fat = "\(food.fat * portion)g Fat"
        protein = "\(food.protein * portion)g Protein"
        carbohydrates = "\(food.carbohydrates * portion)g Carbohydrates"
    }

    // Add meal to user settings
    private func addMeal() {
        guard let selectedFood = selectedFood else { return }

        let newMeal = FoodMeal(
            name: selectedFood.description,
            mealType: mealType,
            calories: Int(calories.replacingOccurrences(of: " kcal", with: "")) ?? 0,
            fat: Double(fat.replacingOccurrences(of: "g Fat", with: "")) ?? 0.0,
            protein: Double(protein.replacingOccurrences(of: "g Protein", with: "")) ?? 0.0,
            carbohydrates: Double(carbohydrates.replacingOccurrences(of: "g Carbohydrates", with: "")) ?? 0.0,
            date: date
        )

        userSettings.meals.append(newMeal)
        userSettings.caloriesConsumed += newMeal.calories

        clearForm()
    }

    // Clear form after adding a meal
    private func clearForm() {
        name = ""
        selectedFood = nil
        portion = 1.0
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
