//
//  ContentView.swift
//  QuickSpell
//
//  Created by Michael & Diana Pascucci on 11/11/22.
//

import SwiftUI

struct GameView: View {
    
    // MARK: - PROPERTIES
    @AppStorage("highScore") var highScore = 0
    @AppStorage("clockTime") var defaultClockTime = 30
    @AppStorage("gameState") var gameState: GameState = .loading
    @Namespace private var animation
    
    // Global Variables
    //@State private var gameState: GameState = .loading
    
    @State private var dictionary = Set<String>()
    @State private var unusedLetters = [Letter]()
    @State private var usedLetters = [Letter]()
    @State private var usedWords: Set<String> = Set<String>()
    @State private var score: Int = 0
    
    @State private var gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeToEndofGame: Int = 0
    
    @State private var randomBonusToChoose: Int = 0
    @State private var randomTimeBeforeShowBonusTask: Int = 0
    @State private var bonusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var bonusTimeRemaining: Int = 0
    @State private var isBonusOn: Bool = false
    @State private var showBonusTask: Bool = false
    
    @State private var isGameOver: Bool = false
    @State private var isSoundPlaying: Bool = false
    @State private var newHighScoreSet: Bool = false

    @State private var isSettingsPresented: Bool = false
    @State private var isGamePaused: Bool = false
    
    @State private var bonusCount: Int = 0
    @State private var bonusLettersNeeded: Int = 3
    
    let bonusArray: [Bonus] = [
        Bonus(task: "Get five 5-letter words", points: 100, duration: 0, type: .value, minValue: 0.0, currentValue: 0.0, maxValue: 5.0),
        Bonus(task: "Get a run of 3-letter, 4-letter, 5-letter, and 6-letter words in consecutive order", points: 50, duration: 10, type: .value, minValue: 0.0, currentValue: 0.0, maxValue: 4.0),
        Bonus(task: "Use all of your tiles in one word", points: 1000, duration: 30, type: .value, minValue: 0.0, currentValue: 0.0, maxValue: 1.0),
        Bonus(task: "Continue playing for 1 minutes", points: 500, duration: 20, type: .time, minValue: 0.0, currentValue: 60.0, maxValue: 60.0)
    ]
    
    @State private var bonus = Bonus(task: "Placeholder", points: 0, duration: 0, type: .value, minValue: 0.0, currentValue: 0.0, maxValue: 0.0)
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack {
                
                // Logo, Time, and Scores
                VStack(spacing: 1) {
                    LogoView(isBonusOn: $isBonusOn)
                        .padding(.bottom, 20)
                    HStack {
                        AnimatingNumberView(title: "Time", value: timeToEndofGame)
                        Spacer()
                        AnimatingNumberView(title: "Score", value: score)
                    }
                    HStack {
                        AnimatingNumberView(title: "Bonus", value: bonusTimeRemaining)
                        Spacer()
                        AnimatingNumberView(title: "High Score", value: highScore)
                    }
                }
                .padding(.vertical, 5)
                .foregroundColor(.white)
                .monospacedDigit()
                .font(.title)
                
                // Show/Hide the Bonus Task
                if showBonusTask {
                    BonusView(bonus: $bonus)
                        .transition(.scale(scale: 0, anchor: .top))
                        .opacity(isGamePaused ? 0 : 1)
                }
                
                Spacer()
                
                // Start Button
                if gameState == .loading || gameState == .paused {
                    Button {
                        gameState == .loading ? start() : resume()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.green.gradient)
                                .frame(width: 200, height: 60)
                                .shadow(radius: 3)
                            
                            HStack {
                                Image(systemName: "play")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                                Text(gameState == .loading ? " START" : " RESUME")
                                    .foregroundColor(.white)
                                    .font(.largeTitle.bold())
                            }
                        }
                    }
                } else {
                    
                    // Used Letter Display
                    HStack {
                        ForEach(usedLetters) { letter in
                            LetterView(letter: letter, color: wordIsValid() ? .green : .red, onTap: remove)
                                .matchedGeometryEffect(id: letter, in: animation)
                        }
                    }
                    .opacity(isGamePaused ? 0 : 1)
                    
                    Spacer()
                    
                    // Unused Letter Display
                    HStack {
                        ForEach(unusedLetters) { letter in
                            LetterView(letter: letter, color: .yellow, onTap: add)
                                .matchedGeometryEffect(id: letter, in: animation)
                        }
                    }
                    .opacity(isGamePaused ? 0 : 1)
                }
                
                Spacer()
                
                // Go and Reset Buttons
                HStack {
                    Button {
                        submit()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.green.gradient)
                                .frame(width: 80, height: 60)
                                .shadow(radius: 3)
                            
                            Text("GO")
                                .foregroundColor(.white.opacity(0.65))
                                .font(.largeTitle.bold())
                        }
                    }
                    .disabled(wordIsValid() == false)
                    .opacity(wordIsValid() ? 1 : 0.35)
                    
                    Spacer()
                    
                    Button {
                        resetLetters()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.orange.gradient)
                                .frame(width: 80, height: 60)
                                .shadow(radius: 3)
                            
                            Image(systemName: "shuffle.circle")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityLabel("Reset Button")
                    .disabled(gameState != .playing)
                    .opacity(gameState != .playing ? 0.35 : 1)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if gameState == .playing { pause() }
                        isSettingsPresented.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }

                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        start()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            Text("Reset")
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(gameState == .loading || gameState == .ended)
                }
                ToolbarItem {
                    Button {
                        isGamePaused ? resume() : pause()
                    } label: {
                        Image(systemName: isGamePaused ? "play.fill" : "pause.fill")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(gameState == .loading || gameState == .ended)

                }
            }
            .padding()
            .background(.blue.gradient)
            .onAppear {
                load()
            }
            .onReceive(gameTimer) { _ in
                if timeToEndofGame == 0 {
                    stop()
                } else if timeToEndofGame < 12 {
                    if isSoundPlaying == false {
                        SoundManager.instance.playSound("clock")
                    }
                    timeToEndofGame -= 1
                } else {
                    SoundManager.instance.stopSound()
                    timeToEndofGame -= 1
                }
            }
            .onReceive(bonusTimer) { _ in
                if bonusTimeRemaining > 0 && showBonusTask == false {
                    bonusTimeRemaining -= 1
                } else if bonusTimeRemaining == 0 && showBonusTask == false {
                    showBonusTask = true
                    if bonus.type == .time {
                        bonusTimeRemaining = Int(bonus.maxValue)
                    } else {
                        bonusTimer.upstream.connect().cancel()
                    }
                } else if bonusTimeRemaining > 0 && showBonusTask == true {
                    bonusTimeRemaining -= 1
                    bonus.currentValue -= 1
                } else {
                    bonusTimer.upstream.connect().cancel()
                    score += bonus.points
                    timeToEndofGame += bonus.duration
                    awardBonus()
                }
            }
            .alert(isPresented: $isGameOver) {
                Alert(title: Text("Game Over!\n You scored: \(score) points!"),
                      primaryButton: .default(Text("Play again? 👍"), action: {
                    start()
                }),
                      secondaryButton: .cancel(Text("I need a break! 😴 🧃 🥨"), action: {
                    resetGame()
                    bonusTimeRemaining = 0
                }))
            }
            .sheet(isPresented: $isSettingsPresented) {
                // do nothing
            } content: {
                SettingsView()
            }
        }
    }
}

// MARK: - PREVIEW
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            GameView()
        }
    }
}

// MARK: - EXTENSION FOR GAME SETUP AND STATE CONTROL METHODS
extension GameView {
    
    // Load the Dictionary from Bundle and Setup the Game
    func load() {
        
        // Set State
        gameState = .loading
        
        // Load the dictionary
        guard let url = Bundle.main.url(forResource: "wordlist", withExtension: "txt") else { return }
        guard let contents = try? String(contentsOf: url) else { return }
        dictionary = Set(contents.components(separatedBy: .newlines))
        
        // Turn off the timers
        gameTimer.upstream.connect().cancel()
        bonusTimer.upstream.connect().cancel()
    }
    
    // Starts a New Game
    func start() {
        
        // Reset Default Values
        resetGame()
        
        // Set Bonus Clock to randomTime and Start Countdown Timer
        resetBonus()

        // Clear the usedLetters Array and Choose 8 Random Letters for unusedLetters
        resetLetters()
        
        // Set Game Clock to Default Time Listed in AppStorage and Start Countdown Timer
        timeToEndofGame = defaultClockTime
        gameState = .playing
        gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    // Pauses the Game
    func pause() {
        
        // Set State
        gameState = .paused
        
        // Stop the Timers
        gameTimer.upstream.connect().cancel()
        if bonusTimeRemaining > 0 {
            bonusTimer.upstream.connect().cancel()
        }
        
        // Stop Any Sounds From Playing
        SoundManager.instance.stopSound()
        
        isGamePaused = true
    }
    
    // Resumes the Game
    func resume() {
        
        // Set State
        gameState = .playing
        
        // Restart the Timers
        gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        if bonusTimeRemaining > 0 {
            bonusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
        
        isGamePaused = false
    }
    
    func stop() {
        
        // Set State
        gameState = .ended
        isGameOver = true
        isBonusOn = false
        showBonusTask = false
        
        // Stop Any Sounds From Playing
        SoundManager.instance.stopSound()
        
        // Cancel All Timers
        bonusTimer.upstream.connect().cancel()
        gameTimer.upstream.connect().cancel()
    }
    
    // Reset the Game to Initial Settings
    func resetGame() {
        
        // Set State
        gameState = .loading
        
        // Clear the usedWords
        usedWords.removeAll()
        
        score = 0
        isGameOver = false
        isSoundPlaying = false
        newHighScoreSet = false
    }
    
    // Reset the Bonus to Initial Settings
    func resetBonus() {
        
        // Set State
        isBonusOn = false
        showBonusTask = false
        
        // Select a random bonus number - Range is the total number of bonuses created
        randomBonusToChoose = Int.random(in: 0..<bonusArray.count)
        bonus = bonusArray[randomBonusToChoose]
        
        // Select a random bonus show time - Range is between 1 minute and 4 minutes
        bonusTimeRemaining = Int.random(in: 60...240)
        
        // Set Bonus Clock to randomTime and Start Countdown Timer
        bonusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}

// MARK: - EXTENSION FOR GAMEPLAY METHODS
extension GameView {
    
    // Game Play Functions
    func add(_ letter: Letter) {
        guard let index = unusedLetters.firstIndex(of: letter) else { return }
        withAnimation(.spring()) {
            unusedLetters.remove(at: index)
            usedLetters.append(letter)
        }
    }
    
    func remove(_ letter: Letter) {
        guard let index = usedLetters.firstIndex(of: letter) else { return }
        withAnimation(.spring()) {
            usedLetters.remove(at: index)
            unusedLetters.append(letter)
        }
    }
    
    // Reset the Tiles During Game Play
    func resetLetters() {
        unusedLetters = (0..<8).map { _ in Letter() }
        usedLetters.removeAll()
    }
    
    // Submit Word for Validation
    func submit() {
        guard wordIsValid() else { return }
        
        withAnimation {
            // let word = usedLetters.map(\.character).joined().lowercased()
            // usedWords.insert(word)
            
            let bonusScore = getBonus()
            
            score += (usedLetters.count * usedLetters.count) + bonusScore.points
            
            switch usedLetters.count {
            case 5...8:
                timeToEndofGame += (usedLetters.count * 2) + bonusScore.duration
            default:
                timeToEndofGame += (usedLetters.count * 1) + bonusScore.duration
            }
            
            resetLetters()
            
            if score > highScore {
                highScore = score
                if newHighScoreSet == false {
                    SoundManager.instance.playSound("hiscore")
                }
                newHighScoreSet = true
            }
        }
    }
    
    // Word Validation - Words Checked During Submit Process
    func wordIsValid() -> Bool {
        let word = usedLetters.map(\.character).joined().lowercased()
        //guard usedWords.contains(word) == false else { return false }
        
        return dictionary.contains(word)
    }
}

// MARK: - EXTENSION FOR BONUS METHODS
extension GameView {
    
    func getBonus() -> (points: Int, duration: Int) {
        
        guard showBonusTask == true && bonus.type == .value else { return (0, 0) }
        
        switch randomBonusToChoose {
        case 0: // Get five 5-letter words
            if usedLetters.count == 5 {
                bonusCount += 1
                bonus.currentValue += 1
            }
            if bonusCount == 5 {
                bonusCount = 0
                awardBonus()
                return (bonus.points, bonus.duration)
            }
            return (0, 0)
        case 1: // Get a run of 3-letter, 4-letter, 5-letter, and 6-letter words in consecutive order
            switch bonusLettersNeeded {
            case 3, 4, 5:
                if usedLetters.count == bonusLettersNeeded {
                    bonusLettersNeeded += 1
                    bonus.currentValue += 1
                } else {
                    bonusLettersNeeded = 3
                    bonus.currentValue = 0
                }
                return (0, 0)
            default:
                if usedLetters.count == bonusLettersNeeded {
                    bonusCount = 0
                    awardBonus()
                    return (bonus.points, bonus.duration)
                }
            }
            return (0, 0)
        case 2: // Use all of your tiles in one word
            if usedLetters.count == 8 {
                return (bonus.points, bonus.duration)
            }
            return (0, 0)
        default:
            return (0, 0)
        }
    }
    
    func awardBonus() {
        isBonusOn = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            resetBonus()
        }
    }
    
}
