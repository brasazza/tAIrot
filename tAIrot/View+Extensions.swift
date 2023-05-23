//
//  View+Extensions.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 22/05/23.
//

import SwiftUI
import UIKit

extension View {
    func snapshot() -> UIImage? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let hostingController = window.rootViewController as? UIHostingController<Self> else {
            return nil
        }

        let targetSize = hostingController.view.bounds.size
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }
}




