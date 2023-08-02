//
//  InputView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import UIKit
import Alamofire
import FirebaseRemoteConfig
import StoreKit

struct InputView: View {
    let card: Card
    @EnvironmentObject var predictionCounter: PredictionCounter
    @EnvironmentObject var iapManager: IAPManager
        var lastPredictionDate: Date {
            get {
                return Date(timeIntervalSince1970: predictionCounter.lastPredictionTimestamp)
            }
            set {
                predictionCounter.lastPredictionTimestamp = newValue.timeIntervalSince1970
            }
        }
    @AppStorage("hasMonthlySubscription") var hasMonthlySubscription: Bool = false
    @AppStorage("hasAnnualSubscription") var hasAnnualSubscription: Bool = false
    @AppStorage("purchasedPredictionCount") var purchasedPredictionCount: Int = 0

    var predictionsLeft: String {
        if hasMonthlySubscription || hasAnnualSubscription {
            return "∞"
        } else {
            return String(max(0, predictionCounter.predictionCount + iapManager.purchasedPredictionCount))
        }
    }

    @State private var isShowingIAPView: Bool = false
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var question: String = ""
    @State private var from: String = ""
    @State private var context: String = ""
    @State private var showResult: Bool = false
    @State private var prediction: (String, Card) = ("", Card(title: "", description: "", color: LinearGradient(gradient: Gradient(colors: []), startPoint: .top, endPoint: .bottom), type: .love))
    @State private var isLoading: Bool = false
    @State private var showMagicDust = false
    @State private var isKeyboardShowing: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @State private var textScaleFactor: CGFloat = 1.0  // Nuevo estado para el factor de escala del texto

    private let openAIService = OpenAIService.shared
    private let remoteConfigService = RemoteConfigService.shared

    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case name, age, from, context, question
    }

    func createPrompt(name: String, age: Int, from: String, context: String, question: String) -> String {
            let promptTemplate = RemoteConfigService.shared.getString(for: "promptTemplate")
            var prompt = promptTemplate
            prompt = prompt.replacingOccurrences(of: "{name}", with: "\(name)")
            prompt = prompt.replacingOccurrences(of: "{age}", with: "\(age)")
            prompt = prompt.replacingOccurrences(of: "{from}", with: "\(from)")
            prompt = prompt.replacingOccurrences(of: "{context}", with: "\(context)")
            prompt = prompt.replacingOccurrences(of: "{card.title}", with: "\(card.title)")
            prompt = prompt.replacingOccurrences(of: "{question}", with: "\(question)")
            return prompt
        }
    
    func makePrediction() {
        print("makePrediction was called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Print the subscription status
            print("Monthly subscription: \(hasMonthlySubscription)")
            print("Annual subscription: \(hasAnnualSubscription)")
            // Your existing code to make a prediction
            print("Button tapped!")
        }
        impactFeedback()
        isLoading = true
        showMagicDust = true
        if name.isEmpty || age.isEmpty || question.isEmpty {
            self.alertMessage = NSLocalizedString("missing_info_message", comment: "")
            self.showAlert = true
            self.isLoading = false
            self.showMagicDust = false
        } else if let ageNumber = Int(age) {
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
                        if !hasMonthlySubscription && !hasAnnualSubscription {
                            if iapManager.purchasedPredictionCount > 0 {
                                iapManager.purchasedPredictionCount -= 1
                                UserDefaults.standard.set(iapManager.purchasedPredictionCount, forKey: "purchasedPredictionCount") // Update UserDefaults
                                print("purchasedPredictionCount after decrement: \(iapManager.purchasedPredictionCount)")
                            } else if predictionCounter.predictionCount > 0 {
                                predictionCounter.predictionCount -= 1
                                UserDefaults.standard.set(predictionCounter.predictionCount, forKey: "predictionCount") // Update UserDefaults
                                print("Prediction count after decrement: \(predictionCounter.predictionCount)")
                                self.predictionCounter.lastPredictionTimestamp = Date().timeIntervalSince1970
                                UserDefaults.standard.set(self.predictionCounter.lastPredictionTimestamp, forKey: "lastPredictionTimestamp") // Update UserDefaults
                            }
                        }
                        // Generate a random number between 1 and 5
                        let randomNumber = Int.random(in: 1...5)

                        // If the random number is 1, request a review
                        if randomNumber == 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) { // Wait 10 more seconds before requesting a review
                                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                }
                            }
                        }
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
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 12) {
                    TextField(NSLocalizedString("Name", comment: ""), text: $name)
                        .focused($focusedField, equals: .name)
                        .onSubmit {
                            focusedField = .age
                        }
                        .onChange(of: name) { newValue in
                            // Remover espacios en blanco del texto
                            name = newValue.trimmingCharacters(in: .whitespaces)
                        }
                        .font(.system(size: 18))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                        )

                    TextField(NSLocalizedString("Age", comment: ""), text: $age)
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
                    
                    TextField(NSLocalizedString("Where do you live?", comment: ""), text: $from)
                        .focused($focusedField, equals: .from)
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

                    TextField(NSLocalizedString("What do you want to know?", comment: ""), text: $question)
                        .focused($focusedField, equals: .question)
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
                    
                    TextField(NSLocalizedString("Any context needed? If not, leave blank.", comment: ""), text: $context)
                        .focused($focusedField, equals: .context)
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
                        let currentMonth = Calendar.current.component(.month, from: Date())
                        let lastPredictionMonth = Calendar.current.component(.month, from: lastPredictionDate)
                        if currentMonth != lastPredictionMonth && !hasMonthlySubscription && !hasAnnualSubscription {
                            predictionCounter.predictionCount = 3
                            self.predictionCounter.lastPredictionTimestamp = Date().timeIntervalSince1970
                        }
                        // Check if the user has an active subscription or available predictions
                        if hasMonthlySubscription || hasAnnualSubscription || iapManager.purchasedPredictionCount > 0 || predictionCounter.predictionCount > 0 {
                            // The user can make a prediction
                            makePrediction()
                        } else {
                            // The user needs to purchase more predictions
                            // Show the IAPView
                            print("purchasedPredictionCount in IAPManager: \(iapManager.purchasedPredictionCount)")
                            print("predictionsLeft in InputView: \(predictionsLeft)")
                            print("Attempting to show IAPView")
                                    isShowingIAPView = true
                                }
                        hideKeyboard()
                        }) {
                            
                        var gradientColors: [Color] {
                            if colorScheme == .dark {
                                // Dark theme colors
                                return [
                                    Color.purple.opacity(1),
                                    Color.purple.opacity(0.6),
                                    Color.purple.opacity(0.3)
                                ]
                            } else {
                                // Light theme colors
                                return [
                                    Color(red: 50/255, green: 6/255, blue: 71/255).opacity(0.7),
                                    Color(red: 150/255, green: 15/255, blue: 255/255).opacity(0.7),
                                    Color(red: 148/255, green: 62/255, blue: 244/255).opacity(0.7),
                                    Color(red: 150/255, green: 15/255, blue: 255/255).opacity(0.7),
                                    Color(red: 50/255, green: 6/255, blue: 71/255).opacity(0.7)
                                ]
                            }
                        }
            
                        Text(isLoading ? NSLocalizedString("Revealing...🔮", comment: "") : NSLocalizedString("🔮 Reveal 🔮", comment: ""))
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: gradientColors),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(radius: 8)
                                    .cornerRadius(40)
                            }
                            .animation(.easeInOut, value: predictionCounter.predictionCount)
                            .disabled(isLoading)
                            .padding(.top, 50)
                            .shadow(color: colorScheme == .dark ? Color.purple.opacity(0.4) : Color.purple.opacity(1), radius: 20)

                            }
                            .padding()
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    VStack {
                                        Text(NSLocalizedString("Enter your details", comment: ""))
                                            .font(.custom("MuseoModerno", size: 30))
                                            .font(.headline)
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 114/255, green: 39/255, blue: 165/255))
                                            .shadow(color: colorScheme == .dark ? Color.purple.opacity(0.9) : Color.black.opacity(0.6), radius: 10, x: 0, y: 2)
                                            .scaleEffect(textScaleFactor)  // Aplicar el factor de escala al texto
                                            .padding()
                                        if isKeyboardShowing {
                                            Spacer(minLength: 80)
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
                .onAppear {
                    // Load the saved count from UserDefaults
                    predictionCounter.predictionCount = UserDefaults.standard.integer(forKey: "predictionCount")

                    // Check if it's the user's first time using the app
                    if UserDefaults.standard.object(forKey: "hasLaunchedBefore") == nil {
                        print("First time using the app, setting predictionCount to 3")
                        predictionCounter.predictionCount = 3
                        UserDefaults.standard.setValue(true, forKey: "hasLaunchedBefore")
                    }
                    
                    // Save the updated count to UserDefaults
                    UserDefaults.standard.set(predictionCounter.predictionCount, forKey: "predictionCount")
                    UserDefaults.standard.synchronize()

                    iapManager.onSinglePredictionPurchased = { [self] in
                        print("Single prediction purchased, increasing purchasedPredictionCount")
                        iapManager.purchasedPredictionCount += 1
                    }
                }

                .sheet(isPresented: $isShowingIAPView) {
                    IAPView(isShowingIAPView: self.$isShowingIAPView)
                        .environmentObject(self.iapManager)
                }
            }
            .sheet(isPresented: $showResult) {
                if #available(iOS 16.0, *) {
                    ResultView(prediction: prediction.0, card: prediction.1, name: name, question: question, showResult: $showResult)
                } else {
                    // Fallback on earlier versions
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(NSLocalizedString("missing_info_title", comment: "")),
                      message: Text(alertMessage),
                      dismissButton: .default(Text(NSLocalizedString("ok_button", comment: ""))))
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
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = true
                    textScaleFactor = 0  // Hacer que el texto sea más pequeño cuando el teclado está visible
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = false
                    textScaleFactor = 1.0  // Restablecer el tamaño del texto cuando el teclado se oculta
                }
            }
            .onTapGesture(count: 2) {
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

func impactFeedback() {
       let generator = UIImpactFeedbackGenerator(style: .medium)
       generator.impactOccurred()
   }

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif



