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
            Section {
                NavigationLink(destination: DailyLimitSetView()) {
                    Label("Günlük Limit", systemImage: "gauge.with.dots.needle.33percent")
                }
            }
            Section {
                Button(role: .destructive) {
                    viewModel.signOut(authViewModel: authViewModel)
                } label: {
                    Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.inline)
    }
}
