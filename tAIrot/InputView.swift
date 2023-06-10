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
    @State private var from: String = ""
    @State private var context: String = ""
    @State private var showResult: Bool = false
    @State private var prediction: (String, Card) = ("", Card(title: "", description: "", color: LinearGradient(gradient: Gradient(colors: []), startPoint: .top, endPoint: .bottom)))
    @State private var isLoading: Bool = false
    @State private var showMagicDust = false
    @State private var isKeyboardShowing: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    private let openAIService = OpenAIService.shared

    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case name, age, from, context, question
    }

    func createPrompt(name: String, age: Int, from: String, context: String, question: String) -> String {
        return "Fictional: Imagine you are Nostradamus. My name is \(name), I am \(age)years old, I am from \(from), context about me: \(context) in the aspect of \(card.title). Focus on this question: \(question). Don't ever mention it's fictional. Don't mention your name. Be specific with details and give a concrete answer. Give me fear or joy, surprise me. 400 characters top."
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 20) {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .onSubmit {
                            focusedField = .age
                        }
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                        )

                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .age)
                        .onSubmit {
                            focusedField = .from
                        }
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                        )
                    
                    TextField("Where are you from?", text: $from)
                        .focused($focusedField, equals: .from)
                        .onSubmit {
                            focusedField = .context
                        }
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                        )

                    TextField("Any context needed? If not, leave blank.", text: $context)
                        .focused($focusedField, equals: .context)
                        .onSubmit {
                            focusedField = .question
                        }
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                        )

                    TextField("What do you want to know about your future?", text: $question)
                        .focused($focusedField, equals: .question)
                        .onSubmit {
                            focusedField = nil
                        }
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                        )

                    Button(action: {
                        print("Button tapped!")
                        isLoading = true
                        showMagicDust = true
                        if let ageNumber = Int(age) {
                            let prompt = createPrompt(name: name, age: ageNumber, from: from, context: context, question: question)
                            openAIService.createChatCompletion(prompt: prompt)
                            { result in
                                switch result {
                                case .success(let predictionResult):
                                    self.prediction = (predictionResult, card)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        self.isLoading = false
                                        self.showMagicDust = false
                                        self.showResult.toggle()
                                    }
                                case .failure(let error):
                                    print(error.localizedDescription)
                                    self.isLoading = false
                                    self.showMagicDust = false
                                }
                            }
                        } else {
                            print("Error: Invalid age input.")
                            self.isLoading = false
                        }
                    }) {
                        Text(isLoading ? "Predicting...🔮" : "Guess My Future 🔮")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 250)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(60)
                    }
                    .disabled(isLoading)
                    .padding(.top, 60)

                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Enter your details")
                                .font(.custom("MuseoModerno", size: 30))
                                .font(.headline)
                                .padding(.top, 120)
                            if isKeyboardShowing {
                                Spacer(minLength: 170)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                .frame(height: 70)
                .background(
                    Group {
                        if colorScheme == .dark {
                            Image("blackbg")
                                .resizable()
                                .scaledToFill()
                                .edgesIgnoringSafeArea(.all)
                        } else {
                            Image("whitebg")
                                .resizable()
                                .scaledToFill()
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                )
            }
            .sheet(isPresented: $showResult) {
                if #available(iOS 16.0, *) {
                    ResultView(prediction: prediction.0, card: prediction.1, name: name, question: question, showResult: $showResult)
                } else {
                    // Fallback on earlier versions
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = false
                }
            }
            .onTapGesture {
                self.isKeyboardShowing = false
                hideKeyboard()
            }

            if showMagicDust {
                MagicDustView()
            }
        }
    }
}

struct MagicDustView: View {
    @State private var animateIn = false
    @State private var animateOut = false

    var body: some View {
        ZStack {
            ForEach(0..<500) { _ in
                Circle()
                    .frame(width: CGFloat.random(in: 5...30), height: CGFloat.random(in: 5...30))
                    .foregroundColor(Color.purple.opacity(Double.random(in: 0.2...0.7)))
                    .offsetIn(radius: UIScreen.main.bounds.width * (self.animateIn ? 0.1 : 2.0))
                    .offsetOut(radius: UIScreen.main.bounds.width * (self.animateOut ? 2.0 : 0.1))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2).repeatForever().speed(Double.random(in: 0.2...0.5))) {
                animateIn = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever().speed(Double.random(in: 0.2...0.5))) {
                    animateOut = true
                }
            }
        }
    }
}

extension View {
    func offsetIn(radius: CGFloat) -> some View {
        let angle = Double.random(in: 0..<(2 * .pi))
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return self.offset(x: x, y: y)
    }

    func offsetOut(radius: CGFloat) -> some View {
        let angle = Double.random(in: 0..<(2 * .pi))
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return self.offset(x: x, y: y)
    }
}


#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
