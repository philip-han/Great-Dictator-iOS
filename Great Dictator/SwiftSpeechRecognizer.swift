//
//  SpeechRecognizer.swift
//  Great Dictator
//
//  Created by Philip Han on 10/4/22.
//

import Foundation
import AVFAudio
import Speech

class SwiftSpeechRecognizer: NSObject {
    
    private let audioEngine = AVAudioEngine()
    var callback: Callback? = nil
    var stateCallback: StateCallback? = nil
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var authorized = false
    
    func reqAuth() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.authorized = true
                    self.start()
                case .notDetermined:
                    self.authorized = false
                case .denied:
                    self.authorized = false
                case .restricted:
                    self.authorized = false
                @unknown default:
                    self.authorized = false
                }
            }
        }
    }
    
    func start() {
        
        if !authorized {
            reqAuth()
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = false
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            
            // Configure the microphone input.
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }

            // Create a recognition task for the speech recognition session.
            // Keep a reference to the task so that it can be canceled.
            if let speechRecognizer = SFSpeechRecognizer() {
                if  let scb = stateCallback {
                    scb(GraalThread.shared.graal_thread.pointee, true)
                }
                recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                    var isFinal = false
                    if let result = result {
                        let confidence: Float = result.bestTranscription.segments.first?.confidence ?? Float(0)
                        print("confidence \(confidence)")
                        isFinal = result.isFinal
                        print("Text \(result.bestTranscription.formattedString) isFinal: \(result.isFinal)")
                        if let cb = self.callback {
                            cb(GraalThread.shared.graal_thread.pointee, result.bestTranscription.formattedString.toCStringRef(), confidence)
                        }
                    }
                    
                    if error != nil || isFinal {
                        // Stop recognizing speech if there is a problem.
                        self.audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        
                        self.recognitionRequest = nil
                        self.recognitionTask = nil
                        
                        if error != nil {
                            print("error: \(String(describing: error))")
                            if let err = error {
                                let errorCode = (err as NSError).code
                                if errorCode == 1107 {
                                    print("restart")
                                    self.start()
                                } else {
                                    self.stateCallback?(GraalThread.shared.graal_thread.pointee, false)
                                }
                            }
                        }
                        
                    }
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
        } catch {
            print("unexpected error: \(error)")
        }
    }
    
    func end() {
        print("end recognizer")
        recognitionRequest?.endAudio()
        stateCallback?(GraalThread.shared.graal_thread.pointee, false)
    }
    
    func close() {
        print("end recognizer")
        audioEngine.stop()
    }
    
}
