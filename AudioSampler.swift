//
//  AudioSampler.swift
//  SoundWaveVisualization
//
//  Created by rs on 2/11/21.
//

import Foundation
import AVFoundation

class AudioSampler {
    
    typealias SoundSamples = [Float]
    
    private(set) var soundSamples: SoundSamples {
        didSet {
            onUpdate?(soundSamples)
        }
    }
    
    var onUpdate: ((SoundSamples) -> Void)?
    
    let audioRecorder: AVAudioRecorder
    
    private var displayLink: CADisplayLink?
    private var currentSample: Int
    private let samplesCount: Int
    
    init(_ audioRecorder: AVAudioRecorder, samplesCount: Int) {
        precondition(samplesCount > 0, "samplesCount should be > 0")
        self.samplesCount = samplesCount
        self.audioRecorder = audioRecorder
        self.currentSample = 0
        self.soundSamples = [Float](repeating: 0, count: samplesCount)
    }
    
    func start() {
        audioRecorder.isMeteringEnabled = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(Self.updateMeters))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc private func updateMeters() {
        self.audioRecorder.updateMeters()
        self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
        self.currentSample.increas(by: 1, upTo: self.samplesCount)
    }
    
    func stop() {
        displayLink?.invalidate()
    }
    
    deinit { stop() }
}

private extension Int {
    mutating func increas(by value: Int, upTo max: Int) {
        self = (self + 1) % max
    }
}

