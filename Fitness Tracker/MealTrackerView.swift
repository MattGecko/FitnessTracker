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
    @State private var isLoading = false
    @State private var pageNumber = 1 // Track the current page number
    @State private var cancellable: AnyCancellable?
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
                                performSearch(query: newValue)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, isSearching ? 0 : 10)

                        if isLoading {
                            ProgressView("Searching...")
                        }

                        if isSearching && !searchResults.isEmpty {
                            ScrollView {
                                LazyVStack {
                                    ForEach(searchResults) { food in
                                        Button(action: {
                                            selectFood(food)
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(food.description)
                                                    .font(.headline)
                                                // Ensure valid numeric values are displayed
                                                Text("\(max(0, food.calories), specifier: "%.0f") kcal")
                                                    .font(.subheadline)
                                            }
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }

                                    if !isLoading {
                                        Button("Load more results...") {
                                            loadMoreResults(query: name)
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)
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

    // Function to reset the search results and page number when a new search begins
    private func resetSearch() {
        pageNumber = 1
        searchResults = []
    }

    // Perform search and load results
    private func performSearch(query: String) {
        // Clear results and reset state if the query is too short
        if query.isEmpty || query.count < 2 {
            isSearching = false
            searchResults = []
            isLoading = false
            print("Query too short, stopping search.")
            return
        }

        // Start the search process
        isSearching = true
        isLoading = true  // Show loading indicator
        print("Searching for: \(query)")

        cancellable?.cancel()
        cancellable = Just(query)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink(receiveValue: { debouncedQuery in
                print("Debounced search for: \(debouncedQuery)")
                self.foodSearchService.searchFood(query: debouncedQuery, pageNumber: self.pageNumber) { result in
                    DispatchQueue.main.async {
                        self.isLoading = false  // Stop loading once the search completes
                        switch result {
                        case .success(let foods):
                            print("Search results found: \(foods.count) items")
                            if foods.isEmpty && self.pageNumber == 1 {
                                self.isSearching = false
                                self.searchResults = []
                            } else {
                                self.searchResults.append(contentsOf: foods) // Append the results for pagination
                            }
                        case .failure(let error):
                            print("Error searching for food: \(error.localizedDescription)")
                            self.isSearching = false  // Reset isSearching on failure
                            self.searchResults = []
                        }
                    }
                }
            })
    }

    // Load more results when the user scrolls to the bottom
    private func loadMoreResults(query: String) {
        pageNumber += 1
        performSearch(query: query)
    }

    // Select the food and autofill the nutritional info
    private func selectFood(_ food: FoodItem) {
        name = food.description
        calories = String(Int(food.calories))
        fat = String(food.fat)
        protein = String(food.protein)
        carbohydrates = String(food.carbohydrates)
        searchResults = []
        isSearching = false
    }

    // Add meal to user settings
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

    // Clear form after adding a meal
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
