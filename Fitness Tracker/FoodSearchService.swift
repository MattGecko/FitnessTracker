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
        self.calories = max(0, calories) // Ensure no NaN or negative values
        self.fat = max(0, fat)           // Ensure no NaN or negative values
        self.protein = max(0, protein)   // Ensure no NaN or negative values
        self.carbohydrates = max(0, carbohydrates) // Ensure no NaN or negative values
    }
}

// Define the FoodSearchService class
class FoodSearchService {
    private let apiKey = "SNb2kzUcguzzrbrHlvSEXAWIouqvXAKsWmQ4TsFg" // Replace with your USDA API Key
    private let baseURL = "https://api.nal.usda.gov/fdc/v1/foods/search"
    private let pageSize = 5 // Adjust as necessary

    // Function to search for food using the USDA API
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

                    // Ensure values are not NaN or negative by using max(0, value)
                    return FoodItem(
                        description: food.description,
                        calories: max(0, calories),
                        fat: max(0, fat),
                        protein: max(0, protein),
                        carbohydrates: max(0, carbohydrates)
                    )
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
