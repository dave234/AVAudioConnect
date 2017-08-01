//
//  ViewController.swift
//  AVAudioConnect
//
//  Created by David O'Neill on 8/1/17.
//  Copyright © 2017 O'Neill. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var file1: AVAudioFile!
    var file2: AVAudioFile!
    let player1: AVAudioPlayerNode = AVAudioPlayerNode()
    let player2: AVAudioPlayerNode = AVAudioPlayerNode()
    
    let reverb = AVAudioUnitReverb()
    let delay = AVAudioUnitDelay()
    let distortion = AVAudioUnitDistortion()
    
    let mixer = AVAudioMixerNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFiles()
        setUpUI()
        
        GlobalAudio.start()
        
        reverb.wetDryMix = 50
        
        let config = 4  //try 1, 2, and 3
        
        switch config {
        case 1:
            [player1 >>> reverb,
             player2 >>> distortion >>> delay] >>> GlobalAudio.mainMixer
        case 2:
            player1 >>> reverb >>> GlobalAudio.mainMixer.bus(0)
            player2 >>> distortion >>> delay >>> GlobalAudio.mainMixer.bus(1)
        case 3:
            //The output of mixer is split to distortion and delay
            [player1, player2] >>> mixer  >>> [distortion, delay] >>> GlobalAudio.mainMixer
        case 4:
            //same setup as 3 diffent choice of operators
            player1 >>> mixer
            player2 >>> mixer
            mixer + distortion
            mixer + delay
            distortion >>> GlobalAudio.mainMixer
            delay >>> GlobalAudio.mainMixer
        }
    }

    
    
    func player1ButtonAction(){
        player1.scheduleFile(file1, at: nil, completionHandler: nil)
        player1.play()
    }
    func player2ButtonAction(){
        player2.scheduleFile(file2, at: nil, completionHandler: nil)
        player2.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setUpUI(){
        let button1 = UIButton(type: .system)
        button1.addTarget(self, action: #selector(player1ButtonAction), for: .touchUpInside)
        button1.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button1.setTitle("Player 1", for: .normal)
        view.addSubview(button1)
        
        
        let button2 = UIButton(type: .system)
        button2.addTarget(self, action: #selector(player2ButtonAction), for: .touchUpInside)
        button2.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
        button2.setTitle("Player 2", for: .normal)
        view.addSubview(button2)
    }
    func setUpFiles(){
        guard let url1 = Bundle.main.url(forResource: "english84", withExtension: "mp3"),
            let url2 = Bundle.main.url(forResource: "english130", withExtension: "mp3") else {
                fatalError()
        }
        do {
            file1 = try AVAudioFile.init(forReading: url1)
            file2 = try AVAudioFile.init(forReading: url2)
        } catch {
            fatalError()
        }
        
        

    }
}

