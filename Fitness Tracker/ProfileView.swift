import SwiftUI

struct ProfileView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: String = "Male"
    @State private var weightLossGoal: String = "Moderate"
    @State private var bmr: Double?
    @State private var showAlert: Bool = false
    @ObservedObject var userSettings: UserSettings
    @FocusState private var isCalorieGoalFocused: Bool

    let genders = ["Male", "Female"]
    let weightLossGoals = [
        "Aggressive": 700,
        "Moderate": 500,
        "Slow and Steady": 300
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
                    .focused($isCalorieGoalFocused)

                    // Add a custom "Done" button below the calorie target field
                    if isCalorieGoalFocused {
                        Button("Done") {
                            isCalorieGoalFocused = false // Dismiss the keyboard
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Button("Calculate BMR and Calorie Target") {
                        calculateBMRandCalorieTarget()
                    }
                }
            }
            .navigationTitle("Profile")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Calorie Target Warning"),
                      message: Text("Your calculated calorie target is below 1200 kcal/day, which may not be sufficient for most adults. Please consult with a healthcare provider."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    private func calculateBMRandCalorieTarget() {
        guard let ageNum = Int(age), let weightNum = Double(weight), let heightNum = Double(height) else {
            return
        }

        let isMale = gender == "Male"
        let weightComponent: Double
        let heightComponent: Double
        let ageComponent: Double

        if isMale {
            weightComponent = 13.397 * weightNum
            heightComponent = 4.799 * heightNum
            ageComponent = 5.677 * Double(ageNum)
            bmr = 88.362 + weightComponent + heightComponent - ageComponent
        } else {
            weightComponent = 9.247 * weightNum
            heightComponent = 3.098 * heightNum
            ageComponent = 4.330 * Double(ageNum)
            bmr = 447.593 + weightComponent + heightComponent - ageComponent
        }

        if let calculatedBMR = bmr, let deficit = weightLossGoals[weightLossGoal] {
            let finalCalorieTarget = calculatedBMR - Double(deficit)
            userSettings.calorieTarget = Int(finalCalorieTarget)

            if finalCalorieTarget < 1200 {
                showAlert = true
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userSettings: UserSettings())
    }
}
