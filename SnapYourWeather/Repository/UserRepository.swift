import Foundation

class TokenManager {
    private static let key = "token"
    private static var token: String? = nil

    static func persistToken(token: String) {
        print("TokenManager: Token persisted.")
        self.token = token
        UserDefaults.standard.set(token, forKey: key)
    }
    
    static func unpersistToken() {
        print("TokenManager: Token unpersisted.")
        self.token = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func getToken() -> String? {
        print("TokenManager: Token retrieved.")
        if token == nil {
            token = UserDefaults.standard.string(forKey: key)
        }
        return self.token
    }
    
    static func tokenExists() -> Bool {
        print("TokenManager: Token exists.")
        return getToken() != nil
    }
}
