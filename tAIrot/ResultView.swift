//  ResultView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import PhotosUI
import IGStoryKit

@available(iOS 16.0, *)
class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        if let pngData = image.pngData() {
            let pngImage = UIImage(data: pngData)
            UIImageWriteToSavedPhotosAlbum(pngImage!, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

class ShareCoordinator: NSObject, UIActivityItemSource, UINavigationControllerDelegate {
    var imageData: Data?
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return imageData
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    
    let coordinator = ShareCoordinator()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        coordinator.imageData = imageData
        let vc = UIActivityViewController(activityItems: [coordinator], applicationActivities: nil)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

@available(iOS 16.0, *)
extension View {
    func snapshot(width: CGFloat, height: CGFloat) -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: width, height: height)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: UIGraphicsImageRendererFormat.default())

        return renderer.image { context in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            let image = context.currentImage
            if let cgImage = image.cgImage?.copy(maskingColorComponents: [255, 255, 255, 255, 255, 255, 255, 255]) {
                let rect = CGRect(origin: .zero, size: targetSize)
                context.cgContext.draw(cgImage, in: rect)
            }
        }
    }
}

struct FireworkParticlesGeometryEffect: GeometryEffect {
    var time: Double
    var speed = Double.random(in: 100...200)
    var direction = Double.random(in: -Double.pi...Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation = CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.1
    let duration = 2.0
    
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<100, id: \.self) { index in
                content
                    .hueRotation(Angle(degrees: time * 80))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(((duration - time) / duration))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: duration)) {
                self.time = duration
                self.scale = 1.0
            }
        }
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var points: [CGPoint] = []
        for i in 0..<5 {
            let angle = .pi * 2 * (Double(i) * 2 / 5 - 0.5)
            let point = CGPoint(x: center.x + rect.width / 2 * CGFloat(cos(angle)),
                                y: center.y + rect.height / 2 * CGFloat(sin(angle)))
            points.append(point)
        }
        var path = Path()
        path.move(to: points[0])
        for i in 1..<5 {
            path.addLine(to: points[i])
        }
        path.closeSubpath()
        return path
    }
}

@available(iOS 16.0, *)
struct ResultView: View {
    let prediction: String
    let card: Card
    let name: String
    let question: String
    let context: String
    @Binding var showResult: Bool
    
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    private let imageSaver = ImageSaver()
    @State private var isShareSheetShowing = false
    @State private var shareImage: UIImage? = nil
    @State private var shareImageData: Data? = nil
    @State private var showMessage = false
    @State private var message = ""

    var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                card.color
                    .cornerRadius(50)
                    .padding()
                    .shadow(radius: 5)
                    .overlay(
                        ForEach(0..<6) { _ in
                            CardEmojiView(card: card)
                                .font(.system(size: CGFloat(arc4random_uniform(50) + 50)))
                                .opacity(0.3)
                                .rotationEffect(.degrees(Double(Int(arc4random_uniform(50)) - 20)))
                                .position(x: CGFloat(arc4random_uniform(UInt32(geometry.size.width))),
                                          y: CGFloat(arc4random_uniform(UInt32(geometry.size.height))))
                        }
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 50)
                            .padding()
                    )

                VStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text(String(format: NSLocalizedString("%@'s Destiny 🔮", comment: ""), name))
                            .font(geometry.size.height < 668 ? .title2 : .title)
                            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("\"\(question)\"")
                            .font(geometry.size.height < 668 ? .headline : .title2)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Context: \"\(context)...\"")
                            .font(geometry.size.height < 668 ? .headline : .title2)
                            .italic()
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.white)
                            .opacity(0.6)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, geometry.size.height < 668 ? 10 : 10)
                    
                    VStack {
                        Spacer()
                        Text(prediction)
                            .font(
                                    geometry.size.height < 668
                                    ? (prediction.count < 300 ? .title3 : .headline)
                                    : (prediction.count < 380 ? .title2 : .title3)
                                )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 500)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    
                    // Aquí agregamos el texto
                    Text("The Seer App 🔮")
                        .font(.custom("MuseoModerno", size: geometry.size.height < 668 ? 13 : 20))
                        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                        .bold()
                        .foregroundColor(.white)  // También puedes cambiar el color
                        .padding(.bottom, -24)
                   
                }
                .padding(50)
            }
            .drawingGroup()
        }
    }

    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                    
                contentView
                
                HStack(spacing: 50) {
                    Button(action: {
                        impactFeedback()
                        let totalHeight = geometry.size.height
                        let image = contentView.snapshot(width: 500, height: totalHeight)
                        imageSaver.successHandler = {
                            self.message = NSLocalizedString("save_success", comment: "")
                            self.showMessage = true
                        }
                        imageSaver.errorHandler = { error in
                            self.message = String(format: NSLocalizedString("save_failure", comment: ""), error.localizedDescription)
                            self.showMessage = true
                        }
                        imageSaver.writeToPhotoAlbum(image: image)
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(60)
                    }
                    .alert(isPresented: $showMessage) {
                        Alert(title: Text(message))
                    }
                        
                    Button(action: {
                        impactFeedback()
                        let totalHeight = geometry.size.height
                        let image = contentView.snapshot(width: 500, height: totalHeight)
                        
                        if let backgroundImage = UIImage(named: "blackbg") {
                            let story = IGStory(contentSticker: image, background: .image(image: backgroundImage))
                            
                            let dispatcher = IGDispatcher(story: story, facebookAppID: "2503996109776287")
                            dispatcher.start()
                        }}) {
                        Image("Instagram") // Using Instagram icon image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(60)
                    }
                    
                    Button(action: {
                        impactFeedback()
                        let totalHeight = geometry.size.height
                        let image = contentView.snapshot(width: 500, height: totalHeight)
                        shareImageData = image.pngData()
                        isShareSheetShowing = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(60)
                    }
                        .presentationDragIndicator(.visible)
                    .sheet(isPresented: $isShareSheetShowing) {
                        ShareSheet(imageData: $shareImageData)
                    }
                }
                .padding(.bottom, 10)
                
                Spacer()
            }
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
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 20, height: 20)  // Adjust size as needed
                .modifier(ParticlesModifier())
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 20, height: 20)  // Adjust size as needed
                .modifier(ParticlesModifier())
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 20, height: 20)  // Adjust size as needed
                .modifier(ParticlesModifier())
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 20, height: 20)  // Adjust size as needed
                .modifier(ParticlesModifier())
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct Previews_ResultView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
