//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//

import Foundation
import SwiftUI
import PopupView

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var date: Date = Date()
    @State var note: String = ""
    @State var value: String = ""
    @State var showAlert: Bool = false
    @State var showSuccessAlert: Bool = false
    @State var showAddCategory: Bool = false
    @State var selectedOptionIndex = 0
    
    let options = Defaults.shared.userCategories
    @State var oneTimeSelected: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Harcama Detayları")
                            .font(.headline)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        HStack{
                            Text("Kategori")
                                .font(.subheadline)
                                .frame(alignment: .leading)
                                .padding(.leading, 25)
                            
                            Button {
                                showAddCategory = true
                            } label: {
                                Image(systemName: "cross.circle.fill")
                            }
                            
                        }
                        .padding(.top, 10)
                        
                        
                        HStack {
                            VStack {
                                Menu {
                                    ForEach(0..<options.count) { index in
                                        Button(action: {
                                            selectedOptionIndex = index
                                        }) {
                                            Text(options[index].title)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(options[selectedOptionIndex].title)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.black, lineWidth: 1)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 90)
                        }
                        
                        Text("Harcanan Para")
                            .font(.subheadline)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        HStack {
                            VStack {
                                TextField("Harcadığınız para miktarı", text: $value)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 1)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .keyboardType(.decimalPad)
                                    .onChange(of: value) { newValue in
                                        // Eğer text boşsa, varsayılan olarak "" göster
                                        if newValue.isEmpty {
                                            value = ""
                                        }
                                    }
                            }
                            .padding(.trailing, 20)
                            .frame(height: 90)
                            .padding(.leading, 25)
                            Spacer()
                        }
                        
                        Text("Ödeme Tarihi")
                            .font(.subheadline)
                            .frame(alignment: .leading)
                            .padding(.leading, 25)
                        
                        HStack {
                            DatePicker(selection: $date, displayedComponents: .date) {
                                Text("Ödeme tarihini seçin")
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        HStack {
                            Text("Harcama Tipi")
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
                                TextField("Bu harcama için notunuz", text: $note)
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
                            let expense = ExpenseModel(
                                date: date,
                                title: options[selectedOptionIndex].title,
                                note: note,
                                amount: amount,
                                category: options[selectedOptionIndex]
                            )
                            Services.shared.addExpense(expense) { error in
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
                                Text("Harcamayı Bitir")
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
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
        .popup(isPresented: $showAlert) {
            Text("Lütfen bir harcama miktarı giriniz")
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
                        Text("Harcama başarıyla eklendi.")
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
        date = Date()
        note = ""
        value = ""
        selectedOptionIndex = 0
    }
}

#Preview {
    AddExpenseView(oneTimeSelected: true)
}


struct AddCategoryView: View {
    @State var categoryName: String = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            VStack{
                TextField("Yeni kategori giriniz", text: $categoryName)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .keyboardType(.decimalPad)
                
                Button(action: {
                    Services.shared.addCategories([CategoryModel(title: categoryName, identifier: categoryName)]) { error in
                        if let error = error {
                            print(error)
                        }
                        else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text("Kategoryi ekle")
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
            }
        }
    }
}

