//
//  RegisterScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation

final class RegisterScreenViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMes: String = ""

    func registerUser(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMes = "Email veya şifre boş olamaz."
            completion(false) // Failure
            return
        }

        AuthenticationManager.shared.createUser(username: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    Services.shared.addCategories(Defaults.shared.categories) { error in
                        if let error = error {
                            print("Error adding categories: \(error)")
                            completion(false) // Failure
                        } else {
                            completion(true) // Success
                        }
                    }
                case .failure(let error):
                    self?.errorMes = error.localizedDescription
                    completion(false) // Failure
                }
            }
        }

    }
}
