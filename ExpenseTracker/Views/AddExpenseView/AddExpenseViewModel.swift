//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 9.08.2024.
//
//
//import Foundation
//import SwiftUI
//import Combine
//import FirebaseFirestore
//
//class AddExpenseViewModel: ObservableObject {
//    @Published var expenseName: String = ""
//    @Published var expenseAmount: String = ""
//    @Published var expenseCategory: String = ""
//    @Published var currentStep: ExpenseStep = .name
//
//    private var cancellables = Set<AnyCancellable>()
//    private let db = Firestore.firestore()
//    
//    enum ExpenseStep {
//        case name, amount, category, completed
//    }
//    
//    func saveExpense() {
//        guard !expenseName.isEmpty, !expenseAmount.isEmpty, !expenseCategory.isEmpty else {
//            return
//        }
//
//        let newExpense = [
//            "name": expenseName,
//            "amount": Double(expenseAmount) ?? 0.0,
//            "category": expenseCategory,
//            "date": Date()
//        ] as [String : Any]
//
//        db.collection("expenses").addDocument(data: newExpense) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                self.moveToNextStep()
//            }
//        }
//    }
//    
//    func moveToNextStep() {
//        switch currentStep {
//        case .name:
//            currentStep = .amount
//        case .amount:
//            currentStep = .category
//        case .category:
//            currentStep = .completed
//        case .completed:
//            resetForm()
//        }
//    }
//
//    func resetForm() {
//        expenseName = ""
//        expenseAmount = ""
//        expenseCategory = ""
//        currentStep = .name
//    }
//}
