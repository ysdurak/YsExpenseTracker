//
//  LoginScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import Combine

final class LoginScreenViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var errorMes: String = ""
    
    func signIn(completion: (() -> Void)? = nil) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMes = "Email veya şifre boş olamaz."
            showAlert = true
            return
        }
        
        AuthenticationManager.shared.signIn(username: email, password: password) { [weak self] result in
            switch result {
            case .success(let userData):
                print(userData)
                DispatchQueue.main.async {
                    completion?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMes = error.localizedDescription
                    self?.showAlert = true
                }
                print(error)
            }
        }
    }
}
