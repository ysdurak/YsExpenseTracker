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
    
        // Önceki kodlar...

        func getExpensesByDate(for period: Calendar.Component, value: Int, completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
            guard let expensesCollection = userExpensesCollection() else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
                return
            }
            
            let calendar = Calendar.current
            let now = Date()
            let startDate = calendar.date(byAdding: period, value: -value, to: now)!
            
            expensesCollection.whereField("date", isGreaterThanOrEqualTo: startDate).whereField("date", isLessThanOrEqualTo: now).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    let expenses = querySnapshot?.documents.compactMap { ExpenseModel(document: $0) }
                    completion(expenses, nil)
                }
            }
        }
        
        func getWeeklyExpenses(completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
            getExpensesByDate(for: .weekOfYear, value: 1, completion: completion)
        }
        
        func getMonthlyExpenses(completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
            getExpensesByDate(for: .month, value: 1, completion: completion)
        }
        
        func getYearlyExpenses(completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
            getExpensesByDate(for: .year, value: 1, completion: completion)
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
    
    func addIncome(_ income: IncomeModel, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        let incomeCollection = db.collection("users").document(userID).collection("incomes")
        incomeCollection.addDocument(data: income.toDictionary(), completion: completion)
    }

    // Get Monthly Income
    func getMonthlyIncome(year: Int, month: Int, completion: @escaping (Double, Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let incomeCollection = db.collection("users").document(userID).collection("incomes")
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let startDate = calendar.date(from: components) else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date components"]))
            return
        }
        
        components.month! += 1
        components.day! -= 1
        
        guard let endDate = calendar.date(from: components) else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date components"]))
            return
        }
        
        incomeCollection.whereField("date", isGreaterThanOrEqualTo: startDate).whereField("date", isLessThanOrEqualTo: endDate).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(0.0, error)
            } else {
                let totalIncome = querySnapshot?.documents.compactMap { IncomeModel(document: $0)?.amount }.reduce(0, +) ?? 0.0
                completion(totalIncome, nil)
            }
        }
    }

    // Get Monthly Expense
    func getMonthlyExpense(year: Int, month: Int, completion: @escaping (Double, Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let startDate = calendar.date(from: components) else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date components"]))
            return
        }
        
        components.month! += 1
        components.day! -= 1
        
        guard let endDate = calendar.date(from: components) else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date components"]))
            return
        }
        
        expensesCollection.whereField("date", isGreaterThanOrEqualTo: startDate).whereField("date", isLessThanOrEqualTo: endDate).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(0.0, error)
            } else {
                let totalExpense = querySnapshot?.documents.compactMap { ExpenseModel(document: $0)?.amount }.reduce(0, +) ?? 0.0
                completion(totalExpense, nil)
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


