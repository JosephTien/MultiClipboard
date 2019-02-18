import Foundation

struct Storage: Codable{
    static var strs: [String] = []
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                             in: .userDomainMask).first!
    static let propertyEncoder = PropertyListEncoder()
    static var userDefaults: UserDefaults?{
        get{
            return UserDefaults(suiteName: "group.com.jtien.MultiClipboard")
        }
    }
    static func saveToFile() {
        let propertyEncoder = PropertyListEncoder()
        if let data = try? propertyEncoder.encode(strs) {
            let url = documentsDirectory.appendingPathComponent("Strings")
            try? data.write(to: url)
        }
        print(documentsDirectory)
    }
    static func readItemsFromFile(){
        let propertyDecoder = PropertyListDecoder()
        let url = documentsDirectory.appendingPathComponent("Strings")
        if let data = try? Data(contentsOf: url), let strs = try?
            propertyDecoder.decode([String].self, from: data) {
            Storage.strs = strs
            return
        }
        return
    }
    static func saveToShare(){
        userDefaults!.set(strs, forKey: "strs")
    }
    static func readItemsFromShare(){
        if let _strs = userDefaults!.array(forKey: "strs"){
            strs = _strs as! [String]
        }
    }
}
