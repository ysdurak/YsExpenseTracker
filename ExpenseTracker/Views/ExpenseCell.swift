//
//  ExpenseCell.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 19.04.2024.
//

import Foundation
import SwiftUI

struct ExpenseCell: View {
    var imageName: String
    var category: String
    var amount: String
    var body: some View{
        ZStack{
            HStack{
                Image(systemName: getImage(categoryName: category))
                    .frame(width: 32, height: 32)
                Text(category)
                    .customFont(.medium)
                Spacer()
                Text(amount +  " TL")
                    .customFont(.medium)
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle())
        }
    }
}

struct ExpenseSummary: View {
    var imageName: String
    var imageColor: Color
    var title: String
    var valueText: String
    var bgColor: Color
    var body: some View {
        ZStack{
            HStack{
                Image(systemName: imageName)    
                    .frame(width: 36,height: 36)
                    .foregroundStyle(imageColor)
                Spacer()
                    .frame(width: 20)
                VStack{
                    Text(title)
                        .customFont(.light)
                    Text(valueText)
                        .customFont(.medium)
                    
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle())
                .background(bgColor.cornerRadius(10))
        }
    }
}

struct RecentExpensesCell: View {
    
    var date: Date 
    var category: CategoryModel
    var note: String
    var value: Double
    
    var body: some View {
        ZStack{
            HStack{
                VStack{
                    Text(date.dayOfMonth())
                        .customFont(.light, 24)
                        .foregroundStyle(.black.opacity(0.8))
                    Text(date.monthAndYear())
                        .customFont(.extraLight, 12)
                        .foregroundStyle(.black.opacity(0.8))
                    Text(date.timeOfDay())
                        .customFont(.extraLight,12)
                        .foregroundStyle(.black.opacity(0.8))
                }
                
                Spacer()
                    .frame(width: 10)
                
                VStack{
                    HStack{
                        Image(systemName: getImage(categoryName: category.identifier))
                        Text(category.title)
                            .customFont(.regular, 16)
                        Spacer()
                    }
                    HStack{
                        Text(note)
                            .customFont(.light, 12)
                        Spacer()
                    }
                    
                    Spacer()
                    
                }
                Spacer()
                Text("\(Int(value)) ₺")
                    .customFont(.semiBold, 16)
            }
            .padding(10)
        }
        .background(Color.white.cornerRadius(10))
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle())
        }
    }
    

}

func getImage(categoryName: String) -> String! {
    switch categoryName {
    case "technology":
        return "laptopcomputer"
    case "food":
        return "fork.knife.circle"
    case "market":
        return "cart.fill"
    case "game":
        return "gamecontroller"
    default:
        return "dollarsign.circle"
    }
}
