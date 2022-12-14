//
//  ContentView.swift
//  WordScramble
//
//  Created by William Young on 04/10/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word!", text: $newWord)
                        .autocapitalization(.none)
                        .onSubmit {
                            addNewWord()
                        }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
                
                Section {
                    Text("Your score is: \(score)")
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Restart") {
                        restart()
                    }
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used.", message: "Try again!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible.", message: "Please use the letters provided!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not real.", message: "Please use a real word!")
            return
        }
        
        guard aboveThree(word: answer) else {
            wordError(title: "Word is to short.", message: "Please use more than 2 characters!")
            return
        }
        
        guard isRoot(word: answer) else {
            wordError(title: "Can't be root word.", message: "Please pick a different word!")
            return
        }
        
        addScore(word: answer)
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from Bundle.")
    }
    
    func addScore(word: String) {
        score += word.count
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func aboveThree(word: String) -> Bool {
        word.count > 2
    }
    
    func isRoot(word: String) -> Bool {
        if word == rootWord {
            return false
        }
        return true
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
        
        func restart() {
            startGame()
            usedWords = [String]()
            score = 0
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
