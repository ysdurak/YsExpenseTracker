//
//  Services.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 21.07.2024.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class Services {
    static let shared = Services()
    private let db = Firestore.firestore()
    private init() {}
    
    // Private function to get the current user's expenses collection reference
    private func userExpensesCollection() -> CollectionReference? {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(userID).collection("expenses")
    }

    // Add Expense
    func addExpense(_ expense: ExpenseModel, completion: @escaping (Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        expensesCollection.addDocument(data: expense.toDictionary(), completion: completion)
    }

    // Get All Expenses
    func getAllExpenses(completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        expensesCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let expenses = querySnapshot?.documents.compactMap { ExpenseModel(document: $0) }
                completion(expenses, nil)
            }
        }
    }

    // Get Expenses by Category
    func getExpensesByCategory(category: String, completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        expensesCollection.whereField("category", isEqualTo: category).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let expenses = querySnapshot?.documents.compactMap { ExpenseModel(document: $0) }
                completion(expenses, nil)
            }
        }
    }

    // Get Expenses by Date
    func getExpensesByDate(startDate: Date, endDate: Date, completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        expensesCollection.whereField("date", isGreaterThanOrEqualTo: startDate).whereField("date", isLessThanOrEqualTo: endDate).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let expenses = querySnapshot?.documents.compactMap { ExpenseModel(document: $0) }
                completion(expenses, nil)
            }
        }
    }

    // Delete Expense
    func deleteExpense(id: String, completion: @escaping (Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        expensesCollection.document(id).delete(completion: completion)
    }
}
