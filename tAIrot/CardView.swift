//
//  CardView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 19/05/23.
//

import SwiftUI

struct CardView: View {
    var card: Card
    
    var body: some View {
        NavigationLink(destination: InputView(card: card)) {
            ZStack {
                CardBackgroundView(card: card)
                
                VStack {
                    Text(card.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    
                    Text(card.description)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    Text("Guess My Future 🔮")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(60)
                }
                .padding(.bottom, 50)
            }
            .frame(width: 300, height: 650)
            .cornerRadius(40)
            .padding()
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10) // Add shadow here
        }
    }
}

struct CardBackgroundView: View {
    var card: Card

    var body: some View {
        GeometryReader { geometry in
            card.color
                .overlay(
                    ForEach(0..<9) { _ in
                        CardEmojiView(card: card)
                            .font(.system(size: CGFloat(arc4random_uniform(50) + 50)))  // Random size
                            .opacity(0.3)
                            .rotationEffect(.degrees(Double(Int(arc4random_uniform(45)) - 20)))  // Random rotation
                            .position(x: CGFloat(arc4random_uniform(UInt32(geometry.size.width))),
                                      y: CGFloat(arc4random_uniform(UInt32(geometry.size.height*2/3))+UInt32(geometry.size.height/3)))
                    }
                )
        }
    }
}

struct CardEmojiView: View {
    var card: Card

    var body: some View {
        if card.title == "Love" {
            Text("❤️")
        } else if card.title == "Finance" {
            Text("💵")
        } else if card.title == "Family" {
            Text("👨‍👩‍👦")
        } else if card.title == "Death" {
            Text("💀")
        } else {
            Text("")
        }
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(title: "Love", description: "Seek insight into your romantic relationships and feelings. Love might be just a card away.", color: LinearGradient(gradient: Gradient(colors: [Color.pink, Color.red]), startPoint: .top, endPoint: .bottom)))
    }
}





















