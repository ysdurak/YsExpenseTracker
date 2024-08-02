//
//  CustomTabBar.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//
import Foundation

import SwiftUI

struct CustomTabBar: View {
    @Binding var currentTab: Tab
    var animation: Namespace.ID
    // Current Tab XValue...
    @State var currentXValue: CGFloat = 0
    var body: some View {
        HStack(spacing: 0){
            ForEach(Tab.allCases,id: \.rawValue){tab in
                TabButton(tab: tab)
                    .overlay {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.black)
                            .offset(y: currentTab == tab ? 15 : 100)
                    }
            }
        }
        .padding(.top)
        .padding(.bottom,getSafeArea().bottom == 0 ? 15 : 10)
        
        .background{
            Color.black
                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: -5)
                .clipShape(BottomCurve(currentXValue: currentXValue))
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    // TabButton...
    @ViewBuilder
    func TabButton(tab: Tab)->some View{
        // Since we need XAxis Value for Curve...
        GeometryReader{proxy in
            Button {
                withAnimation(.easeInOut){
                    currentTab = tab
                    // updating Value...
                    currentXValue = proxy.frame(in: .global).midX
                }
                
            } label: {
                // Moving Button up for current Tab...
                Image(systemName: tab.rawValue)
                // Since we need perfect value for Curve...
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(currentTab == tab ? .white : .gray.opacity(0.8))
                    .padding(currentTab == tab ? 15 : 0)
                    .background(
                        ZStack{
                            if currentTab == tab{
                                Circle()
                                    .fill(Color.orange)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 5, y: 5)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .offset(y: currentTab == tab ? -50 : 0)
            }
            // Setting intial Curve Position...
            .onAppear {
                
                if tab == Tab.allCases.first && currentXValue == 0{
                    
                    currentXValue = proxy.frame(in: .global).midX
                }
            }
        }
        .frame(height: 30)
    }
}

// MARK: Tabs
enum Tab: String,CaseIterable{
    case home = "house"
    case cart = "menucard"
    case add = "plus.circle"
    case favourite = "star"
    case profile = "person.circle"
}

// Getting Safe Area...
extension View{
    func getSafeArea()->UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else{
            return .zero
        }
        
        return safeArea
    }
}


// Tab Bar Curve...
struct BottomCurve: Shape {

    var currentXValue: CGFloat
    
    // Animating Path...
    // it wont work on previews....
    var animatableData: CGFloat{
        get{currentXValue}
        set{currentXValue = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
            // mid will be current XValue..
            let mid = currentXValue
            path.move(to: CGPoint(x: mid - 50, y: 0))
            
            let to1 = CGPoint(x: mid, y: 35)
            let control1 = CGPoint(x: mid - 25, y: 0)
            let control2 = CGPoint(x: mid - 25, y: 35)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            
            let to2 = CGPoint(x: mid + 50, y: 0)
            let control3 = CGPoint(x: mid + 25, y: 35)
            let control4 = CGPoint(x: mid + 25, y: 0)
            
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}

