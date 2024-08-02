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
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // User Avatar
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                        .padding(.top, 20)
                    
                    // User Name
                    Text("Ceren")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // User Email
                    Text(viewModel.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Profile Options
                    VStack(alignment: .leading, spacing: 5) {
                        NavigationLink(destination: CreateRequestScreen()) {
                            ProfileOptionRow(iconName: "plus.circle.fill", title: "Create Request")
                        }
                        NavigationLink(destination: PrivacyPolicyScreen()) {
                            ProfileOptionRow(iconName: "doc.text.fill", title: "Privacy Policy")
                        }
                        NavigationLink(destination: SettingsScreenEx()) {
                            ProfileOptionRow(iconName: "gearshape.fill", title: "Settings")
                        }
                        NavigationLink(destination: LogoutScreen()) {
                            ProfileOptionRow(iconName: "arrowshape.turn.up.left.fill", title: "Log out")
                        }
                    }
                    
                    
                    Spacer()
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        }
    }
}

struct ProfileOptionRow: View {
    let iconName: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.orange)
                .frame(width: 24, height: 24)
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}


struct CreateRequestScreen: View {
    var body: some View {
        Text("Create Request Screen")
            .navigationTitle("Create Request")
    }
}

struct PrivacyPolicyScreen: View {
    var body: some View {
        Text("Privacy Policy Screen")
            .navigationTitle("Privacy Policy")
    }
}

struct SettingsScreenEx: View {
    var body: some View {
        Text("Settings Screen")
            .navigationTitle("Settings")
    }
}

struct LogoutScreen: View {
    var body: some View {
        Text("Logout Screen")
            .navigationTitle("Log Out")
    }
}
