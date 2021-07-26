//
//  ViewController.swift
//  MacOSShazamClone
//
//  Created by David Ilenwabor on 26/07/2021.
//

import AVKit
import Cocoa
import ShazamKit

class ViewController: NSViewController {

    @IBOutlet weak var songTitle: NSTextField!
    @IBOutlet weak var songArtist: NSTextField!
    private var session = SHSession()
    private let audioEngine = AVAudioEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func startListening(_ sender: Any) {
    }
    
    @IBAction func stopListening(_ sender: Any) {
    }
    
    private func startRecording() {
        proceedWithRecording()
    }

    private func proceedWithRecording() {

        if audioEngine.isRunning {
            stopRecording()
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)

        inputNode.removeTap(onBus: .zero)
        inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            self?.session.matchStreamingBuffer(buffer, at: time)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func stopRecording() {
        audioEngine.stop()
    }
    
}


extension ViewController: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let matchedMediaItem = match.mediaItems.first else {
            return
        }
        stopRecording()
        DispatchQueue.main.async {
            self.songTitle.stringValue = matchedMediaItem.title ?? "No song title"
            self.songArtist.stringValue = matchedMediaItem.artist ?? "No artist title"
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("Error with finding match \(error?.localizedDescription ?? "")")
        stopRecording()
    }
}

