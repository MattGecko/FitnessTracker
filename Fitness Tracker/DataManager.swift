import Foundation

class DataManager {
    static let shared = DataManager()  // Singleton instance of DataManager

    let fileName = "UserData.json"
    var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    var userDataPath: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }

    func loadData() -> Data? {
        if FileManager.default.fileExists(atPath: userDataPath.path) {
            do {
                return try Data(contentsOf: userDataPath)
            } catch {
                print("Error reading data: \(error)")
            }
        } else {
            print("\(fileName) file does not exist.")
            // Optionally, create the file or return default data
        }
        return nil
    }

    func createUserDataFile(with data: Data = Data()) {
        if !FileManager.default.fileExists(atPath: userDataPath.path) {
            FileManager.default.createFile(atPath: userDataPath.path, contents: data, attributes: nil)
        }
    }
}
