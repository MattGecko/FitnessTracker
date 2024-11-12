import SwiftUI
import RevenueCat

@main
struct FitnessTrackerApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView() // This is where your ContentView is set as the root view
        }
    }
    
   // init(){
        
    //    Purchases.logLevel = .debug
     //   Purchases.configure(withAPIKey: "appl_lLUTDjrcfeuWHRNqGYxfwIfOHTb")
        
   // }
    }
    



struct ContentView: View {
    @StateObject var userSettings = UserSettings()

    var body: some View {
        TabView {
            ProfileView(userSettings: userSettings)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            MealTrackerView(userSettings: userSettings)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
            FoodLogView(userSettings: userSettings)
                    .tabItem {
                        Label("Food Log", systemImage: "calendar")
                    }
        }
        .onAppear {
            checkAndInitializeData()
        }
    }

    private func checkAndInitializeData() {
        // Check and create UserData.json file if it does not exist when ContentView is displayed
        if DataManager.shared.loadData() == nil {
            // Optionally, provide default data for the file
            DataManager.shared.createUserDataFile()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
