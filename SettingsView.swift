import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                Button(action: {
                    viewTermsAndConditions()
                }) {
                    Text("View Terms and Conditions")
                }

                Button(action: {
                    contactSupport()
                }) {
                    Text("Contact Support")
                }
            }
            
            Section(header: Text("Upgrade")) {
                Button(action: {
                    upgradeToPremium()
                }) {
                    Text("Upgrade to Premium")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Settings")
    }
    
    // Functions to handle the actions
    private func viewTermsAndConditions() {
        // Handle viewing terms and conditions
        print("Viewing Terms and Conditions")
    }
    
    private func contactSupport() {
        // Handle contacting support
        print("Contacting Support")
    }
    
    private func upgradeToPremium() {
        // Placeholder for launching the paywall screen
        print("Upgrade to Premium button tapped")
        // This will eventually trigger the paywall screen (e.g., RevenueCat or StoreKit)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
