//
//  ProfileScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 10) {
                        Text(viewModel.displayName.prefix(1).uppercased())
                            .customFont(.semiBold, 34)
                            .foregroundStyle(.white)
                            .frame(width: 84, height: 84)
                            .background(Color.brand.gradient, in: Circle())
                        Text(viewModel.displayName)
                            .customFont(.semiBold, 22)
                        Text(viewModel.email)
                            .customFont(.regular, 13)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                Section {
                    NavigationLink(destination: SettingsScreen().environmentObject(authViewModel)) {
                        ProfileOptionRow(iconName: "gearshape.fill", title: "Ayarlar", color: .gray)
                    }
                }

                Section {
                    NavigationLink(destination: TermsOfServiceView()) {
                        ProfileOptionRow(iconName: "doc.plaintext.fill", title: "Hizmet Şartları", color: .blue)
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        ProfileOptionRow(iconName: "hand.raised.fill", title: "Gizlilik Politikası", color: .indigo)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Profil")
            .onAppear { viewModel.fetchData() }
        }
    }
}

struct ProfileOptionRow: View {
    let iconName: String
    let title: String
    var color: Color = .brand

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(title)
                .customFont(.regular, 16)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ProfileScreen()
}
