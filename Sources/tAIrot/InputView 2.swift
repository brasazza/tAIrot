//
//  InputView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI

struct InputView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var showResult: Bool = false
    @State private var prediction: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    func createPrompt(name: String, age: Int, aspect: String) -> String {
        // Combine the inputs to create a prompt for the OpenAI API.
        // You can customize the prompt format as needed.
        return "Predict the future of \(name), who is \(age) years old, in the aspect of \(aspect)."
    }

    func fetchPrediction(prompt: String, completion: @escaping (String) -> Void) {
        // Here, you should call the OpenAI API with the generated prompt to get the prediction.
        // This is just a placeholder example. Replace it with the actual API call and parsing logic.
        let examplePrediction = "You will have a great future!"
        completion(examplePrediction)
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
                    if let ageNumber = Int(age) {
                        let prompt = createPrompt(name: name, age: ageNumber, aspect: "love")
                        fetchPrediction(prompt: prompt) { result in
                            DispatchQueue.main.async {
                                self.prediction = result
                                self.showResult = true
                            }
                        }
                    } else {
                        print("Error: Invalid age input.")
                    }
                }) {
                    Text("Get Prediction")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

            }
            .padding()
            .navigationBarTitle("Enter your details")
        }
        .sheet(isPresented: $showResult) {
            ResultView(prediction: prediction)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}








