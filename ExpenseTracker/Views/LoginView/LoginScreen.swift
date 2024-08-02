//
//  LoginScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 20.07.2024.
//

import Foundation
import SwiftUI
import Firebase



struct LoginScreen: View {
    @StateObject private var viewModel = LoginScreenViewModel()
    @EnvironmentObject  var authViewModel: AuthViewModel
    @State var showRegisterSheet: Bool = false
    var body: some View {
        NavigationStack {
            ZStack{
                VStack(spacing: 10){
                    Spacer()
                    Image("money")
                        .resizable()
                        .frame(width: 200, height: 180)
                    Text("Paranızı yönetmenin en kolay yolu")
                        .font(.headline)
                    Text("Track Me ile hemen başla !")
                    VStack{
                        TextField("Kullanıcı Adı", text: $viewModel.email)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        SecureField("Şifre", text: $viewModel.password)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Button(action: {
                            viewModel.signIn {
                                authViewModel.isAuthenticated = true
                            }
                        }, label: {
                            Text("Giriş Yap")
                                .foregroundColor(.black)
                                .padding()
                                .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                                )
                        })
                        
                        Spacer()
                            .frame(height: 20)
                        
                        
                        Button(action: {
                            showRegisterSheet.toggle()
                        }) {
                            Text("Hesabın yok mu ? Kayıt ol")
                                .customFont(.light, 14)
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showRegisterSheet) {
                            RegisterScreen()
                        }
                        
                        
                            
                        
                        
                    }
                    .padding(.all, 10)
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    LoginScreen()
}

