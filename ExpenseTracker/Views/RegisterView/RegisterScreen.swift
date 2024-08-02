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
    @State var showingAlert = false
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "pip.exit")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                    })
                }
                
                Spacer()
                
                TextField("E-mail", text: $viewModel.email)
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
                    viewModel.registerUser {
                        
                    }
                }, label: {
                    Text("Kayıt Ol")
                        .foregroundColor(.black)
                        .padding()
                        .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                        )
                })
                
                Spacer()
            }
            .padding(10)
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

#Preview{
    RegisterScreen()
}
