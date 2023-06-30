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
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "000000"), location: 0),
                        .init(color: Color(hex: "180027"), location: 0.4),
                        .init(color: Color(hex: "180027"), location: 0.6),
                        .init(color: Color(hex: "000000"), location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "000000"), location: 0),
                        .init(color: Color(hex: "180027"), location: 0.4),
                        .init(color: Color(hex: "180027"), location: 0.6),
                        .init(color: Color(hex: "000000"), location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }

            VStack {
                Spacer()

                Image("wizard4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
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
                        .animation(.easeInOut(duration: 1), value: showText)
                        .padding(.bottom, -44)

                }

                Spacer()
            }
            
            .opacity(goToMainView ? 0 : 2)
            .animation(.easeInOut(duration: 1), value: goToMainView)
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1)))

            if showMainView {
                MainView()
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1)))
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
    @AppStorage("predictionCount") var predictionCount: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingMenu = false
    @State private var iconRotation: Double = 0 // Declare iconRotation here
    @State private var isMenuButtonBouncing = false
    
    private var predictionsLeft: Int {
        max(0, 3 - predictionCount)
    }

    let cards = [
        Card(
            title: NSLocalizedString("Love", comment: ""),
            description: NSLocalizedString("Cupid's got nothing on me! \nFire daring questions like: \n\n\"When will I meet 'the one'? \n \n\"Will my ex and I get back together?\"", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color.red.opacity(1), Color.pink.opacity(1)]), startPoint: .top, endPoint: .bottom),
            type: .love
        ),
        Card(
            title: NSLocalizedString("Finance", comment: ""),
            description: NSLocalizedString("Want a glimpse into your financial future? \nAsk questions like: \n\n\"What does my financial future look like?\" \n\n\"Am I ever going to win the lottery?\"", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color.green.opacity(1), Color.yellow.opacity(1)]), startPoint: .top, endPoint: .bottom),
            type: .finance
        ),
        Card(
            title: NSLocalizedString("Relationships", comment: ""),
            description: NSLocalizedString("Delve into matters of family and relationships. \n\n\"Will my relationship with my parents improve?\" \n\n\"Will my friendship last?\" \n\nLet's find out!", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(1), Color.orange.opacity(1)]), startPoint: .top, endPoint: .bottom),
            type: .relationships
        ),
        Card(
            title: NSLocalizedString("Health", comment: ""),
            description: NSLocalizedString("Want to peek into your health's future? \nAsk questions like: \n\n\"What health challenges might I face in the future?\" \n \n\"Will my mental health improve?\"", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 0/255, blue: 128/255), Color(red: 173/255, green: 216/255, blue: 230/255)]), startPoint: .top, endPoint: .bottom),
            type: .health
        ),
        Card(
            title: NSLocalizedString("Job", comment: ""),
            description: NSLocalizedString("Keen to discover your professional destiny? \nFire questions like: \n\n\"Will I get a promotion soon?\" \n \n\"Will my business idea be successful?\"", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(1), Color.brown.opacity(1)]), startPoint: .top, endPoint: .bottom),
            type: .job
        ),
        Card(
            title: NSLocalizedString("Education", comment: ""),
            description: NSLocalizedString("Looking for insights into your educational journey? \nAsk questions like: \n\n\"What areas of study should I focus on?\" \n \n\"Will I be successful in my upcoming exams?\"", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color(red: 30/255, green: 144/255, blue: 255/255), Color(red: 240/255, green: 248/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom),
            type: .education
        ),
        Card(
            title: NSLocalizedString("Death", comment: ""),
            description: NSLocalizedString("Brave enough to face life's deepest truths? \nCourageously ask me things like: \n\n\"How will I die?\" \n \n\"How can I come to terms with my mortality?\" \n\n Warning: You might not like the answer.", comment: ""),
            color: LinearGradient(gradient: Gradient(colors: [Color.black.opacity(1), Color.gray.opacity(1)]), startPoint: .top, endPoint: .bottom),
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
                            Text("The Seer")
                                .font(.custom("MuseoModerno", size: 35))
                                .font(.headline)
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
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Agregar sombra al icono con color dependiente del tema
                            .rotationEffect(.degrees(iconRotation)) // Apply rotation effect
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) { // Put it in the leading side of the navigation bar
                        Text("🔮 \(predictionsLeft)")
                        .font(.custom("MuseoModerno", size:27))
                    }
            }
            .navigationBarBackButtonHidden(true) // Oculta el botón de retroceso

            if isShowingMenu {
                SideMenu(isShowingMenu: $isShowingMenu)
                    .transition(.move(edge: .leading))
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isShowingMenu.toggle()
            }
        }
    }
}

struct SideMenu: View {
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
                    print("Block Ads tapped")
                }) {
                    HStack {
                        Image(systemName: "shield.fill")
                        Text(NSLocalizedString("Block Ads", comment: ""))
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                    }
                }


                Button(action: {
                    print("Restore Purchase tapped")
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text(NSLocalizedString("Restore Purchase", comment: ""))
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.2), radius: 10, x: 0, y: 2)
                    }
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
                        Text(NSLocalizedString("Contact Us", comment: ""))
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


struct ContentView: View {
    var body: some View {
        NavigationView {
            IntroView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


