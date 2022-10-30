//
//  String+UnsafeMutablePointer.swift
//  scraper
//
//  Created by Philip Han on 1/23/22.
//

import Foundation

extension Optional where Wrapped == String {
    func toCStringRef() -> UnsafeMutablePointer<CChar> {
        guard let s = self else { return "nil".toCStringRef() }
        return UnsafeMutablePointer<CChar>(mutating: (s as NSString).utf8String!)
    }
}

extension Optional where Wrapped == UnsafeMutablePointer<CChar> {
    func toString() -> String {
        guard let s = self else { return "nil" }
        return String(cString: s)
    }
}

extension String {
    func toCStringRef() -> UnsafeMutablePointer<CChar> {
        return UnsafeMutablePointer<CChar>(mutating: (self as NSString).utf8String!)
    }
}

extension UnsafeMutablePointer where Pointee == CChar {
    func toString() -> String {
        return String(cString: self)
    }
}
