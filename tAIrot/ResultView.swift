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
    let name: String
    let question: String

    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                card.color // Use card's color here
                .cornerRadius(50)
                .padding()
                .shadow(radius: 5)
                
                VStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text("\(name)'s Future 🔮")
                            .font(.title) // Larger font size
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("\"\(question)\"")
                            .font(.title3) // increased font size
                            .italic()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 20)

                    VStack {
                        Spacer()
                        Text(prediction)
                            .font(.title2) // Increase font size
                            .foregroundColor(.white) // Make the text white
                            .multilineTextAlignment(.center) // Align text to center
                        Spacer()
                    }
                }
                .padding(50) // Add padding around the text
            }
            
            HStack(spacing: 50) {
                            Button(action: {}) {
                                Text("💾")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(red: 191/255, green: 101/255, blue: 197/255)) // Use RGB values
                                    .cornerRadius(60)
                            }

                            Button(action: {}) {
                                Text("Share")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(red: 191/255, green: 101/255, blue: 197/255)) // Use RGB values
                                    .cornerRadius(60)
                            }

                            Button(action: {}) {
                                Text("Done")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(red: 191/255, green: 101/255, blue: 197/255)) // Use RGB values
                                    .cornerRadius(60)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .background(Color.gray.opacity(0.2))
                    .edgesIgnoringSafeArea(.all)
                }
            }
















