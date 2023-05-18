//
//  AspectButton.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct AspectButton: View {
    let title: String
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct AspectButton_Previews: PreviewProvider {
    static var previews: some View {
        AspectButton(title: "Love", destination: AnyView(Text("Love View")))
    }
}
