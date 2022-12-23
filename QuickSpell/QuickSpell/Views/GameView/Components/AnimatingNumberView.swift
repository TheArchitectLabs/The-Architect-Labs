//
//  AnimatingNumberView.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/11/22.
//

import SwiftUI

struct AnimatingNumberView: View, Animatable {
    
    // MARK: - PROPERTIES
    var title: String
    var value: Int
    
    var animatableData: Double {
        get { Double(value) }
        set { value = Int(newValue) }
    }
    
    // MARK: - BODY
    var body: some View {
        Text("\(title): \(value)")
    }
}

// MARK: - PREVIEW
struct AnimatingNumberView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatingNumberView(title: "Score", value: 100)
    }
}
