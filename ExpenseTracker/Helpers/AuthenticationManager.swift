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
    @Published var isLoading: Bool = true

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        // Firebase reports the restored session on launch and every later sign in / sign out,
        // so the UI follows the real auth state instead of a one-off check.
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            if user != nil {
                self.isLoading = true
                self.isAuthenticated = true
                self.getCategories()
            } else {
                self.isAuthenticated = false
                self.isLoading = false
            }
        }
    }

    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    func getCategories() {
        Services.shared.getUserCategories { categories, error in
            DispatchQueue.main.async {
                if let categories, !categories.isEmpty {
                    Defaults.shared.userCategories = categories
                } else {
                    if let error { print("Error fetching categories: \(error)") }
                    Defaults.shared.userCategories = Defaults.shared.categories
                }
                self.isLoading = false
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
