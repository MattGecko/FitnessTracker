import SwiftUI

struct InfoSourcesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Information Sources")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                Text("Clarity Calorie Counter sources its nutritional data and dietary guidance from trusted and well-established resources. Below are our key references:")
                    .font(.body)
                    .padding(.bottom, 5)

                // Eating Under 1200 Calories Disclaimer
                VStack(alignment: .leading, spacing: 5) {
                    Text("⚠️ Eating Under 1200 Calories")
                        .font(.headline)
                    Text("It is generally not recommended to consume fewer than **1200 calories per day** for most adults, as it may not meet basic nutritional needs and could lead to adverse health effects. Always consult a qualified healthcare provider or registered dietitian before adopting a calorie-restricted diet.")
                        .font(.body)
                    Link("Source: Healthline", destination: URL(string: "https://www.medicalnewstoday.com/articles/326343")!)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)

                // USDA FoodData Central
                VStack(alignment: .leading, spacing: 5) {
                    Text("🔍 USDA FoodData Central")
                        .font(.headline)
                    Text("The **USDA FoodData Central** provides accurate and updated nutritional information on thousands of food items. It is a reliable resource for calorie, macronutrient, and micronutrient data used within this app.")
                        .font(.body)
                    Link("Visit USDA FoodData Central", destination: URL(string: "https://fdc.nal.usda.gov/")!)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)

                // British Nutrition Foundation
                VStack(alignment: .leading, spacing: 5) {
                    Text("📚 British Nutrition Foundation")
                        .font(.headline)
                    Text("The **British Nutrition Foundation** provides science-based nutritional advice and guidance. We refer to their resources to ensure our dietary recommendations align with current guidelines.")
                        .font(.body)
                    Link("Visit British Nutrition Foundation", destination: URL(string: "https://www.nutrition.org.uk/")!)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)

                // General Calorie Tracking Guidance
                VStack(alignment: .leading, spacing: 5) {
                    Text("📏 Calorie Tracking Guidance")
                        .font(.headline)
                    Text("Calorie tracking apps, including Clarity Calorie Counter, provide estimates to assist with managing dietary intake. While we strive for accuracy, actual nutritional values may vary depending on portion sizes, preparation methods, and specific food brands.")
                        .font(.body)
                    Link("Learn More: Healthline Nutrition", destination: URL(string: "https://www.healthline.com/nutrition")!)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Information Sources")
    }
}

struct InfoSourcesView_Previews: PreviewProvider {
    static var previews: some View {
        InfoSourcesView()
    }
}
