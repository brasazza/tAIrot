//
//  Card.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 19/05/23.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: LinearGradient
}

