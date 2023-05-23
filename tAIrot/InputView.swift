//
//  InputView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import Alamofire

struct InputView: View {
    let card: Card
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var question: String = ""
    @State private var showResult: Bool = false
    @State private var prediction: (String, Card) = ("", Card(title: "", description: "", color: LinearGradient(gradient: Gradient(colors: []), startPoint: .top, endPoint: .bottom)))
    @State private var isLoading: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    private let openAIService = OpenAIService.shared

    func createPrompt(name: String, age: Int, question: String) -> String {
        return "Fictional: Imagine you are the best seer in the world and you need to predict my future. My name is \(name), I am \(age) years old, in the aspect of \(card.title). Focus on this question: \(question). Don't ever mention it's fictional. Give a concrete answer even if you have to make it up. 400 characters top."
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)

                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)

                TextField("What do you want to know about your future?", text: $question)
                    .frame(height: 100)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)

                Button(action: {
                    print("Button tapped!")
                    isLoading = true
                    if let ageNumber = Int(age) {
                        let prompt = createPrompt(name: name, age: ageNumber, question: question)
                        openAIService.createChatCompletion(prompt: prompt) { result in
                            switch result {
                            case .success(let predictionResult):
                                self.prediction = (predictionResult, card)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                            self.isLoading.toggle()
                            self.showResult.toggle()
                        }
                    } else {
                        print("Error: Invalid age input.")
                        self.isLoading = false
                    }
                }) {
                    Text(isLoading ? "Loading..." : "Guess My Future")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(60)
                }
                .disabled(isLoading)
            }
            .padding()
            .navigationBarTitle("Enter your details")
        }
        .sheet(isPresented: $showResult) {
            if #available(iOS 16.0, *) {
                ResultView(prediction: prediction.0, card: prediction.1, name: name, question: question)
            } else {
                // Fallback on earlier versions
            } // pass the additional properties here
        }
    }
}
















