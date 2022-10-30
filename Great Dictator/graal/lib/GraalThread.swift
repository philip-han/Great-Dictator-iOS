//
//  GraalThread.swift
//  scraper
//
//  Created by Philip Han on 1/16/22.
//

import Foundation

typealias CBlock = @convention(c) () -> Void

class GraalThread: NSObject {

    static let shared = GraalThread()
    
    private var thread: Thread!
    private let isolate = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    private let params = UnsafeMutablePointer<graal_create_isolate_params_t>.allocate(capacity: 1)
    internal let graal_thread = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    
    private override init() {
        super.init()
        self.start()
    }
    
   
    private func cleanup() {
        let ret = graal_detach_all_threads_and_tear_down_isolate(graal_thread.pointee)
        if ret != 0 {
            print("error tearing down isolate")
            exit(0)
        }
        params.deallocate()
        isolate.deallocate()
        graal_thread.deallocate()
    }
    
    private func graalThreadInit() {
        let ret = graal_create_isolate(self.params, self.isolate, graal_thread)
        if ret != 0 {
            print("error creating isolate")
            exit(0)
        }
    }
    
    public func start() {
        let semaphore = DispatchSemaphore(value: 0)
        self._start(semaphore: semaphore)
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    private func _start(semaphore: DispatchSemaphore) {
        
        if thread != nil {
            print("already started")
            return
        }
        
        let threadName = String(describing: self)
            .components(separatedBy: .punctuationCharacters)[1]
        
        thread = Thread { [weak self] in
            self?.graalThreadInit()
            semaphore.signal()
            while (self != nil && !self!.thread.isCancelled) {
                RunLoop.current.run(
                    mode: RunLoop.Mode.default,
                    before: Date.distantFuture
                )
            }
            self?.cleanup()
            print("exiting thread")
            self?.thread = nil
            Thread.exit()
        }
        print("starting thread")
        thread.name = "\(threadName)-\(UUID().uuidString)"
        thread.qualityOfService = QualityOfService.userInitiated
        thread.start()
    }
    
    func stop() {
        guard let thread = thread else { return }
        thread.cancel()
    }
  
    func queueCBlock(_ cBlock: @escaping CBlock) {
        guard let thread = thread else {
            print("thread stopped")
            return
        }
        perform(#selector(_dispatch),
                on: thread,
                with: cBlock,
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }
    
    @objc
    private func _dispatch(cBlock: CBlock) {
        cBlock()
    }
    
    func queueBlock(_ receiver: AnyObject, _ sel: Selector, with arg: Any? = nil) {
        guard let thread = thread else {
            print("thread stopped")
            return
        }
        receiver.perform(sel,
                on: thread,
                with: arg,
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }
    
    
}
