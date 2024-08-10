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
    @StateObject var viewModel = AddExpenseViewModel()
    @State var date: Date = Date()
    @State var note: String = ""
    @State var value: String = ""
    @State var showAlert: Bool = false
    @State var showSuccessAlert: Bool = false
    @State var showAddCategory: Bool = false
    @State var selectedOptionIndex = 0
    
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                if viewModel.isLoading {
                    VStack{
                        ProgressView("Yükleniyor...")
                    }
                }
                else {
                    VStack {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Harcama Detayları")
                                .font(.headline)
                                .frame(alignment: .leading)
                                .padding(.leading, 25)
                            
                            RecentExpensesCell(date: date,
                                               category: viewModel.userCategories[selectedOptionIndex],
                                               note: note,
                                               value: Double(value) ?? 0)
                            .padding(.horizontal, 20)
                            
                            
                            HStack{
                                Text("Kategori")
                                    .customFont(.regular, 15)
                                    .frame(alignment: .leading)
                                    .padding(.leading, 25)
                                
                                Button {
                                    showAddCategory = true
                                } label: {
                                    Image(systemName: "cross.circle.fill")
                                        .foregroundColor(.green)
                                }
                                
                            }
                            .padding(.top, 10)
                            
                            
                            HStack {
                                Menu {
                                    ForEach(0..<viewModel.userCategories.count) { index in
                                        Button(action: {
                                            selectedOptionIndex = index
                                        }) {
                                            Text(viewModel.userCategories[index].title)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.userCategories[selectedOptionIndex].title)
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
                                
                                .padding(.horizontal, 25)
                                .frame(height: 55)
                            }
                            
                            Text("Harcanan Para")
                                .customFont(.regular, 15)
                                .frame(alignment: .leading)
                                .padding(.leading, 25)
                            
                            
                            TextField("Harcadığınız para miktarı", text: $value)
                                .padding(10)
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
                            
                                .padding(.horizontal, 25)
                            
                            
                            
                            
                            DatePicker(selection: $date, displayedComponents: [.date, .hourAndMinute]) {
                                Text("Ödeme tarihini seçin")
                            }
                            .padding(.horizontal, 25)
                            
                            
                            TextField("Bu harcama için notunuz", text: $note)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                            
                                .padding(.horizontal, 25)
                                .frame(height: 50)
                            
                            
                            Button(action: {
                                if value.isEmpty || value == "0" {
                                    showAlert = true
                                    return
                                }
                                let amount = Double(value) ?? 0.0
                                let expense = ExpenseModel(
                                    date: date,
                                    title: viewModel.userCategories[selectedOptionIndex].title,
                                    note: note,
                                    amount: amount,
                                    category: viewModel.userCategories[selectedOptionIndex]
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
                                Text("Harcamayı Bitir")
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
                        
                        Spacer()
                    }
                }
            }
            .dismissKeyboardOnTap()
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
                .environmentObject(viewModel)
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
                .fill(Color.white.opacity(0.8))
                .frame(width: 300, height: 300)
                .overlay(
                    VStack {
                        Text("Tamamdır!")
                            .customFont(.semiBold, 20)
                            .foregroundColor(.black)
                            .padding(.bottom, 20)
                        Text("Harcama başarıyla eklendi.")
                            .customFont(.regular, 16)
                            .foregroundColor(.black)
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
    //AddExpenseView()
    AddCategoryView()
}


struct AddCategoryView: View {
    @State var categoryName: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Arka plan rengi
            
            VStack(spacing: 20) {
                // Başlık kısmı
                Text("Yeni Kategori Ekle")
                    .customFont(.bold,32)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                // Açıklama metni
                Text("Harcama veya gelirlerinizi daha iyi yönetmek için bir kategori ekleyin.")
                    .customFont(.extraLight,14)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Kategori giriş alanı
                TextField("Yeni kategori giriniz", text: $categoryName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .keyboardType(.default)
                    .padding(.horizontal, 30)
                
                // Kategori ekleme butonu
                Button(action: {
                    Services.shared.addCategories([CategoryModel(title: categoryName, identifier: categoryName)]) { error in
                        if let error = error {
                            print(error)
                        }
                        else {
                            viewModel.getUserCategories {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }, label: {
                    Text("Kategori Ekle")
                        .customFont(.semiBold,16)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                })
                .padding(.horizontal, 30)
                
                Spacer() // İçeriği üst kısma itmek için
                
            }
            .padding(.top, 20)
        }
    }
}
