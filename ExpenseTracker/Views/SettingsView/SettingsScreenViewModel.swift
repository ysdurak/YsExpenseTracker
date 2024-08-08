//
//  SettingsScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation

@MainActor
final class SettingsScreenViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = true

    func signOut(authViewModel: AuthViewModel) {
        AuthenticationManager.shared.signOut { result in
            switch result {
            case .success(let success):
                authViewModel.signOut { result in
                    
                }
            case .failure(let failure): break
                
            }
        }
    }
}
