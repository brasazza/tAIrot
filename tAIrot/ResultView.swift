//
//  ResultView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct ResultView: View {
    let prediction: String
    let card: Card

    var body: some View {
        VStack {
            Spacer()
            Text("Your Future")
                .font(.largeTitle)
                .bold()
                .padding()
            
            ZStack {
                card.color // Use card's color here
                .cornerRadius(50)
                .padding()
                .shadow(radius: 5)
                
                Text(prediction)
                    .font(.title2) // Increase font size
                    .padding() // Add padding around the text
                    .multilineTextAlignment(.center) // Align text to center
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .background(Color.gray.opacity(0.2))
        .edgesIgnoringSafeArea(.all)
    }
}





