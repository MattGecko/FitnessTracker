import SwiftUI

struct ProfileView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: String = "Male"
    @State private var weightLossGoal: String = "Moderate"
    @State private var bmr: Double?

    @ObservedObject var userSettings: UserSettings

    let genders = ["Male", "Female"]
    let weightLossGoals = [
        "Aggressive": 500,
        "Moderate": 300,
        "Slow and Steady": 200
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Your Details")) {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Weight in kg", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Height in cm", text: $height)
                        .keyboardType(.decimalPad)
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Weight Loss Goal", selection: $weightLossGoal) {
                        ForEach(weightLossGoals.keys.sorted(), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                }

                Section(header: Text("Calculated BMR and Calorie Target")) {
                    if let bmr = bmr {
                        Text("BMR: \(bmr, specifier: "%.0f") kcal/day")
                    }
                    TextField("Calorie Target", text: Binding(
                        get: { String(userSettings.calorieTarget) },
                        set: { userSettings.calorieTarget = Int($0) ?? userSettings.calorieTarget }
                    ))
                    .keyboardType(.numberPad)
                    Button("Calculate BMR and Calorie Target") {
                        calculateBMRandCalorieTarget()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    private func calculateBMRandCalorieTarget() {
        guard let ageNum = Int(age), let weightNum = Double(weight), let heightNum = Double(height) else {
            return  // Optionally add user feedback here to indicate input error
        }
        
        let isMale = gender == "Male"
        let weightComponent = 13.397 * weightNum
        let heightComponent = 4.799 * heightNum
        let ageComponent = 5.677 * Double(ageNum)
        
        if isMale {
            bmr = 88.362 + weightComponent + heightComponent - ageComponent
        } else {
            bmr = 447.593 + weightComponent + heightComponent - ageComponent
        }

        if let calculatedBMR = bmr, let deficit = weightLossGoals[weightLossGoal] {
            let finalCalorieTarget = calculatedBMR - Double(deficit)
            userSettings.calorieTarget = Int(finalCalorieTarget)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userSettings: UserSettings())
    }
}
