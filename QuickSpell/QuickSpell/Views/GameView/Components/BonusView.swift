//
//  BonusView.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/15/22.
//

import SwiftUI

struct BonusView: View {
    
    // MARK: - PROPERTIES
    @Binding var bonus: Bonus
    
    // MARK: - BODY
    var body: some View {
        
        VStack(spacing: 50) {
            
            VStack(alignment: .center, spacing: 5) {
                HStack(spacing: 20) {
                    Text("+\(bonus.points)\n Pts")
                        .frame(width: 80, height: 50)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.gradient)
                                .shadow(radius: 3)
                        )
                        .multilineTextAlignment(.center)
                    
                    Gauge(value: bonus.currentValue, in: bonus.minValue...bonus.maxValue) {
                        Text("Done")
                            .foregroundColor(.white)
                    } currentValueLabel: {
                        Text("\(bonus.currentValue, specifier: "%.0f") / \(bonus.maxValue, specifier: "%.0f")")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(Gradient(colors: [.green, .yellow, .red]))
                    
                    Text("+\(bonus.duration)\n Secs")
                        .frame(width: 80, height: 50)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.pink.gradient)
                                .shadow(radius: 3)
                        )
                        .multilineTextAlignment(.center)
                }
                .font(.headline)
                
                Text(bonus.task)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(.white)
            )
        }
    }
}

// MARK: - PREVIEW
struct BonusView_Previews: PreviewProvider {
    
    static var previews: some View {
        BonusView(bonus: .constant(Bonus(task: "Placeholder", points: 0, duration: 0, type: .time, minValue: 0, currentValue: 0, maxValue: 0)))
            .background(.blue.gradient)
    }
}
