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
                        NavigationLink(destination: TermsOfServiceView()) {
                            ProfileOptionRow(iconName: "square.and.pencil", title: "Hizmet Şartları")
                        }
                        NavigationLink(destination: PrivacyPolicyView()) {
                            ProfileOptionRow(iconName: "doc.text.fill", title: "Gizlilik Politikası")
                        }
                        NavigationLink(destination: SettingsScreen()) {
                            ProfileOptionRow(iconName: "gearshape.fill", title: "Ayarlar")
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


