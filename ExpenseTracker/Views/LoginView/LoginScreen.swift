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
                    Image("coinmoney")
                        .resizable()
                        .frame(width: 150, height: 150)
                    Text("Paranızı yönetmenin en kolay yolu")
                        .customFont(.semiBold, 16)
                    Text("Track Me ile hemen başla !")
                        .customFont(.regular, 16)
                    VStack{
                        TextField("E-mail", text: $viewModel.email)
                            .fieldStyle()
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        SecureField("Şifre", text: $viewModel.password)
                            .fieldStyle()
                            .textContentType(.password)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Button(action: {
                            // AuthViewModel's listener takes over once Firebase signs the user in.
                            viewModel.signIn()
                        }, label: {
                            HStack(spacing: 8) {
                                if viewModel.isSigningIn {
                                    ProgressView().tint(.white)
                                }
                                Text(viewModel.isSigningIn ? "Giriş yapılıyor..." : "Giriş yap")
                            }
                        })
                        .buttonStyle(.primary)
                        .disabled(viewModel.isSigningIn)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        
                        Button(action: {
                            showRegisterSheet.toggle()
                        }) {
                            Text("Hesabın yok mu ? Kayıt ol")
                                .customFont(.medium, 14)
                                .foregroundStyle(Color.brand)
                        }
                        .sheet(isPresented: $showRegisterSheet) {
                            RegisterScreen()
                        }
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    Spacer()
                }
            }
            .appAlert($viewModel.alert)
        }
    }
}


#Preview {
    LoginScreen()
}

