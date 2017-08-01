//
//  AVAKConvenience.swift
//  Audive
//
//  Created by David O'Neill on 7/12/17.
//  Copyright © 2017 David O'Neill. All rights reserved.
//

import Foundation
import AVFoundation


final class GlobalAudio{
    static let shared = GlobalAudio()
    static var engine: AVAudioEngine { return shared.engine }
    static func attach(_ node: AVAudioNode){ shared.attach(node) }
    static var format: AVAudioFormat { return shared.format }
    static func attach(nodes: [AVAudioNode]){ shared.attach(nodes: nodes) }
    
    
    let engine = AVAudioEngine()
    let format = AVAudioFormat.init(standardFormatWithSampleRate: 44100.0, channels: 2)
    func attach(_ node: AVAudioNode){
        if (node.engine == nil){
            engine.attach(node);
        }
    }
    func attach(nodes: [AVAudioNode]){
        for node in nodes { attach(node) }
    }
}


extension AVAudioNode {
    
    @discardableResult func connect(to node: AVAudioNode, bus: AVAudioNodeBus = 0, fromBus: AVAudioNodeBus = 0) -> AVAudioNode{
        GlobalAudio.attach(node)
        GlobalAudio.engine.connect(self,
                                    to: node,
                                    fromBus: fromBus,
                                    toBus: bus,
                                    format: GlobalAudio.format)
        return node
    }
    func disconnectInput(bus: AVAudioNodeBus = 0){
        GlobalAudio.engine.disconnectNodeInput(self, bus: bus)
    }
    func disconnectOutput(bus: AVAudioNodeBus = 0){
        GlobalAudio.engine.disconnectNodeOutput(self, bus: bus)
    }
    func connect(toConnectionPoints: [AVAudioConnectionPoint], fromBus: AVAudioNodeBus = 0){
        GlobalAudio.attach(nodes: toConnectionPoints.map{ $0.node! })
        GlobalAudio.engine.connect(self,
                                    to: toConnectionPoints,
                                    fromBus: fromBus,
                                    format: GlobalAudio.format)
    }
    
    func connect(to nodes: [AVAudioNode], fromBus: AVAudioNodeBus = 0){
        let connectionPoints = nodes.map{AVAudioConnectionPoint.init(node: $0, bus: 0)}
        return connect(toConnectionPoints:connectionPoints, fromBus:fromBus)
    }
    func detach(){
        GlobalAudio.engine.detach(self)
    }
}

























