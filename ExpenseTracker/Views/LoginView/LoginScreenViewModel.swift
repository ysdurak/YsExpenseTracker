//
//  LoginScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation

final class LoginScreenViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signIn(completion: (() -> Void)?){
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.signIn(username: email, password: password)
                
                print(returnedUserData)
                completion?()
            }
            catch {
                print(error)            }
        }
        
    }
}
