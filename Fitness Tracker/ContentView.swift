import SwiftUI
import RevenueCat
import RevenueCatUI

@main
struct FitnessTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentPaywallIfNeeded(requiredEntitlementIdentifier: "PRO")
        }
    }
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_lLUTDjrcfeuWHRNqGYxfwIfOHTb")
    }
}

struct ContentView: View {
    @StateObject var userSettings = UserSettings()
    @State private var isExpanded = false // Controls the radial menu expansion
    @State private var selectedTab = 0 // Tracks active tab

    var body: some View {
        ZStack {
            VStack {
                // Main Tab View without default bar
                TabView(selection: $selectedTab) {
                    ProfileView(userSettings: userSettings)
                        .tag(0)
                    
                    MealTrackerView(userSettings: userSettings)
                        .tag(1)

                    FoodLogView(userSettings: userSettings)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Removes default tab bar
                
                // Custom Bottom Navigation Bar with Center + Button
                HStack {
                    Spacer()
                    
                    // Profile Tab Button
                    Button(action: {
                        selectedTab = 0
                    }) {
                        VStack {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)
                    
                    Spacer()
                    
                    // Center + Button (Controls Radial Menu)
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "xmark.circle.fill" : "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 10)

                    Spacer()
                    
                    // Food Log Tab Button
                    Button(action: {
                        selectedTab = 2
                    }) {
                        VStack {
                            Image(systemName: "calendar")
                            Text("Food Log")
                        }
                    }
                    .foregroundColor(selectedTab == 2 ? .blue : .gray)
                    
                    Spacer()
                }
                .padding(.top, 5)
                .frame(height: 60)
                .background(Color(UIColor.systemGray6))
                .overlay(
                    // Radial menu expands here
                    RadialMenuView(isExpanded: $isExpanded)
                )
            }
        }
        .onAppear {
            checkAndInitializeData()
        }
    }

    private func checkAndInitializeData() {
        if DataManager.shared.loadData() == nil {
            DataManager.shared.createUserDataFile()
        }
    }
}
