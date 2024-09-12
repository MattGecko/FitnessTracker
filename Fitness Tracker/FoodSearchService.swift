import Foundation

// Define a struct to hold the food item data
struct FoodItem: Identifiable, Codable {
    let id: UUID
    let description: String
    let calories: Double
    let fat: Double
    let protein: Double
    let carbohydrates: Double

    // Custom initializer to create a FoodItem and automatically assign a UUID
    init(description: String, calories: Double, fat: Double, protein: Double, carbohydrates: Double) {
        self.id = UUID()
        self.description = description
        self.calories = calories
        self.fat = fat
        self.protein = protein
        self.carbohydrates = carbohydrates
    }
}

// Define the FoodSearchService class
class FoodSearchService {
    private let apiKey = "XKjTiHR6d4oXxzTwbhge0ZwLCf0L220GBeW39ph3" // Your USDA API Key
    private let baseURL = "https://api.nal.usda.gov/fdc/v1/foods/search"
    private let pageSize = 50 // Limit the number of results to 50 per page

    // Function to search for food using the USDA API with pagination support
    func searchFood(query: String, pageNumber: Int = 1, completion: @escaping (Result<[FoodItem], Error>) -> Void) {
        // Percent-encode the query to handle spaces and special characters
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?query=\(encodedQuery)&pageSize=\(pageSize)&pageNumber=\(pageNumber)&api_key=\(apiKey)") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        print("URL Request: \(url)") // Debug: Print the request URL

        // Perform the API request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle network or connection errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            // Handle non-200 HTTP status codes
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP Error: Status code \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 401 {
                        print("Unauthorized: Invalid API key")
                    } else if httpResponse.statusCode == 429 {
                        print("Rate-limited: Too many requests")
                    } else if httpResponse.statusCode == 500 {
                        print("Server error: Try again later")
                    }
                    completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }
            }

            // Ensure we have data
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            // Parse the JSON response
            do {
                let decodedResponse = try JSONDecoder().decode(USDAFoodResponse.self, from: data)

                // Map the parsed data to FoodItem objects
                let foodItems = decodedResponse.foods.map { food -> FoodItem in
                    // Extract relevant nutrient data
                    let calories = food.foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value ?? 0
                    let fat = food.foodNutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value ?? 0
                    let protein = food.foodNutrients.first(where: { $0.nutrientName == "Protein" })?.value ?? 0
                    let carbohydrates = food.foodNutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value ?? 0

                    // Ensure values are not NaN by checking and setting defaults
                    let safeCalories = calories.isNaN ? 0 : calories
                    let safeFat = fat.isNaN ? 0 : fat
                    let safeProtein = protein.isNaN ? 0 : protein
                    let safeCarbohydrates = carbohydrates.isNaN ? 0 : carbohydrates

                    // Create a FoodItem instance
                    return FoodItem(description: food.description, calories: safeCalories, fat: safeFat, protein: safeProtein, carbohydrates: safeCarbohydrates)
                }
                print("Food items found: \(foodItems.count)") // Debug: Print number of food items found
                completion(.success(foodItems))
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        // Start the network task
        task.resume()
    }
}

// Define the structures needed to parse the USDA API response
struct USDAFoodResponse: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable {
    let description: String
    let foodNutrients: [FoodNutrient]
}

struct FoodNutrient: Codable {
    let nutrientName: String
    let value: Double
}
