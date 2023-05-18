//
//  ResultView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct ResultView: View {
    var prediction: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Your Future Prediction")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(prediction)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                // This action will dismiss the ResultView
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Text("Done")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(prediction: "You will have a great future!")
    }
}

