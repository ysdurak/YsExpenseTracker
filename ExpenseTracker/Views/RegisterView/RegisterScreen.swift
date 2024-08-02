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
    var body: some View {
        ZStack {
            VStack {
                
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
            }
        }

    }
}

#Preview{
    RegisterScreen()
}
