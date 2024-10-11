import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                Button(action: {
                    // Code to view terms and conditions
                    viewTermsAndConditions()
                }) {
                    Text("View Terms and Conditions")
                }

                Button(action: {
                    // Code to contact support
                    contactSupport()
                }) {
                    Text("Contact Support")
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
