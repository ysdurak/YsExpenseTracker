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
    @State var value: String = "0"
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
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .keyboardType(.decimalPad)
                        
                        .padding(.horizontal, 25)
                        .frame(height: 50)
                        
                        
                        
                        
                        Text("Gelir Tarihi")
                            .customFont(.semiBold, 16)
                            .padding(.leading, 25)
                        
                        
                        DatePicker(selection: $date, displayedComponents: .date) {
                            Text("Tarih seçin")
                                .customFont(.regular, 14)
                        }
                        .padding(.horizontal, 25)
                        
                        TextField("Bu gelir kalemi için notunuz", text: $note)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .padding(.top, 5)
                            .padding(.horizontal, 25)
                            .frame(height: 50)
                        
                        
                        Button(action: {
                            if value.isEmpty || value == "0" {
                                showAlert = true
                                return
                            }
                            let amount = Double(value) ?? 0.0
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
                            Text("Gelir girişini bitir")
                                .customFont(.semiBold,16)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        })
                        .padding(.top, 10)
                        .padding(.horizontal, 25)
                    }
                    .background(Color.white)
                    
                    Spacer()
                }
            }
        }
        .popup(isPresented: $showAlert) {
            Text("Lütfen bir gelir miktarı giriniz")
                .frame(width: 200, height: 60)
                .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                .cornerRadius(30.0)
        } customize: {
            $0.autohideIn(2)
        }
        .popup(isPresented: $showSuccessAlert) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .frame(width: 300, height: 200)
                .overlay(
                    VStack {
                        Text("Tamamdır!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        Text("Gelir başarıyla eklendi.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                        .padding()
                )
                .padding()
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
