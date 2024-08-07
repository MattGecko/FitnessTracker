import SwiftUI

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
                    Label("Meals", systemImage: "list.bullet")
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
