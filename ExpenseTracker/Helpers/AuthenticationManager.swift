//
//  AuthenticationManager.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 20.07.2024.
//

import Foundation
import Firebase

struct AuthDataResultModel{
    
    let uid: String?
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {
        
    }
    
    func signIn(username: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: username, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func createUser(username: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: username, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func signOut() throws  {
        try Auth.auth().signOut()
    }
}
    

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    init() {
        let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
        self.isAuthenticated = authUser != nil
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
        self.isAuthenticated = false
    }
}
