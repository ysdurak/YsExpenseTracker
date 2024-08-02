//
//  SettingsScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 20.07.2024.
//

import Foundation
import SwiftUI


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
