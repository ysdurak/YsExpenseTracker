//
//  DataController.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 19.04.2024.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "ExpenseData")
    
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Data Error \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            // Handle errors in our database
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addExpense(category: String, date : Date, note: String, value: Double, context: NSManagedObjectContext) {
        let expense = Expense(context: context)
        expense.category = category
        expense.id = UUID()
        expense.date = date
        expense.note = note
        expense.value = value
        
        save(context: context)
    }
    
    func editFood(expense: Expense, category: String, date : Date, note: String, value: Double, context: NSManagedObjectContext) {
        expense.category = category
        expense.id = UUID()
        expense.date = date
        expense.note = note
        expense.value = value
        
        save(context: context)
    }
}

