import SwiftUI

// Custom ViewModifier to handle keyboard dismissal on "Done"
struct DismissKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onSubmit { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
    }
}

extension View {
    func dismissKeyboardOnDone() -> some View {
        self.modifier(DismissKeyboardModifier())
    }
}

struct ProfileView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: String = "Male"
    @State private var unitSystem: String = "Metric"
    @State private var weightLossGoal: String = "Moderate"
    @State private var bmr: Double?
    @State private var showAlert: Bool = false
    @ObservedObject var userSettings: UserSettings
    let genders = ["Male", "Female"]
    let unitSystems = ["Metric", "Imperial"]
    let weightLossGoals = [
        "Aggressive": 700,
        "Moderate": 500,
        "Slow and Steady": 300
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Your Details")) {
                    Picker("Unit System", selection: $unitSystem) {
                        ForEach(unitSystems, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .dismissKeyboardOnDone()

                    TextField(unitSystem == "Metric" ? "Weight in kg" : "Weight in lbs", text: $weight)
                        .keyboardType(.decimalPad)
                        .dismissKeyboardOnDone()

                    TextField(unitSystem == "Metric" ? "Height in cm" : "Height in inches", text: $height)
                        .keyboardType(.decimalPad)
                        .dismissKeyboardOnDone()

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
                    .dismissKeyboardOnDone()

                    Button("Calculate BMR and Calorie Target") {
                        calculateBMRandCalorieTarget()
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Calorie Target Warning"),
                      message: Text("Your calculated calorie target is below 1200 kcal/day, which may not be sufficient for most adults. Please consult with a healthcare provider."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    private func calculateBMRandCalorieTarget() {
        guard let ageNum = Int(age),
              let weightNum = Double(weight),
              let heightNum = Double(height) else {
            return
        }

        let isMale = gender == "Male"
        let weightInKg = unitSystem == "Metric" ? weightNum : weightNum * 0.453592
        let heightInCm = unitSystem == "Metric" ? heightNum : heightNum * 2.54

        let weightComponent: Double
        let heightComponent: Double
        let ageComponent: Double

        if isMale {
            weightComponent = 13.397 * weightInKg
            heightComponent = 4.799 * heightInCm
            ageComponent = 5.677 * Double(ageNum)
            bmr = 88.362 + weightComponent + heightComponent - ageComponent
        } else {
            weightComponent = 9.247 * weightInKg
            heightComponent = 3.098 * heightInCm
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

