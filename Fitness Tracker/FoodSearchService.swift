import Foundation

// Define a struct to hold the food item data
struct FoodItem: Identifiable, Codable {
    let id: UUID = UUID() // Unique ID for each food item
    let description: String // Description of the food item
    let calories: Double // Calories in the food item
    let fat: Double // Fat content
    let protein: Double // Protein content
    let carbohydrates: Double // Carbohydrate content
}

// Define the FoodSearchService class
class FoodSearchService {
    private let apiKey = "XKjTiHR6d4oXxzTwbhge0ZwLCf0L220GBeW39ph3" // Your USDA API Key
    private let baseURL = "https://api.nal.usda.gov/fdc/v1/foods/search" // Base URL for the USDA API
    
    // Function to search for food using the USDA API
    func searchFood(query: String, completion: @escaping (Result<[FoodItem], Error>) -> Void) {
        // Construct the URL with the query and API key
        guard let url = URL(string: "\(baseURL)?query=\(query)&api_key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Perform the API request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle any errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure we have data
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            // Parse the JSON response
            do {
                let decodedResponse = try JSONDecoder().decode(USDAFoodResponse.self, from: data)
                let foodItems = decodedResponse.foods.map { food -> FoodItem in
                    // Extract relevant nutrient data
                    let calories = food.foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value ?? 0
                    let fat = food.foodNutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value ?? 0
                    let protein = food.foodNutrients.first(where: { $0.nutrientName == "Protein" })?.value ?? 0
                    let carbohydrates = food.foodNutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value ?? 0
                    
                    // Ensure values are not NaN by checking and setting defaults if necessary
                    let safeCalories = calories.isNaN ? 0 : calories
                    let safeFat = fat.isNaN ? 0 : fat
                    let safeProtein = protein.isNaN ? 0 : protein
                    let safeCarbohydrates = carbohydrates.isNaN ? 0 : carbohydrates
                    
                    // Create a FoodItem instance with the extracted data
                    return FoodItem(description: food.description, calories: safeCalories, fat: safeFat, protein: safeProtein, carbohydrates: safeCarbohydrates)
                }
                // Return the array of FoodItem objects
                completion(.success(foodItems))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Define the structures needed to parse the USDA API response
struct USDAFoodResponse: Codable {
    let foods: [USDAFood] // Array of foods in the response
}

struct USDAFood: Codable {
    let description: String // Description of the food item
    let foodNutrients: [FoodNutrient] // Array of nutrient information
}

struct FoodNutrient: Codable {
    let nutrientName: String // Name of the nutrient
    let value: Double // Value of the nutrient
}
