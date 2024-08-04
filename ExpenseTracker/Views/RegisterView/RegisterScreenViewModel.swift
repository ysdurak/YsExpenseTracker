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
    @Published var showError: Bool = false
    @Published var showSuccess: Bool = false
    
    func registerUser(completion: (() -> Void)?){
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(username: email, password: password)
                showSuccess = true
                print(returnedUserData)
                completion?()
            }
            catch {
                errorMes = error.localizedDescription
                showError = true
                print(error)            }
        }
        
    }
    
}
