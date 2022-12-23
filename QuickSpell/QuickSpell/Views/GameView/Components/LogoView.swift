//
//  LogoView.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/13/22.
//

import SwiftUI

struct LogoView: View {
    
    // MARK: - PROPERTIES
    @Binding var isBonusOn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: -10) {
                TitleViewCharacter(letter: "Q", color: isBonusOn ? .yellow : .orange, rotation: Angle(degrees: -10))
                TitleViewCharacter(letter: "U", color: isBonusOn ? .yellow : .green, rotation: Angle(degrees: 8))
                TitleViewCharacter(letter: "I", color: isBonusOn ? .yellow : .purple, rotation: Angle(degrees: 0))
                TitleViewCharacter(letter: "C", color: isBonusOn ? .yellow : .red, rotation: Angle(degrees: 10))
                TitleViewCharacter(letter: "K", color: isBonusOn ? .yellow : .blue, rotation: Angle(degrees: -5))
            }
            
            HStack(spacing: -10) {
                TitleViewCharacter(letter: "S", color: isBonusOn ? .yellow : .purple, rotation: Angle(degrees: 10))
                TitleViewCharacter(letter: "P", color: isBonusOn ? .yellow : .orange, rotation: Angle(degrees: -5))
                TitleViewCharacter(letter: "E", color: isBonusOn ? .yellow : .yellow, rotation: Angle(degrees: 8))
                TitleViewCharacter(letter: "L", color: isBonusOn ? .yellow : .blue, rotation: Angle(degrees: -10))
                TitleViewCharacter(letter: "L", color: isBonusOn ? .yellow : .green, rotation: Angle(degrees: 10))
            }
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(isBonusOn: .constant(false))
    }
}

struct TitleViewCharacter: View {
    
    let letter: String
    let color: Color
    let rotation: Angle
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 80, height: 80)
                .shadow(radius: 3)
            
            Text(letter)
                .foregroundColor(.white.opacity(0.65))
                .font(.largeTitle.bold())
        }
        .rotationEffect(rotation)
    }
}
