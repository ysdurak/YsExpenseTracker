//
//  AddIncomeScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 4.08.2024.
//

import Foundation
import SwiftUI

struct AddIncomeScreen: View {
    @Environment(\.dismiss) var dismiss
    
    @State var category: String = ""
    @State var date: Date = Date()
    @State var note: String = ""
    @State var value: String = ""
    @State var alert: AppAlert?
    @State var selectedOptionIndex = 0
    
    let options = ["Yemek", "Oyun", "Kıyafet", "Market"]
    
    // ExpenseService instance
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        Text("Gelir Detayları")
                            .customFont(.semiBold, 16)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        Text("Gelen Para")
                            .customFont(.regular, 14)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        
                        TextField("Kazandığınız para miktarı", text: $value)
                            .fieldStyle()
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 25)
                        
                        
                        
                        
                        Text("Gelir Tarihi")
                            .customFont(.semiBold, 16)
                            .padding(.leading, 25)
                        
                        
                        DatePicker(selection: $date, displayedComponents: .date) {
                            Text("Tarih seçin")
                                .customFont(.regular, 14)
                        }
                        .environment(\.locale, .turkish)
                        .tint(.brand)
                        .padding(.horizontal, 25)
                        
                        TextField("Bu gelir kalemi için notunuz", text: $note)
                            .fieldStyle()
                            .padding(.top, 5)
                            .padding(.horizontal, 25)
                        
                        
                        Button(action: {
                            guard let amount = value.amountValue, amount > 0 else {
                                alert = AppAlert(kind: .warning, title: "Tutar eksik", message: "Lütfen geçerli bir gelir miktarı giriniz.")
                                return
                            }
                            let income = IncomeModel(
                                date: date,
                                title: options[selectedOptionIndex],
                                note: note,
                                amount: amount
                            )
                            Services.shared.addIncome(income) { error in
                                if let error = error {
                                    alert = AppAlert(kind: .error, title: "Gelir kaydedilemedi", message: error.localizedDescription)
                                } else {
                                    alert = AppAlert(kind: .success, title: "Gelir eklendi", message: "\(amount.currency) tutarındaki gelirin kaydedildi.")
                                    dismiss()
                                    clearParams()
                                }
                            }
                        }, label: {
                            Text("Geliri Kaydet")
                        })
                        .buttonStyle(.primary)
                        .padding(.top, 10)
                        .padding(.horizontal, 25)
                    }
                    
                    Spacer()
                }
            }
        }
        .appAlert($alert)
    }
    
    func clearParams() {
        category = ""
        date = Date()
        note = ""
        value = ""
        selectedOptionIndex = 0
    }
}

#Preview {
    AddIncomeScreen()
}
