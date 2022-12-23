//
//  SettingsView.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/19/22.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.dismiss) private var dismiss
    @AppStorage("clockTime") var defaultClockTime: Int = 60
    @AppStorage("highScore") var highScore: Int = 0
    
    var clockTimes: [Int] = [30,60,90]
    
    // MARK: - BODY
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Clock Time Setting", selection: $defaultClockTime) {
                        ForEach(clockTimes, id: \.self) { time in
                            Text("\(time)")
                        }
                    }
                    .pickerStyle(.segmented)
                    
                } header: {
                    Text("What do you want the starting time to be?")
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button(role: .destructive) {
                            highScore = 0
                        } label: {
                            Text("Reset")
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                } header: {
                    HStack {
                        Text("Reset High Score")
                        Spacer()
                        Text("\(highScore)")
                    }
                }
            }
            
            Button {
                dismiss()
            } label: {
                Text("Dismiss")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - PREVIEW
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
