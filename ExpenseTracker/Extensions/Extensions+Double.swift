//
//  Extensions+Double.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 4.08.2024.
//

import Foundation



extension Double {
    func toReadableString() -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(self))
        } else {
            return String(self)
        }
    }
}
