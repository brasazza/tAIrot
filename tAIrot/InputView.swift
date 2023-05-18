//
//  InputView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import Alamofire

struct InputView: View {
    let aspect: String
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var showResult: Bool = false
    @State private var prediction: String = ""
    @State private var isLoading: Bool = false  // Add this
    @Environment(\.presentationMode) var presentationMode
    
    private let openAIService = OpenAIService.shared

    func createPrompt(name: String, age: Int, aspect: String) -> String {
        return "Imagine you are a seer and you need to predict my future. My name is  \(name), I am \(age) years old, in the aspect of \(aspect)."
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Button(action: {
                    print("Button tapped!")
                    isLoading = true
                    if let ageNumber = Int(age) {
                        let prompt = createPrompt(name: name, age: ageNumber, aspect: aspect)
                        openAIService.createChatCompletion(prompt: prompt) { result in
                            switch result {
                            case .success(let prediction):
                                self.prediction = prediction
                            case .failure(let error):
                                // handle error here
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
                    Text(isLoading ? "Loading..." : "Get Prediction")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isLoading)

            }
            .padding()
            .navigationBarTitle("Enter your details")
        }
        .sheet(isPresented: $showResult) {
            ResultView(prediction: prediction)
        }
    }
}












