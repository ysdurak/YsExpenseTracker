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

    private var selectedIndex: Int {
        Tab.allCases.firstIndex(of: currentTab) ?? 0
    }

    var body: some View {
        GeometryReader { proxy in
            let itemWidth = proxy.size.width / CGFloat(Tab.allCases.count)
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    tabButton(tab)
                        .frame(width: itemWidth)
                }
            }
            .frame(maxHeight: .infinity)
            .background {
                Color.tabBarBackground
                    .clipShape(BottomCurve(currentXValue: itemWidth * (CGFloat(selectedIndex) + 0.5)))
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: -5)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .frame(height: 64)
        .animation(.snappy(duration: 0.35), value: currentTab)
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = currentTab == tab
        Button {
            currentTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .gray)
                    .frame(width: isSelected ? 54 : 30, height: isSelected ? 54 : 30)
                    .background {
                        if isSelected {
                            Circle()
                                .fill(Color.brand)
                                .shadow(color: Color.brand.opacity(0.35), radius: 8, x: 0, y: 4)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                    .offset(y: isSelected ? -26 : 0)

                Text(tab.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .opacity(isSelected ? 1 : 0)
                    .offset(y: isSelected ? -18 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: Tabs
enum Tab: String, CaseIterable {
    case home
    case cart
    case addSomething
    case profile

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .cart: "list.bullet.rectangle.fill"
        case .addSomething: "plus"
        case .profile: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Özet"
        case .cart: "Harcamalar"
        case .addSomething: "Ekle"
        case .profile: "Profil"
        }
    }
}

// Tab Bar Curve...
struct BottomCurve: Shape {

    var currentXValue: CGFloat

    // Animating Path...
    var animatableData: CGFloat {
        get { currentXValue }
        set { currentXValue = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
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
