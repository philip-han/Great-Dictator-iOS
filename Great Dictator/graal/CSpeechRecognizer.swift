//
//  CSpeechRecognizer.swift
//  Great Dictator
//
//  Created by Philip Han on 10/4/22.
//

import Foundation

let swiftSpeechRecognizer: SwiftSpeechRecognizer = SwiftSpeechRecognizer()
let StartFunc: Start = { swiftSpeechRecognizer.start() }
let EndFunc: End = { swiftSpeechRecognizer.end() }
let CloseFunc: Close = { swiftSpeechRecognizer.close() }
let RegisterCallbackFunc: RegisterCallback = { callback in
    swiftSpeechRecognizer.callback = callback
}
let RegisterStateCallbackFunc: RegisterStateCallback = { stateCallback in
    swiftSpeechRecognizer.stateCallback = stateCallback
}
    
func createSpeechRecognizerStruct() -> UnsafeMutablePointer<SpeechRecognizer> {
    let graalSpeechRecognizer = UnsafeMutablePointer<SpeechRecognizer>.allocate(capacity: 1)
    graalSpeechRecognizer.pointee.start = StartFunc
    graalSpeechRecognizer.pointee.end = EndFunc
    graalSpeechRecognizer.pointee.close = CloseFunc
    graalSpeechRecognizer.pointee.registerCallback = RegisterCallbackFunc
    graalSpeechRecognizer.pointee.registerStateCallback = RegisterStateCallbackFunc
    return graalSpeechRecognizer
}
