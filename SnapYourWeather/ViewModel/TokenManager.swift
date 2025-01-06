class TokenManager {
    static let shared = TokenManager()
    private var authToken: String?
    
    private init() {
        self.authToken = UserRepository().getSavedToken()
    }
    
    func persistToken(token: String) {
        self.authToken = token
        UserRepository().saveToken(token)
    }
    
    func unpersistToken() {
        self.authToken = nil
        UserRepository().removeToken()
    }
    
    func getToken() -> String? {
        return authToken
    }
    
    func tokenExists() -> Bool {
        return authToken != nil
    }
}
