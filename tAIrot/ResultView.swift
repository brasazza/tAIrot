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
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError
                             error: Error?, contextInfo: UnsafeRawPointer) {
        print("Saved!")
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
    
    // This view will be used for the image rendering.
    var contentView: some View {
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
                Spacer()
            }
        }
        .padding(50)
        .frame(maxWidth: 500, maxHeight: 500)  // Adjust these values as needed
        .drawingGroup()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                ZStack {
                    card.color
                        .cornerRadius(50)
                        .padding()
                        .shadow(radius: 5)
                    
                    contentView
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                }
                
                HStack(spacing: 50) {
                    Button(action: {
                        let renderer = ImageRenderer(content: body)
                        if let image = renderer.uiImage {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: image)
                        }
                    }) {
                        Text("💾")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 191/255, green: 101/255, blue: 197/255))
                            .cornerRadius(60)
                    }
                    
                    Button(action: {}) {
                        Text("Share")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 191/255, green: 101/255, blue: 197/255))
                            .cornerRadius(60)
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
            }
            .background(Color.gray.opacity(0.2))
            .edgesIgnoringSafeArea(.all)
        }
    }
}






































