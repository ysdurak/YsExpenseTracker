//
//  AuthenticationManager.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 20.07.2024.
//

import Foundation
import Firebase
// AuthenticationManager.swift
import Foundation
import Firebase

struct AuthDataResultModel {
    let uid: String?
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    func signIn(username: String, password: String, completion: @escaping (Result<AuthDataResultModel, Error>) -> Void) {
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(AuthDataResultModel(user: user)))
            }
        }
    }
    
    func createUser(username: String, password: String, completion: @escaping (Result<AuthDataResultModel, Error>) -> Void) {
        Auth.auth().createUser(withEmail: username, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(AuthDataResultModel(user: user)))
            }
        }
    }
    
    func getAuthenticatedUser(completion: @escaping (Result<AuthDataResultModel, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            completion(.success(AuthDataResultModel(user: user)))
        } else {
            completion(.failure(URLError(.badServerResponse)))
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

// AuthViewModel.swift
import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    
    init() {
        checkAuthentication()
    }
    

    func checkAuthentication() {
        isLoading = true
        AuthenticationManager.shared.getAuthenticatedUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.isAuthenticated = user.uid != nil
                self?.getCategories()
            case .failure:
                self?.isAuthenticated = false
            }
        }
    }
    
    func getCategories(){
        Services.shared.getUserCategories { categories, error in
            if let categories = categories {
                Defaults.shared.userCategories = categories
                self.isLoading = false
            }
            else {
                return
            }
        }
    }
    
    
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        AuthenticationManager.shared.signOut { result in
            switch result {
            case .success:
                self.isAuthenticated = false
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
