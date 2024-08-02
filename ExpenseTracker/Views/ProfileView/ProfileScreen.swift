//
//  ProfileScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // User Avatar
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .padding(.top, 20)
                
                // User Name
                Text("Robi")
                    .font(.title)
                    .fontWeight(.bold)
                
                // User Phone
                Text("8967452743")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // User Email
                Text("robi123@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Profile Options
                VStack(alignment: .leading, spacing: 20) {
                    ProfileOptionRow(iconName: "cart.fill", title: "Order History")
                    ProfileOptionRow(iconName: "house.fill", title: "Shipping Address")
                    ProfileOptionRow(iconName: "plus.circle.fill", title: "Create Request")
                    ProfileOptionRow(iconName: "doc.text.fill", title: "Privacy Policy")
                    ProfileOptionRow(iconName: "gearshape.fill", title: "Settings")
                    ProfileOptionRow(iconName: "arrowshape.turn.up.left.fill", title: "Log out")
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
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
        .padding(.vertical, 10)
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
