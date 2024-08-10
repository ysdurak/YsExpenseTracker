//
//  DailyLimitSetView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 10.08.2024.
//

import Foundation
import SwiftUI


struct DailyLimitSetView: View {
    @State private var limitAmount: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Günlük harcama limitini belirle")
                    .customFont(.bold, 32)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                Text("Harcama veya gelirlerinizi daha iyi yönetmek için günlük harcama limitinizi belirleyiniz.")
                    .customFont(.extraLight, 14)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                TextField("Limitinizi giriniz", text: $limitAmount)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    guard let limit = Double(limitAmount) else {
                        alertMessage = "Lütfen geçerli bir limit giriniz."
                        showAlert = true
                        return
                    }
                    Services.shared.setDailyLimit(limit) { error in
                        if let error = error {
                            alertMessage = "Limit belirlenirken hata oluştu: \(error.localizedDescription)"
                        } else {
                            alertMessage = "Günlük limit başarıyla kaydedildi."
                        }
                        showAlert = true
                    }
                }, label: {
                    Text("Limiti Belirle")
                        .customFont(.semiBold, 16)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                })
                .padding(.horizontal, 30)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}
