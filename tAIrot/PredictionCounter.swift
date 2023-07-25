//
//  PredictionCounter.swift
//  The Seer
//
//  Created by Brandon Ramírez Casazza on 17/07/23.
//

import SwiftUI

class PredictionCounter: ObservableObject {
    static let shared = PredictionCounter()

    @ObservedObject var iapManager = IAPManager.shared

    @AppStorage("predictionCount") private var storedPredictionCount: Int = 0 {
        didSet {
            predictionCount = storedPredictionCount
        }
    }
    @Published var predictionCount: Int = 0

    @AppStorage("lastPredictionTimestamp") private var storedLastPredictionTimestamp: Double = 0 {
        didSet {
            lastPredictionTimestamp = storedLastPredictionTimestamp
        }
    }
    @Published var lastPredictionTimestamp: Double = 0

    init() {
        if storedLastPredictionTimestamp == 0 {
            storedPredictionCount = 3
        }
    }
}












