//
//  TestView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 5.08.2024.
//
//
//import Foundation
//
//import SwiftUI
//
//struct TestView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//
//    var body: some View {
//        VStack {
//            Spacer()
//
//            // Title
//            Text("Login")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.bottom, 4)
//
//            // Subtitle
//            Text("Please sign in to continue.")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .padding(.bottom, 40)
//
//            // Email Field
//            HStack {
//                Image(systemName: "envelope.fill")
//                    .foregroundColor(.gray)
//                TextField("Email", text: $email)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(radius: 5)
//            .padding(.horizontal, 24)
//            .padding(.bottom, 20)
//
//            // Password Field
//            HStack {
//                Image(systemName: "lock.fill")
//                    .foregroundColor(.gray)
//                SecureField("Password", text: $password)
//                Spacer()
//                Text("FORGOT")
//                    .font(.footnote)
//                    .foregroundColor(.orange)
//                    .padding(.trailing, 8)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(radius: 5)
//            .padding(.horizontal, 24)
//            .padding(.bottom, 40)
//
//            // Login Button
//            Button(action: {
//                // Handle login action
//            }) {
//                Text("LOGIN")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .leading, endPoint: .trailing))
//                    .cornerRadius(10)
//                    .padding(.horizontal, 24)
//            }
//
//            Spacer()
//
//            // Sign Up
//            HStack {
//                Text("Don't have an account?")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//                Button(action: {
//                    // Handle sign up action
//                }) {
//                    Text("Sign up")
//                        .font(.footnote)
//                        .foregroundColor(.orange)
//                }
//            }
//            .padding(.bottom, 40)
//        }
//        .background(Color(UIColor.systemGroupedBackground))
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//    }
//}
