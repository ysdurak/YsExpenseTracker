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
        do {
            try authViewModel.signOut()
        } catch {
            print(error)
        }
    }
}
