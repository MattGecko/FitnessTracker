import SwiftUI
import Combine

struct MealTrackerView: View {
    @ObservedObject var userSettings: UserSettings
    @State private var name: String = ""
    @State private var selectedFoodName: String = "" // New state variable for the selected food name
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
                                LazyVStack(spacing: 10) { // Add spacing between results
                                    ForEach(searchResults) { food in
                                        Button(action: {
                                            selectFood(food)
                                        }) {
                                            VStack(alignment: .leading, spacing: 5) { // Add spacing inside each item
                                                Text(food.description)
                                                    .font(.headline)
                                                    .foregroundColor(.primary) // Custom text color
                                                Text("\(max(0, food.calories), specifier: "%.0f") kcal")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity) // Ensure the search results are full width
                                            .padding() // Add padding inside each item
                                            .background(Color(.systemGray6)) // Subtle background color
                                            .cornerRadius(10) // Rounded corners
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Add shadow
                                        }
                                        Divider() // Add divider between results
                                    }

                                    if !isLoading {
                                        Button("Load more results...") {
                                            loadMoreResults(query: name)
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .padding(.horizontal) // Add padding around the entire results list
                            .frame(height: 300) // Increase the height for a better view
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
        searchTimer?.invalidate() // Invalidate the timer when the search changes
    }

    // Schedule the search using a timer (2-second delay after typing stops)
    private func scheduleSearch(query: String) {
        searchTimer?.invalidate()  // Invalidate the timer on each keystroke
        guard query.count >= 3 else {
            print("Query too short, stopping search.")
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
        print("User stopped typing. Proceeding with search for: \(query)")

        isSearching = true
        isLoading = true  // Show loading indicator

        cancellable?.cancel()  // Cancel any ongoing search

        self.foodSearchService.searchFood(query: query, pageNumber: self.pageNumber) { result in
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
    }

    // Load more results when the user scrolls to the bottom
    private func loadMoreResults(query: String) {
        pageNumber += 1
        performSearch(query: query)
    }

    // Select the food and autofill the nutritional info
    private func selectFood(_ food: FoodItem) {
        selectedFoodName = food.description // Persist the selected food name
        name = "" // Clear the search bar
        calories = "\(Int(food.calories)) kcal"  // Add kcal for calories
        fat = "\(food.fat)g Fat"  // Format with unit and label
        protein = "\(food.protein)g Protein"  // Format with unit and label
        carbohydrates = "\(food.carbohydrates)g Carbohydrates"  // Format with unit and label

        searchResults = []
        isSearching = false
    }

    // Add meal to user settings
    private func addMeal() {
        let newMeal = FoodMeal(
            name: selectedFoodName,  // Use selectedFoodName to log the food item
            mealType: mealType,
            calories: Int(calories.replacingOccurrences(of: " kcal", with: "")) ?? 0,
            fat: Double(fat.replacingOccurrences(of: "g Fat", with: "")) ?? 0.0,
            protein: Double(protein.replacingOccurrences(of: "g Protein", with: "")) ?? 0.0,
            carbohydrates: Double(carbohydrates.replacingOccurrences(of: "g Carbohydrates", with: "")) ?? 0.0,
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
        selectedFoodName = "" // Clear the selected food name after saving
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
