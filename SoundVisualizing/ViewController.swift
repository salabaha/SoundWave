//
//  ViewController.swift
//  SoundWaveVisualization
//
//  Created by rs on 2/11/21.
//

import UIKit
import AVFoundation
import Accelerate

class ViewController: UIViewController {

    @IBOutlet weak var waveView: SoundWaveView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var friquencyLabel: UILabel!
    
    let audioSession = AVAudioSession.sharedInstance()

    var audioSampler: AudioSampler?

    @IBAction func sliderDidUpdateFrequency(sender: UISlider) {
        waveView.frequency = CGFloat(sender.value)
        friquencyLabel.text = "frequency: \(Int(waveView.frequency))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        slider.value = Float(waveView.frequency)
        sliderDidUpdateFrequency(sender: slider)
        
        
        let url = URL(fileURLWithPath: "/dev/null")
    
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                            AVNumberOfChannelsKey: 1,
                                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue ] as [String : Any]
        

        audioSession.requestRecordPermission { [weak self] (isAllowed) in
            guard isAllowed else { return }
            guard let self = self else { return }

            self.audioSampler = .init(try! .init(url: url, settings: settings), samplesCount: 10)

            self.audioSampler?.start()
            self.audioSampler?.audioRecorder.record()

            self.audioSampler?.onUpdate = { [weak self] soundSamples in
                self?.waveView.soundSamples = soundSamples
            }
        }
    }
}


