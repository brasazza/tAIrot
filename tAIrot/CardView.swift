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
        GeometryReader { geometry in
            NavigationLink(destination: InputView(card: card)) {
                ZStack {
                    CardBackgroundView(card: card)
                    
                    VStack {
                        Text(card.title)
                            .font(.custom("MuseoModerno", size: 40))
                            .foregroundColor(.white)
                            .padding()
                        
                        Text(card.description)
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        Text(NSLocalizedString("Guess My Future 🔮", comment: ""))
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Color.white.opacity(0.3)
                            )
                            .cornerRadius(60)
                            .shadow(color: Color.white.opacity(0.4), radius: 10, x: -5, y: -5)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 5, y: 5)
                    }
                    .padding(.bottom, geometry.size.height * 0.1)
                    .padding(.top, geometry.size.height * 0.05)
                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.8)
                .cornerRadius(40)
                .padding()
                .padding(.vertical, 10)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
                .padding(.horizontal, UIScreen.main.bounds.width * 0.04)
            }
            .alignmentGuide(VerticalAlignment.center) { dimensions in
                dimensions[VerticalAlignment.center] / 2
            }
        }
    }
}

struct CardBackgroundView: View {
    var card: Card

    var body: some View {
        GeometryReader { geometry in
            card.color
                .overlay(
                    ForEach(0..<6) { _ in // change 9 to 6 to display only 6 emojis
                        CardEmojiView(card: card)
                            .font(.system(size: CGFloat(arc4random_uniform(50) + 50)))  // Random size
                            .opacity(0.3)
                            .rotationEffect(.degrees(Double(Int(arc4random_uniform(50)) - 20)))  // Random rotation
                            .position(x: CGFloat(arc4random_uniform(UInt32(geometry.size.width))),
                                      y: CGFloat(arc4random_uniform(UInt32(geometry.size.height/2))+UInt32(geometry.size.height/2)))
                        // Adjust y position to avoid last 4th of card
                    }
                )
        }
    }
}

struct CardEmojiView: View {
    var card: Card

    var body: some View {
        switch card.type {
        case .love:
            Text("❤️")
        case .finance:
            Text("💵")
        case .relationships:
            Text("🫶")
        case .death:
            Text("💀")
        case .job:
            Text("🧳")
        case .health:
            Text("💊")
        case .education:
            Text("📝")
        }
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(title: NSLocalizedString("Love", comment: ""), description: NSLocalizedString("Seek insight into your romantic relationships and feelings. Love might be just a card away.", comment: ""), color: LinearGradient(gradient: Gradient(colors: [Color.pink, Color.red]), startPoint: .top, endPoint: .bottom), type: .love))
    }
}
