//
//  AddIncomeScreen.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 4.08.2024.
//

import Foundation
import SwiftUI
import PopupView

struct AddIncomeScreen: View {
    @Environment(\.dismiss) var dismiss
    
    @State var category: String = ""
    @State var date: Date = Date()
    @State var note: String = ""
    @State var value: String = ""
    @State var showAlert: Bool = false
    @State var showSuccessAlert: Bool = false
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
                                showAlert = true
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
                                    print("Error adding expense: \(error)")
                                } else {
                                    showSuccessAlert = true
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
        .popup(isPresented: $showAlert) {
            Label("Lütfen geçerli bir gelir miktarı giriniz", systemImage: "exclamationmark.circle.fill")
                .font(.customFont(.medium, 14))
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(.regularMaterial, in: Capsule())
        } customize: {
            $0.autohideIn(2)
        }
        .popup(isPresented: $showSuccessAlert) {
            SuccessToast(title: "Tamamdır!", message: "Gelir başarıyla eklendi.")
        } customize: {
            $0.autohideIn(2)
        }
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
