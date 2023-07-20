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

@available(iOS 16.0, *)
struct ResultView: View {
    let prediction: String
    let card: Card
    let name: String
    let question: String
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
                            .font(.title)
                            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("\"\(question)\"")
                            .font(.title3)
                            .italic()
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 20)
                    
                    VStack {
                        Spacer()
                        Text(prediction)
                            .font(.title2)
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
                        .font(.custom("MuseoModerno", size: 20))
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
                    
                    Button(action: {
                        self.showResult = false
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(60)
                        }
                }
                .padding(.bottom, 50)
                
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
        }
    }
}
