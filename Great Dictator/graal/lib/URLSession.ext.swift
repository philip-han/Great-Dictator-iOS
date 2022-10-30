//
//  URLSession.ext.swift
//  Great Dictator
//
//  Created by Philip Han on 10/19/22.
//

import Foundation

extension URLSession {

    func synchronousDataTask(withString uri: String, withSpeech speech: String) throws -> (data: Foundation.Data?, response: HTTPURLResponse?) {
        let escaped = uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: escaped!)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = speech.data(using: String.Encoding.utf8)
        return try self.synchronousDataTask(with: request)
    }
        
    func synchronousDataTask(with request: URLRequest) throws -> (data: Foundation.Data?, response: HTTPURLResponse?) {

        let semaphore = DispatchSemaphore(value: 0)

        var responseData: Foundation.Data?
        var theResponse: URLResponse?
        var theError: Error?

        dataTask(with: request) { (data, response, error) -> Void in

            responseData = data
            theResponse = response
            theError = error

            semaphore.signal()

        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        if let error = theError {
            throw error
        }

        return (data: responseData, response: theResponse as! HTTPURLResponse?)

    }

}
