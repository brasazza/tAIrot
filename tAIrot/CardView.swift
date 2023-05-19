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
        NavigationLink(destination: InputView(aspect: card.title)) {
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
                
                Text("Guess My Future")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(60)
            }
                    .padding(.bottom, 50)
            .frame(width: 300, height: 650)
            .background(card.color)
            .cornerRadius(40)
            .padding()
            .shadow(radius: 5)
        }
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(title: "Love", description: "Seek insight into your romantic relationships and feelings. Love might be just a card away.", color: LinearGradient(gradient: Gradient(colors: [Color.pink, Color.red]), startPoint: .top, endPoint: .bottom)))
    }
}



