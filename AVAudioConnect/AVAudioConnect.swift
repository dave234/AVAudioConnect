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
    
    private static let shared = GlobalAudio()
    private let engine = AVAudioEngine()
    
    static var engine: AVAudioEngine { return shared.engine }
    static let format = AVAudioFormat.init(standardFormatWithSampleRate: 44100.0, channels: 2)
    static func attach(_ node: AVAudioNode){
        if (node.engine == nil){
            engine.attach(node);
        }
    }
    static func attach(_ nodes: [AVAudioNode]){
        for node in nodes { attach(node) }
    }
    static func start(){
        do{
            let _ = engine.mainMixerNode
            try engine.start()
        } catch {
            print(error)
        }
    }
    static func stop(){
        engine.stop()
    }

    static var mainMixer: AVAudioMixerNode {
        return engine.mainMixerNode
    }
}


extension AVAudioNode {
    
    @discardableResult func connect(to node: AVAudioNode, bus: AVAudioNodeBus = 0, fromBus: AVAudioNodeBus = 0) -> AVAudioNode{
        GlobalAudio.attach(self)
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
        GlobalAudio.attach(self)
        GlobalAudio.attach(toConnectionPoints.map{ $0.node! })
        GlobalAudio.engine.connect(self,
                                   to: toConnectionPoints,
                                   fromBus: fromBus,
                                   format: GlobalAudio.format)
    }
    
    @discardableResult func connect(to nodes: [AVAudioNode], fromBus: AVAudioNodeBus = 0) -> [AVAudioNode]{
        let connectionPoints = nodes.map{AVAudioConnectionPoint.init(node: $0, bus: 0)}
        connect(toConnectionPoints:connectionPoints, fromBus:fromBus)
        return nodes
    }
    func bus(_ bus:AVAudioNodeBus) -> AVAudioConnectionPoint{
        return AVAudioConnectionPoint.init(node: self, bus: bus)
    }
    func detach(){
        GlobalAudio.engine.detach(self)
    }
}






@discardableResult func +(left: AVAudioNode, right: AVAudioNode) -> AVAudioNode {
    left.connect(to: right)
    return right
}
@discardableResult func +(left: AVAudioNode, right: AVAudioConnectionPoint) -> AVAudioNode {
    return left.connect(to: right.node!, bus: right.bus)
}
@discardableResult func +(left: AVAudioNode, right: [AVAudioNode]) -> [AVAudioNode] {
    return left.connect(to: right)
}
@discardableResult func +(left: [AVAudioNode], right: AVAudioMixerNode) -> AVAudioMixerNode {
    for node in left {
        node.connect(to: right, bus: right.nextAvailableInputBus)
    }
    return right
}
//@discardableResult func +(left: AVAudioNode, right: AVAudioMixerNode) -> AVAudioMixerNode {
//    return left.connect(to: right, bus: right.nextAvailableInputBus) as! AVAudioMixerNode
//}













