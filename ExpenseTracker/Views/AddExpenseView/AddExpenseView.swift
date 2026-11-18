//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import VisionKit

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = AddExpenseViewModel()
    @StateObject var scanViewModel = ScanExpenseViewModel()
    @State var showReceiptOptions: Bool = false
    @State var showDocumentScanner: Bool = false
    @State var showReceiptPicker: Bool = false
    @State var receiptItem: PhotosPickerItem?
    @State var screenshotItems: [PhotosPickerItem] = []
    @State var date: Date = Date()
    @State var note: String = ""
    @State var value: String = ""
    @State var alert: AppAlert?
    @State var showAddCategory: Bool = false
    @State var selectedOptionIndex = 0
    
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                // Categories arrive asynchronously; the form indexes into them, so wait until they exist.
                if viewModel.isLoading || viewModel.userCategories.isEmpty {
                    VStack{
                        ProgressView("Yükleniyor...")
                    }
                }
                else {
                    VStack {
                        scanButtons
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                        VStack(alignment: .leading, spacing: 15) {
                            Text("Harcama Detayları")
                                .font(.headline)
                                .frame(alignment: .leading)
                                .padding(.leading, 25)
                            
                            RecentExpensesCell(date: date,
                                               category: viewModel.userCategories[selectedOptionIndex],
                                               note: note,
                                               value: value.amountValue ?? 0)
                            .padding(.horizontal, 20)
                            
                            
                            HStack{
                                Text("Kategori")
                                    .customFont(.regular, 15)
                                    .frame(alignment: .leading)
                                    .padding(.leading, 25)
                                
                                Button {
                                    showAddCategory = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(Color.brand)
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
                                        CategoryIcon(identifier: viewModel.userCategories[selectedOptionIndex].identifier, size: 26)
                                        Text(viewModel.userCategories[selectedOptionIndex].title)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundStyle(.secondary)
                                    }
                                    .fieldStyle()
                                }
                                .tint(.primary)
                                
                                .padding(.horizontal, 25)
                                .frame(height: 55)
                            }
                            
                            Text("Harcanan Para")
                                .customFont(.regular, 15)
                                .frame(alignment: .leading)
                                .padding(.leading, 25)
                            
                            
                            TextField("Harcadığınız para miktarı", text: $value)
                                .fieldStyle()
                                .keyboardType(.decimalPad)
                                .onChange(of: value) { newValue in
                                    // Eğer text boşsa, varsayılan olarak "" göster
                                    if newValue.isEmpty {
                                        value = ""
                                    }
                                }
                            
                                .padding(.horizontal, 25)
                            
                            
                            
                            
                            DatePicker(selection: $date, displayedComponents: [.date, .hourAndMinute]) {
                                Text("Ödeme tarihi")
                                    .customFont(.regular, 15)
                            }
                            .environment(\.locale, .turkish)
                            .tint(.brand)
                            .padding(.horizontal, 25)
                            
                            
                            TextField("Bu harcama için notunuz", text: $note)
                                .fieldStyle()
                                .padding(.horizontal, 25)
                            
                            
                            Button(action: {
                                guard let amount = value.amountValue, amount > 0 else {
                                    alert = AppAlert(kind: .warning, title: "Tutar eksik", message: "Lütfen geçerli bir harcama miktarı giriniz.")
                                    return
                                }
                                let expense = ExpenseModel(
                                    date: date,
                                    title: viewModel.userCategories[selectedOptionIndex].title,
                                    note: note,
                                    amount: amount,
                                    category: viewModel.userCategories[selectedOptionIndex]
                                )
                                Services.shared.addExpense(expense) { error in
                                    if let error = error {
                                        alert = AppAlert(kind: .error, title: "Harcama kaydedilemedi", message: error.localizedDescription)
                                    } else {
                                        alert = AppAlert(kind: .success, title: "Harcama eklendi", message: "\(amount.currency) tutarındaki harcaman kaydedildi.")
                                        dismiss()
                                        clearParams()
                                    }
                                }
                            }, label: {
                                Text("Harcamayı Kaydet")
                            })
                            .buttonStyle(.primary)
                            .padding(.top, 10)
                            .padding(.horizontal, 25)
                        }
                        
                        Spacer()
                    }
                }
            }
            .dismissKeyboardOnTap()
            .tabBarSafeArea()

            if scanViewModel.isProcessing {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView("Taranıyor...")
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .frame(maxWidth: .infinity)
            }
        }
        .confirmationDialog("Fiş tara", isPresented: $showReceiptOptions) {
            if VNDocumentCameraViewController.isSupported {
                Button("Kamerayla tara") { showDocumentScanner = true }
            }
            Button("Galeriden seç") { showReceiptPicker = true }
        }
        .fullScreenCover(isPresented: $showDocumentScanner) {
            DocumentScannerView { images in
                scan(images, source: .receipt)
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showReceiptPicker, selection: $receiptItem, matching: .images)
        .onChange(of: receiptItem) { item in
            guard let item else { return }
            receiptItem = nil
            Task { scan(await loadImages([item]), source: .receipt) }
        }
        .onChange(of: screenshotItems) { items in
            guard !items.isEmpty else { return }
            screenshotItems = []
            Task { scan(await loadImages(items), source: .bankScreenshot) }
        }
        .sheet(isPresented: $scanViewModel.showReview) {
            ScanReviewView(viewModel: scanViewModel) {
                alert = AppAlert(kind: .success, title: "Harcamalar eklendi", message: "Seçtiğin harcamalar kaydedildi.")
            }
        }
        .onChange(of: scanViewModel.showNothingFound) { _, nothingFound in
            guard nothingFound else { return }
            scanViewModel.showNothingFound = false
            alert = AppAlert(
                kind: .warning,
                title: "İşlem bulunamadı",
                message: scanViewModel.errorMessage ?? "Bu görselde bir harcama bulamadık. Harcamayı formdan elle ekleyebilirsin.",
                primary: .init(title: "Elle ekle")
            )
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
                .environmentObject(viewModel)
        }
        .appAlert($alert)
    }
    
    var scanButtons: some View {
        HStack(spacing: 12) {
            Button {
                showReceiptOptions = true
            } label: {
                scanButtonLabel(title: "Fiş tara", systemImage: "camera.fill")
            }

            PhotosPicker(selection: $screenshotItems, maxSelectionCount: 10, matching: .images) {
                scanButtonLabel(title: "Ekran görüntüsü", systemImage: "photo.on.rectangle")
            }
        }
        .disabled(scanViewModel.isProcessing)
    }

    func scanButtonLabel(title: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
                .customFont(.medium, 14)
        }
        .foregroundStyle(Color.brand)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.brand.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    func loadImages(_ items: [PhotosPickerItem]) async -> [UIImage] {
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                images.append(image)
            }
        }
        return images
    }

    func scan(_ images: [UIImage], source: ScanExpenseViewModel.Source) {
        Task {
            await scanViewModel.process(images, source: source, userCategories: viewModel.userCategories)
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
            Color.appBackground.ignoresSafeArea() // Arka plan rengi
            
            VStack(spacing: 20) {
                // Başlık kısmı
                Text("Yeni Kategori Ekle")
                    .customFont(.bold, 28)
                    .foregroundStyle(.primary)
                    .padding(.top, 40)
                
                // Açıklama metni
                Text("Harcama veya gelirlerinizi daha iyi yönetmek için bir kategori ekleyin.")
                    .customFont(.regular, 14)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Kategori giriş alanı
                TextField("Yeni kategori giriniz", text: $categoryName)
                    .fieldStyle()
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
                })
                .buttonStyle(.primary)
                .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 30)
                
                Spacer() // İçeriği üst kısma itmek için
                
            }
            .padding(.top, 20)
        }
    }
}
