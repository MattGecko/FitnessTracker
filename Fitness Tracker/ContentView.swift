import SwiftUI

struct ContentView: View {
    @StateObject var userSettings = UserSettings()  // Initialize UserSettings in the ContentView

    init() {
        // Check and create UserData.json file if it does not exist when ContentView initializes
        if DataManager.shared.loadData() == nil {
            // Optionally, provide default data for the file
            DataManager.shared.createUserDataFile()
        }
    }

    var body: some View {
        TabView {
            ProfileView(userSettings: userSettings)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
   //         MealTrackerView(userSettings: userSettings)  // Pass the same userSettings instance
                .tabItem {
                    Label("Meals", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
