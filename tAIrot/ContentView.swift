//
//  ContentView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import UIKit

struct IntroView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    @State private var showText = false
    @State private var moveImageUp = false
    @State private var hideElements = false
    @State private var goToMainView = false
    @State private var showMainView = false
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "000000"), location: 0),
                            .init(color: Color(hex: "24003c"), location: 0.4),
                            .init(color: Color(hex: "24003c"), location: 0.6),
                            .init(color: Color(hex: "000000"), location: 1)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 900
                    )
                    .edgesIgnoringSafeArea(.all)
                } else {
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "000000"), location: 0),
                            .init(color: Color(hex: "24003c"), location: 0.4),
                            .init(color: Color(hex: "24003c"), location: 0.6),
                            .init(color: Color(hex: "000000"), location: 1)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 900
                    )
                    .edgesIgnoringSafeArea(.all)
                }

            VStack {
                Spacer()

                Image("wizard4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 110, height: 110)
                    .scaleEffect(isAnimating ? 5 : 1)
                    .offset(y: moveImageUp ? -55 : 0)
                    .opacity(hideElements ? 0 : 1)
                    .animation(.easeInOut(duration: 1), value: isAnimating)
                
                
                VStack {
                    Text(NSLocalizedString("The Seer", comment: ""))
                        .font(.custom("MuseoModerno", size: 40))
                        .foregroundColor(colorScheme == .dark ? .white : .white)
                        .shadow(color: Color.white, radius: 10, x: 0, y: 0)
                        .opacity(showText && !hideElements ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6), value: showText)
                        .padding(.bottom, -44)

                }

                Spacer()
            }
            
            .opacity(goToMainView ? 0 : 2)
            .animation(.easeInOut(duration: 0.7), value: goToMainView)
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))

            if showMainView {
                MainView()
                    .environmentObject(IAPManager.shared)
                    .environmentObject(PredictionCounter.shared)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 1)) {
                    moveImageUp = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 1)) {
                    showText = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 1)) {
                    goToMainView = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation(.easeInOut(duration: 2)) {
                    showMainView = true
                }
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var iapManager: IAPManager
    @StateObject private var predictionCounter = PredictionCounter.shared
    @AppStorage("hasMonthlySubscription") var hasMonthlySubscription: Bool = false
    @AppStorage("hasAnnualSubscription") var hasAnnualSubscription: Bool = false
    
    var predictionsLeft: String {
        if hasMonthlySubscription || hasAnnualSubscription {
            return "∞"
        } else {
            return String(max(0, predictionCounter.predictionCount + iapManager.purchasedPredictionCount))
        }
    }
    
    @State private var isShowingIAPView = false
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingMenu = false
    @State private var iconRotation: Double = 0 // Declare iconRotation here
    @State private var isMenuButtonBouncing = false
    
    let cards = [
            Card(
                title: NSLocalizedString("card_title_personal", comment: ""),
                description: NSLocalizedString("card_description_personal", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 53/255, green: 18/255, blue: 102/255), Color(red: 182/255, green: 132/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom),
                type: .personal
            ),
            Card(
                title: NSLocalizedString("card_title_love", comment: ""),
                description: NSLocalizedString("card_description_love", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 103/255, green: 7/255, blue: 9/255), Color(red: 253/255, green: 0/255, blue: 12/255)]), startPoint: .top, endPoint: .bottom),
                type: .love
            ),
            Card(
                title: NSLocalizedString("card_title_finance", comment: ""),
                description: NSLocalizedString("card_description_finance", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 43/255, green: 161/255, blue: 73/255), Color(red: 242/255, green: 204/255, blue: 27/255)]), startPoint: .top, endPoint: .bottom),
                type: .finance
            ),
            Card(
                title: NSLocalizedString("card_title_relationships", comment: ""),
                description: NSLocalizedString("card_description_relationships", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 224/255, green: 131/255, blue: 15/255), Color(red: 255/255, green: 204/255, blue: 3/255)]), startPoint: .top, endPoint: .bottom),
                type: .relationships
            ),
            Card(
                title: NSLocalizedString("card_title_health", comment: ""),
                description: NSLocalizedString("card_description_health", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 0/255, blue: 128/255), Color(red: 173/255, green: 216/255, blue: 230/255)]), startPoint: .top, endPoint: .bottom),
                type: .health
            ),
            Card(
                title: NSLocalizedString("card_title_job", comment: ""),
                description: NSLocalizedString("card_description_job", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 54/255, green: 32/255, blue: 14/255), Color(red: 188/255, green: 131/255, blue: 66/255)]), startPoint: .top, endPoint: .bottom),
                type: .job
            ),
            Card(
                title: NSLocalizedString("card_title_education", comment: ""),
                description: NSLocalizedString("card_description_education", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 30/255, green: 144/255, blue: 255/255), Color(red: 240/255, green: 248/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom),
                type: .education
            ),
            Card(
                title: NSLocalizedString("card_title_death", comment: ""),
                description: NSLocalizedString("card_description_death", comment: ""),
                color: LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 0/255, blue: 0/255), Color(red: 147/255, green: 147/255, blue: 155/255)]), startPoint: .top, endPoint: .bottom),
                type: .death
            )
        ]
    
    var shadowColor: Color {
        switch colorScheme {
        case .light:
            return Color.black.opacity(0.15)
        case .dark:
            return Color.white.opacity(0.1)
        @unknown default:
            return Color.black.opacity(0.2)
        }
    }
    
    var body: some View {
        ZStack {
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
            
            GeometryReader { outerGeometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: outerGeometry.size.width / 10) {
                        ForEach(cards) { card in
                            GeometryReader { innerGeometry in
                                CardView(card: card)
                                    .environmentObject(predictionCounter)
                                    .rotation3DEffect(
                                        Angle(degrees: Double((innerGeometry.frame(in: .global).minX - (outerGeometry.size.width / 30 + outerGeometry.frame(in: .global).minX)) / -10)),
                                        axis: (x: 0, y: 1, z: 0),
                                        anchorZ: 0.0,
                                        perspective: 1.0
                                    )
                                    .shadow(color: shadowColor, radius: 6, x: -7, y: -10)
                                    .opacity(isShowingMenu ? 0.5 : 1) // Aplica el efecto de cambio de opacidad durante el scroll
                                    .animation(.easeInOut(duration: 0.3), value: isShowingMenu) // Configura la animación
                            }
                            .frame(width: outerGeometry.size.width * 0.68, height: outerGeometry.size.height * 1.2)
                        }
                        Color.clear
                            .frame(width: outerGeometry.size.width / 7)
                    }
                    .padding(.horizontal, outerGeometry.size.width / 20)
                    .padding(.bottom, 40)
                    .padding(.top, 85)
                }
                .opacity(isShowingMenu ? 0.1 : 1) // Opacidad del contenido cuando el SideMenu está visible
                .animation(.easeInOut(duration: 0.3), value: isShowingMenu)
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        HStack {
                            Text(NSLocalizedString("The Seer", comment: ""))
                                .font(.custom("MuseoModerno", size: 35))
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 114/255, green: 39/255, blue: 165/255))
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                                .padding(.vertical, 20)
                                .frame(height: 70)
                                .opacity(isShowingMenu ? 0 : 1) // Opacidad del texto del título del ToolbarItem
                                .animation(.easeInOut(duration: 0.3), value: isShowingMenu)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        impactFeedback()
                        withAnimation(.spring()) {
                            isShowingMenu.toggle()
                            iconRotation += 180 // Rotate the icon by 180 degrees
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding()
                            .opacity(isShowingMenu ? 0.5 : 1)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.8), radius: 8) // Agregar sombra al icono con color dependiente del tema
                            .rotationEffect(.degrees(iconRotation)) // Apply rotation effect
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        impactFeedback()
                        print("purchasedPredictionCount in IAPManager: \(iapManager.purchasedPredictionCount)")
                        isShowingIAPView = true
                    }) {
                        Text("🔮 \(predictionsLeft)")
                            .font(.custom("MuseoModerno", size:27))
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.4), radius: 7, x: 1, y: 2)
                    }
                }
            }
            .sheet(isPresented: $isShowingIAPView) {
                IAPView(isShowingIAPView: self.$isShowingIAPView)
            }
                
                .navigationBarBackButtonHidden(true) // Oculta el botón de retroceso
                
                if isShowingMenu {
                    SideMenu(isShowingMenu: $isShowingMenu)
                        .transition(.move(edge: .leading))
                }
            }
            .onAppear {
                predictionCounter.predictionCount = UserDefaults.standard.integer(forKey: "predictionCount")
                iapManager.purchasedPredictionCount = UserDefaults.standard.integer(forKey: "purchasedPredictionCount")
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    isShowingMenu.toggle()
                }
            }
    }
    
    struct SideMenu: View {
        @EnvironmentObject var iapManager: IAPManager
        @State private var isShowingIAPView = false
        @Binding var isShowingMenu: Bool
        @Environment(\.colorScheme) var colorScheme
        @AppStorage("isDarkMode") private var isDarkMode = false
        let emailAddress = "theseerapplication@gmail.com"
        
        var isSystemInDarkMode: Bool {
            return colorScheme == .dark
        }
        
        var body: some View {
            ZStack {
                if colorScheme == .dark {
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .leading, endPoint: .trailing)
                } else {
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.clear]), startPoint: .leading, endPoint: .trailing)
                }
                
                VStack(alignment: .leading, spacing: 40) {
                                        
                    Button(action: {
                        print("purchasedPredictionCount in IAPManager: \(iapManager.purchasedPredictionCount)")
                                               isShowingIAPView = true
                    }) {
                        HStack {
                            Image(systemName: "shield.fill")
                            Text(NSLocalizedString("block_ads", comment: ""))
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                        }
                    }
                    .sheet(isPresented: $isShowingIAPView) {
                                    IAPView(isShowingIAPView: self.$isShowingIAPView)
                                }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.instagram.com/TheSeerApp/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image("InstaSideMenu")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text(NSLocalizedString("Instagram", comment: ""))
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://twitter.com/TheSeerApp") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image("TwitterSideMenu")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text(NSLocalizedString("Twitter", comment: ""))
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                        }
                    }
                    
                    
                    Button(action: {
                        if let url = URL(string: "mailto:theseerapplication@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text(NSLocalizedString("contact_us", comment: ""))
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                        }
                    }
                    
                    
                    Spacer() // Spacer principal aquí
                    
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text(isDarkMode ? NSLocalizedString("Dark Mode", comment: "") : NSLocalizedString("Light Mode", comment: ""))  // Aquí cambias el texto.
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                        }
                    }
                    .onAppear {
                        self.isDarkMode = self.isSystemInDarkMode
                    }
                    .onChange(of: isDarkMode) { newValue in
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            scene.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                            impactFeedback()
                        }
                        isDarkMode = newValue
                    }
                    .padding(.bottom, 100)  // Agrega el padding que necesites aquí.
                }
                .padding()
                .padding(.top, 100)
            }
            .frame(width: UIScreen.main.bounds.width / 1.7)
            .offset(x: isShowingMenu ? UIScreen.main.bounds.width / -4.8 : -UIScreen.main.bounds.width)
        }
    }
}
    
    
    struct ContentView: View {
        @ObservedObject var iapManager = IAPManager.shared

        var body: some View {
            NavigationView {
                IntroView()
                    .environmentObject(IAPManager.shared)
                    .environmentObject(PredictionCounter.shared)
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
