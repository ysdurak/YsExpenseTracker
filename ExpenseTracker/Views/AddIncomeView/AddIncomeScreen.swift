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
    @State var oneTimeSelected: Bool

    // ExpenseService instance
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("Gelir Detayları")
                            .font(.headline)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        Text("Gelen Para")
                            .font(.subheadline)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        HStack {
                            VStack {
                                TextField("Kazandığınız para miktarı", text: $value)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 1)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.trailing, 20)
                            .frame(height: 90)
                            .padding(.leading, 25)
                            Spacer()
                        }
                        
                        Text("Gelir Tarihi")
                            .customFont(.semiBold, 16)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        HStack {
                            DatePicker(selection: $date, displayedComponents: .date) {
                                Text("Tarih seçin")
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        HStack {
                            Text("Gelir Tipi")
                                .font(.headline)
                                .frame(alignment: .leading)
                                .padding(.leading, 25)
                            
                            Text(oneTimeSelected ? "Tek seferlik" : "Aylık")
                                .opacity(0.5)
                        }
                        .padding(.bottom, 25)
                        
                        HStack {
                            Spacer()
                            VStack {
                                Image("cashRegister")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .opacity(oneTimeSelected ? 1 : 0.5)
                                Text("Tek seferlik")
                                    .font(.subheadline)
                                    .opacity(oneTimeSelected ? 1 : 0.5)
                            }
                            .frame(width: 150, height: 150)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                    .opacity(oneTimeSelected ? 1 : 0.5)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    oneTimeSelected = true
                                }
                            }
                            Spacer()
                            VStack {
                                Image("creditCard")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .opacity(!oneTimeSelected ? 1 : 0.5)
                                Text("Aylık")
                                    .font(.subheadline)
                                    .opacity(!oneTimeSelected ? 1 : 0.5)
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    oneTimeSelected = false
                                }
                            }
                            .frame(width: 150, height: 150)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                    .opacity(!oneTimeSelected ? 1 : 0.5)
                            }
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            VStack {
                                TextField("Bu gelir kalemi için notunuz", text: $note)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 1)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                            .padding(.leading, 25)
                            .padding(.trailing, 20)
                            .frame(height: 50)
                            Spacer()
                        }
                        Spacer()
                        
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
                            HStack {
                                Spacer()
                                Text("Gelir Girişini Bitir")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .frame(height: 90)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            }
                        })
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
    AddIncomeScreen(oneTimeSelected: true)
}
