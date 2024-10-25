import SwiftUI

struct ProfileView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var feet: String = ""
    @State private var inches: String = ""
    @State private var isMetric: Bool = true // Toggle state for metric/imperial
    @State private var gender: String = "Male"
    @State private var weightLossGoal: String = "Moderate"
    @State private var bmr: Double?
    @State private var showAlert: Bool = false // State to manage alert display
    @ObservedObject var userSettings: UserSettings
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
                    Toggle(isOn: $isMetric) {
                        Text(isMetric ? "Metric (kg, cm)" : "Imperial (lbs, ft & in)")
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    TextField(isMetric ? "Weight in kg" : "Weight in lbs", text: $weight)
                        .keyboardType(.decimalPad)
                    
                    if isMetric {
                        TextField("Height in cm", text: $height)
                            .keyboardType(.decimalPad)
                    } else {
                        HStack {
                            TextField("Height (ft)", text: $feet)
                                .keyboardType(.numberPad)
                            TextField("Height (in)", text: $inches)
                                .keyboardType(.numberPad)
                        }
                    }
                    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24)) // Adjust the size of the gear icon
                            .foregroundColor(.blue)  // Customize the color of the gear icon
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
              let heightNum = isMetric ? Double(height) : (Double(feet) ?? 0) * 30.48 + (Double(inches) ?? 0) * 2.54
        else { return }
        
        let isMale = gender == "Male"
        
        let weightComponent: Double
        let heightComponent: Double
        let ageComponent: Double
        
        let weightInKg = isMetric ? weightNum : weightNum * 0.453592 // Convert lbs to kg if using imperial
        let heightInCm = isMetric ? heightNum : (Double(feet) ?? 0) * 30.48 + (Double(inches) ?? 0) * 2.54 // Convert ft and in to cm if using imperial

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
