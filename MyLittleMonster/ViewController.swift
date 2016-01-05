//
//  ViewController.swift
//  MyLittleMonster
//
//  Created by Joshua Ide on 5/01/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imgMonster: MonsterImg!
    @IBOutlet weak var imgFood: DragImg!
    @IBOutlet weak var imgHeart: DragImg!
    @IBOutlet weak var imgPenalty1: UIImageView!
    @IBOutlet weak var imgPenalty2: UIImageView!
    @IBOutlet weak var imgPenalty3: UIImageView!
    @IBOutlet weak var lblGameOver: UILabel!
    @IBOutlet weak var btnRestart: UIButton!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var currentPenalties = 0
    var timer: NSTimer!
    var monsterHappy = true
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgFood.dropTarget = imgMonster
        imgHeart.dropTarget = imgMonster
        
        imgPenalty1.alpha = DIM_ALPHA
        imgPenalty2.alpha = DIM_ALPHA
        imgPenalty3.alpha = DIM_ALPHA
        imgHeart.alpha = DIM_ALPHA
        imgFood.alpha = DIM_ALPHA
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDroppedOnCharacter:", name: "onTargetDropped", object: nil)
        
        do {
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!))
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxSkull.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        startTimer()
    }

    func itemDroppedOnCharacter(notif: AnyObject) {
        monsterHappy = true
        startTimer()
        
        imgFood.alpha = DIM_ALPHA
        imgHeart.alpha = DIM_ALPHA
        imgFood.userInteractionEnabled = false
        imgHeart.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else {
            sfxBite.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeGameState", userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        let rand = arc4random_uniform(2)
        if rand == 0 {
            imgFood.alpha = DIM_ALPHA
            imgFood.userInteractionEnabled = false
            imgHeart.alpha = OPAQUE
            imgHeart.userInteractionEnabled = true
        } else {
            imgHeart.alpha = DIM_ALPHA
            imgHeart.userInteractionEnabled = false
            imgFood.alpha = OPAQUE
            imgFood.userInteractionEnabled = true
        }
        
        if !monsterHappy {
            currentPenalties++
            sfxSkull.play()
            
            if currentPenalties == 1 {
                imgPenalty1.alpha = OPAQUE
                imgPenalty2.alpha = DIM_ALPHA
            } else if currentPenalties == 2 {
                imgPenalty2.alpha = OPAQUE
                imgPenalty3.alpha = DIM_ALPHA
            } else if currentPenalties >= 3 {
                imgPenalty3.alpha = OPAQUE
            } else {
                imgPenalty1.alpha = DIM_ALPHA
                imgPenalty2.alpha = DIM_ALPHA
                imgPenalty3.alpha = DIM_ALPHA
            }
            
            if currentPenalties >= MAX_PENALTIES {
                gameOver()
            }
        }

        currentItem = rand
        monsterHappy = false
    }
    
    func gameOver() {
        timer.invalidate()
        imgMonster.playDeathAnimation()
        sfxDeath.play()
        imgHeart.userInteractionEnabled = false
        imgFood.userInteractionEnabled = false
        imgHeart.alpha = DIM_ALPHA
        imgFood.alpha = DIM_ALPHA
        lblGameOver.hidden = false
        btnRestart.hidden = false
    }
    
    @IBAction func onRevivePressed(sender: AnyObject) {
        lblGameOver.hidden = true
        btnRestart.hidden = true
        
        imgFood.dropTarget = imgMonster
        imgHeart.dropTarget = imgMonster
        
        imgPenalty1.alpha = DIM_ALPHA
        imgPenalty2.alpha = DIM_ALPHA
        imgPenalty3.alpha = DIM_ALPHA
        imgHeart.alpha = DIM_ALPHA
        imgFood.alpha = DIM_ALPHA
        imgMonster.playIdleAnimation()
        
        currentPenalties = 0
        monsterHappy = true
        startTimer()
    }
    
    
}

