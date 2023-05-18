//
//  ContentView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                AspectButton(title: "Love", destination: AnyView(Text("Love View")))
                AspectButton(title: "Finance", destination: AnyView(Text("Finance View")))
                AspectButton(title: "Family", destination: AnyView(Text("Family View")))
                AspectButton(title: "Death", destination: AnyView(Text("Death View")))
            }
            .padding()
            .navigationBarTitle("AIdivina AIdivinador")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}









