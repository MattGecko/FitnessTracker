import SwiftUI
import MessageUI
import RevenueCat

struct SettingsView: View {
    @State private var isShowingMailView = false
    @State private var isShowingMailErrorAlert = false // State to show alert for mail error
    @State private var mailData = MailData(subject: "[SUPPORT REQUEST]", recipients: ["support@example.com"], body: "")
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                Button(action: {
                    contactSupport()
                }) {
                    Text("Contact Support")
                }
                .sheet(isPresented: $isShowingMailView) {
                    MailView(mailData: mailData, result: .constant(nil))
                }
                .alert(isPresented: $isShowingMailErrorAlert) {
                    Alert(title: Text("Mail Error"), message: Text("This device is not configured to send mail. Please check your email settings."), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: TermsAndConditionsView()) {
                    Text("View Terms and Conditions")
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

    private func contactSupport() {
        if MFMailComposeViewController.canSendMail() {
            let systemInfo = """
            Device: \(UIDevice.current.model)
            iOS Version: \(UIDevice.current.systemVersion)
            App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            """
            mailData.body = "Please describe your issue or question:\n\n---\nSystem Information:\n\(systemInfo)"
            isShowingMailView = true
        } else {
            // If the device can't send mail, show an alert
            isShowingMailErrorAlert = true
        }
    }

    private func upgradeToPremium() {
        Purchases.shared.getOfferings { (offerings, error) in
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
                return
            }
            
            if let offering = offerings?.current {
                Purchases.shared.purchase(package: offering.availablePackages.first!) { (transaction, customerInfo, error, userCancelled) in
                    if let error = error {
                        print("Error during purchase: \(error.localizedDescription)")
                        return
                    }
                    
                    if let customerInfo = customerInfo, customerInfo.entitlements["premium"]?.isActive == true {
                        print("User has successfully upgraded to premium!")
                        // Add any post-upgrade actions here
                    } else if userCancelled {
                        print("User cancelled the purchase.")
                    }
                }
            } else {
                print("No available offerings found.")
            }
        }
    }
}

struct MailData {
    var subject: String
    var recipients: [String]
    var body: String
}

struct MailView: UIViewControllerRepresentable {
    let mailData: MailData
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(result: Binding<Result<MFMailComposeResult, Error>?>) {
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer { controller.dismiss(animated: true) }
            if let error = error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(mailData.subject)
        vc.setToRecipients(mailData.recipients)
        vc.setMessageBody(mailData.body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {}

    // Ensure this is only presented if the device can send mail
    static func dismantleUIViewController(_ uiViewController: MFMailComposeViewController, coordinator: Self.Coordinator) {
        uiViewController.dismiss(animated: true)
    }
}
