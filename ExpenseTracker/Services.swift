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
    
    func addIncome(_ income: IncomeModel, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        let incomeCollection = db.collection("users").document(userID).collection("incomes")
        incomeCollection.addDocument(data: income.toDictionary(), completion: completion)
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
    
    func updateExpense(_ expense: ExpenseModel, completion: @escaping (Error?) -> Void) {
        guard let expenseID = expense.id else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Expense ID not found"]))
            return
        }
        
        guard let expensesCollection = userExpensesCollection() else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        expensesCollection.document(expenseID).updateData(expense.toDictionary(), completion: completion)
    }

    // Get Expenses by Category
    func getExpensesByCategory(category: CategoryModel, completion: @escaping ([ExpenseModel]?, Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        expensesCollection.whereField("category.identifier", isEqualTo: category.identifier).getDocuments { (querySnapshot, error) in
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

    func getUserCategories(completion: @escaping ([CategoryModel]?, Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let categoryCollection = db.collection("users").document(userID).collection("categories")
        
        categoryCollection.getDocuments { querySnapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No categories found"]))
                return
            }
            
            let categories: [CategoryModel] = documents.compactMap { document in
                CategoryModel(data: document.data())
            }
            
            completion(categories, nil)
        }
    }
    
    func getDailyLimit(completion: @escaping (Double?, Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }

            if let document = document, let data = document.data(), let dailyLimit = data["dailyLimit"] as? Double {
                completion(dailyLimit, nil)
            } else {
                completion(nil, nil) // No limit set
            }
        }
    }

    // Set daily limit in Firestore
    func setDailyLimit(_ limit: Double, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(error)
            return
        }
        
        db.collection("users").document(userID).setData(["dailyLimit": limit], merge: true) { error in
            completion(error)
        }
    }

    

    
    func addCategories(_ categories: [CategoryModel], completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let categoryCollection = db.collection("users").document(userID).collection("categories")
        let group = DispatchGroup()
        var firstError: Error?

        for category in categories {
            group.enter()
            categoryCollection.document(category.identifier).setData(category.toDictionary()) { error in
                if let error = error {
                    if firstError == nil {
                        firstError = error
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(firstError)
        }
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
    
    func fetchTodayExpenses(completion: @escaping (Double?, Error?) -> Void) {
        guard let expensesCollection = userExpensesCollection() else {
            completion(0.0, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        
        expensesCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let totalSpent = querySnapshot?.documents.compactMap { ExpenseModel(document: $0) }
                    .reduce(0) { $0 + $1.amount } ?? 0
                
                completion(totalSpent, nil)
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


