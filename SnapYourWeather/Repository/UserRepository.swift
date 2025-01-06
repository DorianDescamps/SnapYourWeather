import Foundation

class UserRepository {
    private static let key = "token"

    static func persistToken(token: String) {
        UserDefaults.standard.set(token, forKey: key)
    }
    
    static func unpersistToken() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func getToken() -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    static func tokenExists() -> Bool {
        return getToken() != nil
    }
}
