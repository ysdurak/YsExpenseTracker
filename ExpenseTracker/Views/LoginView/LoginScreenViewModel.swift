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
    @Published var alert: AppAlert?
    @Published var isSigningIn: Bool = false
    
    func signIn(completion: (() -> Void)? = nil) {
        guard !email.isEmpty, !password.isEmpty else {
            alert = AppAlert(kind: .warning, title: "Bilgiler eksik", message: "E-posta ve şifre boş olamaz.")
            return
        }

        isSigningIn = true
        
        AuthenticationManager.shared.signIn(username: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSigningIn = false
                switch result {
                case .success:
                    completion?()
                case .failure(let error):
                    self?.alert = AppAlert(kind: .error, title: "Giriş yapılamadı", message: error.localizedDescription)
                }
            }
        }
    }
}
