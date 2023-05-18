//
//  ContentView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    Text("Love View")
                    NavigationLink(destination: InputView(aspect: "love")) {
                        Text("Get Prediction")
                    }
                }
                .navigationBarTitle("Love")
            }
            .tabItem {
                Label("Love", systemImage: "heart")
            }

            NavigationView {
                VStack {
                    Text("Finance View")
                    NavigationLink(destination: InputView(aspect: "finance")) {
                        Text("Get Prediction")
                    }
                }
                .navigationBarTitle("Finance")
            }
            .tabItem {
                Label("Finance", systemImage: "dollarsign.circle")
            }

            NavigationView {
                VStack {
                    Text("Family View")
                    NavigationLink(destination: InputView(aspect: "family")) {
                        Text("Get Prediction")
                    }
                }
                .navigationBarTitle("Family")
            }
            .tabItem {
                Label("Family", systemImage: "person.3")
            }

            NavigationView {
                VStack {
                    Text("Death View")
                    NavigationLink(destination: InputView(aspect: "death")) {
                        Text("Get Prediction")
                    }
                }
                .navigationBarTitle("Death")
            }
            .tabItem {
                Label("Death", systemImage: "xmark.circle")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}










