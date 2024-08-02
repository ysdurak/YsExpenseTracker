//
//  SettingsScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 20.07.2024.
//

import Foundation
import SwiftUI

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

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsScreenViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        List {
            Button(action: {
                viewModel.signOut(authViewModel: authViewModel)
            }, label: {
                Text("Çıkış Yap")
            })
        }
    }
}
