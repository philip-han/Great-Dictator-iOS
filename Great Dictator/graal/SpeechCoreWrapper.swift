//
//  SpeechCoreWrapper.swift
//  Great Dictator
//
//  Created by Philip Han on 10/4/22.
//

import Foundation
import SwiftUI

class SpeechCoreWrapper: NSObject, ObservableObject {
    
    @Published var publishedList: Array<SwiftSpeechBusinessData> = [SwiftSpeechBusinessData]()
    @Published var speechRecognizerState: (text: String, color: Color)? // = ("Sleeping", Color.black)
    @Published var errorMessageState: String = ""
    
    private let vm_init = speechcore_init
    private var graalThread = GraalThread.shared.graal_thread.pointee
    private var dispatcherFunc: Dispatcher
    private var errorDispatcherFunc: ErrorDispatcher
    private var stateDispatcherFunc: StateDispatcher
    private let httpPostFunc: @convention(c) (_ uri: UnsafeMutablePointer<CChar>, _ speech: UnsafeMutablePointer<CChar>) -> UnsafeMutablePointer<Either>?
   
    override init() {
        httpPostFunc = httpPost
        dispatcherFunc = { speechCoreWrapperAsPointer, arr in
            if let unwrappedPointer = speechCoreWrapperAsPointer {
                if var speechBusinessDataArray = arr {
                    var speechList: [SwiftSpeechBusinessData] = []
                    while let s = speechBusinessDataArray.pointee { // incoming array must be null pointer terminated
                        speechList.append(convertToSwiftSpeechBusinessData(s))
                        speechBusinessDataArray += 1
                    }
                    let speechCoreWrapper = Unmanaged<SpeechCoreWrapper>.fromOpaque(unwrappedPointer).takeUnretainedValue()
                    DispatchQueue.main.async {
                        speechCoreWrapper.publishedList = speechList
                    }
                }
            }
        }
        stateDispatcherFunc = { speechCoreWrapperAsPointer, state in
            if let unwrappedPointer = speechCoreWrapperAsPointer {
                let speechCoreWrapper = Unmanaged<SpeechCoreWrapper>.fromOpaque(unwrappedPointer).takeUnretainedValue()
                DispatchQueue.main.async {
                    speechCoreWrapper.speechRecognizerState = speechCoreWrapper.convertSpeechRecognizerStateForDisplay(isListening: state)
                }
            }
        }
        errorDispatcherFunc = { speechCoreWrapperAsPointer, errorMessage in
            if let unwrappedPointer = speechCoreWrapperAsPointer {
                let speechCoreWrapper = Unmanaged<SpeechCoreWrapper>.fromOpaque(unwrappedPointer).takeUnretainedValue()
                DispatchQueue.main.async {
                    speechCoreWrapper.errorMessageState = errorMessage.toString()
                }
            }
        }
        super.init()
        setupViewModel()
    }
    
    private func convertSpeechRecognizerStateForDisplay(isListening: Bool) -> (String, Color) {
        isListening ? ("LISTENING", Color.red) : ("Sleeping", Color.black)
    }
    
    func toggle() {
        GraalThread.shared.queueBlock(self, #selector(_toggle))
    }
    
    @objc
    func _toggle() {
        speechcore_toggle(graalThread)
        
    }

    func setupViewModel() {
        GraalThread.shared.queueBlock(self, #selector(_setupViewModel))
    }
    
    @objc
    func _setupViewModel() {
        let speechCoreWrapperAsPointer = Unmanaged.passUnretained(self).toOpaque()
        let sr = createSpeechRecognizerStruct()
        vm_init(graalThread, speechCoreWrapperAsPointer, unsafeBitCast(dispatcherFunc, to: UnsafeMutableRawPointer?.self),
                unsafeBitCast(stateDispatcherFunc, to: UnsafeMutableRawPointer?.self), unsafeBitCast(errorDispatcherFunc, to: UnsafeMutableRawPointer?.self),
                sr, unsafeBitCast(httpPostFunc, to: UnsafeMutableRawPointer?.self))
        
    }
    
    func start() {
        GraalThread.shared.queueBlock(self, #selector(_start))
    }
    
    @objc func _start() {
        speechcore_start(graalThread)
    }
    
    func end() {
        GraalThread.shared.queueBlock(self, #selector(_end))
    }
    
    @objc func _end() {
        speechcore_end(graalThread)
    }
    
    func close() {
        GraalThread.shared.queueBlock(self, #selector(_close))
    }
    
    @objc func _close() {
        speechcore_close(graalThread)
    }
    
}

func httpPost(uri: UnsafeMutablePointer<CChar>, speech: UnsafeMutablePointer<CChar>) -> UnsafeMutablePointer<Either>? {
    print("ios http get")
    // allocate does not gurantee sanitization? need to find out.
    let v = UnsafeMutablePointer<Either>.allocate(capacity: 1)
    do {
        let (data, _) = try URLSession.shared.synchronousDataTask(withString: uri.toString(), withSpeech: speech.toString())
        if let d = data {
            v.pointee.error = nil // fails null check on java side if not initialized as nil
            v.pointee.type = stringValue
            v.pointee.value = unsafeBitCast(String(data: d, encoding: .utf8).toCStringRef(), to: UnsafeMutableRawPointer?.self)
        }
    } catch let error as NSError {
        let e = UnsafeMutablePointer<CError>.allocate(capacity: 1)
        e.pointee.code = Int32(error.code)
        e.pointee.message = error.localizedDescription.toCStringRef()
        v.pointee.error = e
        v.pointee.value = nil
    }
    return v
}

struct SwiftSpeechBusinessData: Identifiable, Hashable {
    let speech: String
    let confidenceRatingColor: String
    let sentiment: String
    let interrogative: Bool
    let id = UUID()
}

func convertToSwiftSpeechBusinessData(_ s: UnsafeMutablePointer<SpeechBusinessData>) -> SwiftSpeechBusinessData {
    let data = SwiftSpeechBusinessData(
        speech: s.pointee.speech.toString(),
        confidenceRatingColor: s.pointee.confidenceRatingColor.toString(),
        sentiment: s.pointee.sentiment.toString(),
        interrogative: s.pointee.interrogative
    )
    print("speech: \(data.speech) confidence: \(data.confidenceRatingColor)")
    s.pointee.speech.deallocate()
    s.pointee.sentiment.deallocate()
    s.pointee.confidenceRatingColor.deallocate()
    s.deallocate()
    return data
}
