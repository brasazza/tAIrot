//
//  ResultView.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        if let pngData = image.pngData() {
            let pngImage = UIImage(data: pngData)
            UIImageWriteToSavedPhotosAlbum(pngImage!, self, #selector(saveCompleted), nil)
        }
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Saved!")
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
    
    @Environment(\.displayScale) var displayScale
    
    private let imageSaver = ImageSaver()
    @State private var isShareSheetShowing = false
    @State private var shareImage: UIImage? = nil
    @State private var shareImageData: Data? = nil
    
    var contentView: some View {
        ZStack {
            card.color
                .cornerRadius(50)
                .padding()
                .shadow(radius: 5)

            VStack {
                VStack(alignment: .center, spacing: 10) {
                    Text("\(name)'s Future 🔮")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("\"\(question)\"")
                        .font(.title3)
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 20)
                
                VStack {
                    Spacer()
                    Text(prediction)
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
            .padding(50)
        }
        .drawingGroup()
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
                        imageSaver.writeToPhotoAlbum(image: image)
                    }) {
                        Text("💾")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 191/255, green: 101/255, blue: 197/255))
                            .cornerRadius(60)
                    }
                        
                    Button(action: {
                        let totalHeight = geometry.size.height
                        let image = contentView.snapshot(width: 500, height: totalHeight)
                        shareImageData = image.pngData()
                        isShareSheetShowing = true
                    }) {
                        Text("Share")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 191/255, green: 101/255, blue: 197/255))
                            .cornerRadius(60)
                    }
                    .sheet(isPresented: $isShareSheetShowing) {
                        ShareSheet(imageData: $shareImageData)
                    }
                        
                    Button(action: {}) {
                        Text("Done")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 191/255, green: 101/255, blue: 197/255))
                            .cornerRadius(60)
                    }
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
            .background(Image("bg").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
        }
    }
}





    
