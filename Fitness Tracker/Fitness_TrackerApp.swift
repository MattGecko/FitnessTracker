import SwiftUI


// hello josh

@main
struct FitnessTrackerApp: App {
    @StateObject private var userSettings = UserSettings()  // Initialize UserSettings here

    var body: some Scene {
        WindowGroup {
        //    ContentView(userSettings: userSettings)
        }
    }
}
