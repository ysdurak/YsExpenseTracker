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
    @State var showingError = false
    @State var showSuccess = false
    @State var showPrivacyPolicy = false
    @State var showTermsOfService = false
    @State private var acceptedPrivacyPolicy = false
    @State private var acceptedTermsOfService = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all) // Background color
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .padding()
                    })
                }
                
                Spacer()
                    .frame(height: 20)
                
                Text("Hemen kayıt ol ve biriktirmeye başla!")
                    .customFont(.bold, 42)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .padding(.horizontal)
                
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 20) {
                    TextField("E-mail", text: $viewModel.email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                    
                    SecureField("Şifre", text: $viewModel.password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 20)
                
                VStack(spacing: 10) {
                    HStack {
                        Toggle(isOn: $acceptedPrivacyPolicy) {
                            Text("Gizlilik Politikasını kabul ediyorum")
                                .font(.footnote)
                                .foregroundColor(.blue)
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
                                .foregroundColor(.blue)
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
                    viewModel.registerUser {
                        // Perform registration
                    }
                }, label: {
                    Text("Kayıt Ol")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                })
                
                
                
                
                Spacer()
            }
        }
        .sheet(isPresented: $showPrivacyPolicy, content: {
            PrivacyPolicyView()
        })
        .sheet(isPresented: $showTermsOfService, content: {
            TermsOfServiceView()
        })
        .alert(isPresented: $showSuccess, content: {
            Alert(title: Text("Kayıt Başarılı"), message: Text("Başarıyla kayıt olundu! Lütfen giriş yapınız."), dismissButton: .default(Text("Tamam"), action: {
                self.presentationMode.wrappedValue.dismiss()
                viewModel.showSuccess = false // Reset the alert state if needed
            }))
        })
        .onChange(of: viewModel.showSuccess) { newValue in
            if newValue {
                showSuccess = true
            }
        }
        .alert(isPresented: $showingError, content: {
            Alert(title: Text("Hata"), message: Text(viewModel.errorMes ?? "Bir hata oluştu"), dismissButton: .default(Text("Tamam"), action: {
                viewModel.showError = false // Reset the alert state if needed
            }))
        })
        .onChange(of: viewModel.showError) { newValue in
            if newValue {
                showingError = true
            }
        }
    }
}

#Preview {
    RegisterScreen()
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
