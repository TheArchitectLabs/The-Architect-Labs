//
//  LetterView.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/11/22.
//

import SwiftUI

struct LetterView: View {
    
    // MARK: - PROPERTIES
    @ScaledMetric(relativeTo: .largeTitle) var size = 60
    let letter: Letter
    var color: Color
    var onTap: (Letter) -> Void
    
    // MARK: - BODY
    var body: some View {
        Button {
            onTap(letter)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.gradient)
                    .frame(height: size)
                    .frame(minWidth: size / 2, maxWidth: size)
                    .shadow(radius: 3)
                
                Text(letter.character)
                    .foregroundColor(.black.opacity(0.65))
                    .font(.largeTitle.bold())
            }
        }
        .accessibilityLabel(letter.character.lowercased())
    }
}

// MARK: - PRVIEW
struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        LetterView(letter: Letter(), color: .orange, onTap: { _ in })
    }
}
