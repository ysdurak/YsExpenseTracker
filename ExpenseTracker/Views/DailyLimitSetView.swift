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
    @State private var alert: AppAlert?
    @Environment(\.dismiss) private var dismiss
    
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
                        alert = AppAlert(kind: .warning, title: "Limit eksik", message: "Lütfen geçerli bir limit giriniz.")
                        return
                    }
                    Services.shared.setDailyLimit(limit) { error in
                        if let error = error {
                            alert = AppAlert(kind: .error, title: "Limit kaydedilemedi", message: error.localizedDescription)
                        } else {
                            alert = AppAlert(
                                kind: .success,
                                title: "Limit kaydedildi",
                                message: "Günlük harcama limitin \(limit.currency) olarak belirlendi.",
                                primary: .init(title: "Tamam") { dismiss() }
                            )
                        }
                    }
                }, label: {
                    Text("Limiti Belirle")
                })
                .buttonStyle(.primary)
                .padding(.horizontal, 30)
                .appAlert($alert)
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}
