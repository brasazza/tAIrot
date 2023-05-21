//
//  ContentView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme // Retrieves the current color scheme
    
    let cards = [
        Card(title: "Love",
             description: "Seek insight into your romantic relationships and feelings. Love might be just a card away.",
             color: LinearGradient(gradient: Gradient(colors: [Color.pink, Color.red]), startPoint: .top, endPoint: .bottom)),
        Card(title: "Finance",
             description: "Explore your financial status and potential opportunities. Fortune might be just a card away.",
             color: LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .top, endPoint: .bottom)),
        Card(title: "Family",
             description: "Delve into matters of family and relationships. Understanding might be just a card away.",
             color: LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .top, endPoint: .bottom)),
        Card(title: "Death",
             description: "Discover insights into the profound questions of life and mortality. Wisdom might be just a card away.",
             color: LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
    ]

    var shadowColor: Color { // Computed property for the shadow color
        switch colorScheme {
        case .light:
            return Color.black.opacity(0.2)
        case .dark:
            return Color.white.opacity(0.2)
        @unknown default:
            return Color.black.opacity(0.2)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .shadow(color: shadowColor, radius: 6, x: -5, y: -10) // Adjusted shadow
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 100) // Increased vertical padding
            }
            .navigationBarTitle("tAIrot")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

















