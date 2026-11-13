//
//  RegisterScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 2.08.2024.
//

import Foundation
import SwiftUI

struct RegisterScreen: View {
    @StateObject private var viewModel = RegisterScreenViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var alert: AppAlert?
    @State private var isRegistering = false
    @State var showPrivacyPolicy = false
    @State var showTermsOfService = false
    @State private var acceptedPrivacyPolicy = false
    @State private var acceptedTermsOfService = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.primary)
                            .padding()
                    })
                }
                
                Spacer()
                    .frame(height: 20)
                
                Text("Hemen kayıt ol ve biriktirmeye başla!")
                    .customFont(.bold, 34)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .padding(.horizontal)
                
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 20) {
                    TextField("E-mail", text: $viewModel.email)
                        .fieldStyle()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Şifre", text: $viewModel.password)
                        .fieldStyle()
                        .textContentType(.newPassword)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 10) {
                    HStack {
                        Toggle(isOn: $acceptedPrivacyPolicy.animation()) {
                            Text("Gizlilik Politikasını kabul ediyorum")
                                .font(.footnote)
                                .foregroundStyle(Color.brand)
                                .underline()
                                .onTapGesture {
                                    showPrivacyPolicy.toggle()
                                }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Toggle(isOn: $acceptedTermsOfService) {
                            Text("Hizmet Şartlarını kabul ediyorum")
                                .font(.footnote)
                                .foregroundStyle(Color.brand)
                                .underline()
                                .onTapGesture {
                                    showTermsOfService.toggle()
                                }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                    .frame(height: 20)
                
                Button(action: {
                    guard acceptedPrivacyPolicy, acceptedTermsOfService else {
                        alert = AppAlert(kind: .warning, title: "Onay gerekli", message: "Devam etmek için Gizlilik Politikası ve Hizmet Şartlarını kabul etmelisin.")
                        return
                    }
                    isRegistering = true
                    // On success Firebase signs the new user in and AuthViewModel opens the app.
                    viewModel.registerUser { success in
                        isRegistering = false
                        if !success {
                            alert = AppAlert(kind: .error, title: "Kayıt olunamadı", message: viewModel.errorMes)
                        }
                    }
                }, label: {
                    HStack(spacing: 8) {
                        if isRegistering {
                            ProgressView().tint(.white)
                        }
                        Text(isRegistering ? "Kayıt olunuyor..." : "Kayıt Ol")
                    }
                })
                .buttonStyle(.primary)
                .disabled(isRegistering)
                .padding(.horizontal, 30)
                
                
                Spacer()
            }
        }
        .sheet(isPresented: $showPrivacyPolicy, content: {
            PrivacyPolicyView()
        })
        .sheet(isPresented: $showTermsOfService, content: {
            TermsOfServiceView()
        })
        .appAlert($alert)
        
    }
}



struct PrivacyPolicyView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gizlilik Politikası")
                .customFont(.semiBold, 32)
                .padding()
            ScrollView {
                Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    .customFont(.regular, 16)
                    .padding()
            }
        }
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hizmet Şartları")
                .customFont(.semiBold, 32)
                .padding()
            ScrollView {
                Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    .customFont(.regular, 16)
                    .padding()
            }
        }    }
}

#Preview {
    RegisterScreen()
}
