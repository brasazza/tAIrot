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
    let type: CardType
}

enum CardType: String {
    case love = "Love"
    case finance = "Finance"
    case relationships = "Relationships"
    case death = "Death"
    case job = "Job"
    case health = "Health"
    case education = "Education"
}

