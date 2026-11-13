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
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Günlük harcama limitini belirle")
                    .customFont(.bold, 28)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                Text("Harcama veya gelirlerinizi daha iyi yönetmek için günlük harcama limitinizi belirleyiniz.")
                    .customFont(.regular, 14)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                TextField("Limitinizi giriniz", text: $limitAmount)
                    .fieldStyle()
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    guard let limit = limitAmount.amountValue, limit > 0 else {
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
                })
                .buttonStyle(.primary)
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
