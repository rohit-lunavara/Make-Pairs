//
//  ViewController.swift
//  Challenge10
//
//  Created by Rohit Lunavara on 6/25/20.
//  Copyright © 2020 Rohit Lunavara. All rights reserved.
//

import UIKit

enum CardType : Int {
    case hidden
    case shown
}

class ViewController: UIViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    var currentWords = [String]()
    var currentActiveWords = [ActiveWord]()
    var currentFoundWords = [ActiveWord]()
    var flips = 0 {
        didSet {
            navigationItem.leftBarButtonItem?.title = "Flips : \(flips)"
        }
    }
    
    let notificationCenter = NotificationCenter.default
    let defaults = UserDefaults.standard
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        registerObservers()
        configureButtons()
        loadGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let ac = UIAlertController(title: "Rules", message: "Flip the cards 2 at a time to find their pairs!", preferredStyle: .alert)
        let newGameAction = UIAlertAction(title: "New Game", style: .default, handler: startGame)
        let continueAction = UIAlertAction(title: "Continue", style: .default)
        ac.addAction(newGameAction)
        ac.addAction(continueAction)
        present(ac, animated: true)
    }
    
    //MARK: - Setup Navigation Bar
    
    func setupNavigationBar() {
        title = K.gameName
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Flips : 0", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(confirmResetGame))
    }
    
    //MARK: - Handle Observers
    
    func registerObservers() {
        notificationCenter.addObserver(self, selector: #selector(saveGame), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(loadGame), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

//MARK: - Configure Button

extension ViewController {
    func configureButtons() {
        for view in view.subviews {
            for i in K.Bounds.tagLowerBound ... K.Bounds.tagUpperBound {
                guard let btn = view.viewWithTag(i) as? UIButton else { continue }
                
                btn.setTitleColor(K.hiddenColor, for: .normal)
                btn.titleLabel?.adjustsFontSizeToFitWidth = true
                
                btn.layer.cornerRadius = btn.frame.width / 10
                btn.layer.borderColor = K.hiddenColor.cgColor
                btn.layer.borderWidth = btn.frame.width / 50
                btn.clipsToBounds = true
                
                // Change color when button is pressed
                let renderer = UIGraphicsImageRenderer(bounds: btn.frame)
                let image = renderer.image { (ctx) in
                    UIColor.secondarySystemFill.setFill()
                    ctx.cgContext.fill(btn.frame)
                }
                btn.setBackgroundImage(image, for: .highlighted)
            }
        }
    }
}

//MARK: - UIButton helper extension

extension UIButton {
    func transitionLabel(_ title: String?, using color: UIColor, for state: CardType) {
        let transition : UIView.AnimationOptions =
            color == K.shownColor ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: self, duration: K.Animation.flipTransitionTime, options: transition, animations: {
            self.setTitle(title, for: .normal)
            self.setTitleColor(color, for: .normal)
            self.layer.borderColor = color.cgColor
        }) { (done) in
            if done {
                if state == .hidden {
                    self.isUserInteractionEnabled = true
                } else {
                    self.isUserInteractionEnabled = false
                }
            }
        }
    }
}

//MARK: - Save and Load Game Data

extension ViewController {
    func loadWords() {
        guard let wordsPath = Bundle.main.path(forResource: "start", ofType: "txt") else { fatalError("Could not find start.txt") }
        guard let words = try? String(contentsOfFile: wordsPath) else { fatalError("Could not read words from start.txt") }
        usedWords.removeAll()
        allWords = words.components(separatedBy: "\n")
    }
    
    @objc func saveGame() {
        defaults.set(currentWords, forKey: K.Keys.currentWords)
        defaults.set(flips, forKey: K.Keys.flips)
        
        let jsonEncoder = JSONEncoder()
        if let activeWordsData = try? jsonEncoder.encode(currentActiveWords) {
            defaults.set(activeWordsData, forKey: K.Keys.activeWords)
        }
        if let foundWordsData = try? jsonEncoder.encode(currentFoundWords) {
            defaults.set(foundWordsData, forKey: K.Keys.foundWords)
        }
    }
    
    @objc func loadGame() {
        let jsonDecoder = JSONDecoder()
        if let activeWordsData = defaults.object(forKey: K.Keys.activeWords) as? Data,
            let foundWordsData = defaults.object(forKey: K.Keys.foundWords) as? Data  {
            if let activeWords = try? jsonDecoder.decode([ActiveWord].self, from: activeWordsData),
                let foundWords = try? jsonDecoder.decode([ActiveWord].self, from: foundWordsData) {
                currentActiveWords = activeWords
                currentFoundWords = foundWords
                
                currentWords = defaults.stringArray(forKey: K.Keys.currentWords) ?? [String]()
                flips = defaults.integer(forKey: K.Keys.flips)
                
                loadButtons()
            }
        }
        else {
            startGame()
        }
    }
    
    func loadButtons() {
        var savedTags = [Int]()
        for savedWord in currentFoundWords + currentActiveWords {
            guard let btn = view.viewWithTag(savedWord.tag) as? UIButton else { continue }
            btn.transitionLabel(savedWord.word, using: K.shownColor, for: .shown)
            savedTags.append(savedWord.tag)
        }
        
        for i in K.Bounds.tagLowerBound ... K.Bounds.tagUpperBound where !savedTags.contains(i) {
            guard let btn = view.viewWithTag(i) as? UIButton else { continue }
            btn.transitionLabel(K.hiddenName, using: K.hiddenColor, for: .hidden)
        }
    }
}

//MARK: - Game Logic

extension ViewController {
    func startGame(_ action : UIAlertAction! = nil) {
        loadWords()
        resetGame()
    }
    
    @objc func confirmResetGame() {
        let ac = UIAlertController(title: "Reset Game", message: "Are you sure?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .destructive, handler: resetGame)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @objc func resetGame(_ action : UIAlertAction! = nil) {
        currentWords.removeAll(keepingCapacity: true)
        assert(currentWords.count == 0)
        
        for _ in 0 ..< K.Bounds.wordsToWin / 2 {
            guard let newWord = allWords.randomElement() else {
                startGame()
                return
            }
            currentWords.append(newWord)
            currentWords.append(newWord)
        }
        currentWords.shuffle()
        assert(currentWords.count == K.Bounds.wordsToWin)
        
        flips = 0
        currentFoundWords.removeAll(keepingCapacity: true)
        currentActiveWords.removeAll(keepingCapacity: true)
        
        for view in view.subviews {
            for i in K.Bounds.tagLowerBound ... K.Bounds.tagUpperBound {
                guard let btn = view.viewWithTag(i) as? UIButton else { continue }
                btn.transitionLabel(K.hiddenName, using: K.hiddenColor, for: .hidden)
            }
        }
        
        saveGame()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let currentWord = currentWords[sender.tag - 1]
        sender.transitionLabel(currentWord, using: K.shownColor, for: .shown)
        
        let newActiveWord = ActiveWord(tag: sender.tag, word: currentWord)
        if !currentActiveWords.contains(newActiveWord)
            && !currentFoundWords.contains(newActiveWord)
            && currentActiveWords.count <= 1 {
            flips += 1
            currentActiveWords.append(newActiveWord)
        }
        
        if currentActiveWords.count == 2 {
            checkAnswer(sender)
        }
    }
    
    @objc func checkAnswer(_ sender : UIButton) {
        view.isUserInteractionEnabled = false
        
        dispatchGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + K.Animation.answerDelay) { [unowned self] in
            if self.currentActiveWords[0].word == self.currentActiveWords[1].word {
                self.currentFoundWords.append(contentsOf: self.currentActiveWords)
                self.currentActiveWords.removeAll(keepingCapacity: true)
            }
            else {
                guard let btn1 = self.view.viewWithTag(self.currentActiveWords[0].tag) as? UIButton else { fatalError("Button not found")
                }
                btn1.transitionLabel(K.hiddenName, using: K.hiddenColor, for: .hidden)
                sender.transitionLabel(K.hiddenName, using: K.hiddenColor, for: .hidden)
                self.currentActiveWords.removeAll(keepingCapacity: true)
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.view.isUserInteractionEnabled = true
            self.checkWin()
        }
    }
    
    func checkWin() {
        if currentFoundWords.count == K.Bounds.wordsToWin {
            DispatchQueue.main.asyncAfter(deadline: .now() + K.Animation.restartGameTime) {
                [weak self] in
                let ac = UIAlertController(title: "Game Over!", message: "Number of flips : \(self?.flips ?? 0)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Restart", style: .default, handler: self?.resetGame)
                let shareAction = UIAlertAction(title: "Share", style: .default, handler: self?.shareResult)
                ac.addAction(okAction)
                ac.addAction(shareAction)
                self?.present(ac, animated: true)
                return
            }
        }
    }
}

//MARK: - Share Result

extension ViewController {
    func shareResult(_ action : UIAlertAction! = nil) {
        let result = "I just won the \(K.gameName) game in \(flips) flips!"
        let uc = UIActivityViewController(activityItems: [result], applicationActivities: [])
        uc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(uc, animated: true) {
            [weak self] in
            self?.startGame()
        }
    }
}
