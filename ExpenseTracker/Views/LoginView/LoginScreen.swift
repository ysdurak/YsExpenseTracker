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
    @State var showingAlert: Bool = false
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
                            viewModel.signIn {
                                authViewModel.isAuthenticated = true
                            }
                        }, label: {
                            Text("Giriş yap")
                        })
                        .buttonStyle(.primary)
                        
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
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text("Hata"), message: Text(viewModel.errorMes ?? "Bir hata oluştu"), dismissButton: .default(Text("Tamam"), action: {
                    viewModel.showAlert = false // Reset the alert state if needed
                }))
            })
            .onChange(of: viewModel.showAlert) { newValue in
                if newValue {
                    showingAlert = true
                }
            }
        }
    }
}


#Preview {
    LoginScreen()
}

