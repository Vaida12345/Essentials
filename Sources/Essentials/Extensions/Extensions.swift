//
//  Extensions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 2019/8/21.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import CoreMedia
import OSLog


// Please note that `Int` is implemented using little-endian byte order, ie, most significant byte is at the rhs.
// While inside each byte, the bits are in bit-endian order, ie, mots significant byte is at the lhs.
// However, in bit-shift, operations are performed as if the bytes are in big-endian order.
public extension BinaryInteger {
    
    /// Calls a closure with a pointer to the object’s bytes.
    @inlinable
    func withUnsafeBufferPointer<Result>(_ body: (UnsafeBufferPointer<UInt8>) -> Result) -> Result {
        withUnsafePointer(to: self) { pointer in
            pointer.withMemoryRebound(to: UInt8.self, capacity: bitWidth / 8) { pointer in
                body(UnsafeBufferPointer(start: pointer, count: bitWidth / 8))
            }
        }
    }
    
    /// The raw data that made up the binary integer.
    ///
    /// - Tip: This method may not be efficient. When you want to access the raw pointer, use ``withUnsafeBufferPointer(_:)`` instead.
    @inlinable
    var data: Data {
        withUnsafeBufferPointer { buffer in
            Data(buffer: buffer)
        }
    }
    
    /// Creates a integer using the given data.
    ///
    /// - Precondition: If `data` length is not equal to bit width, the result is undefined.
    @inlinable
    init(data: Data) {
        self = data.withUnsafeBytes { (tuple: UnsafeRawBufferPointer) in
            tuple.bindMemory(to: Self.self).baseAddress!.pointee
        }
    }

}

extension DefaultStringInterpolation {
    
    /// Interpolates the given value’s textual representation into the string literal being created. It would only be shown when `isShown` is `true`.
    ///
    /// - Parameters:
    ///   - value: any value that should be represented.
    ///   - isShown: Whether the value should be shown.
    @inline(__always)
    public mutating func appendInterpolation(_ value: Any, isShown: Bool) {
        if isShown {
            appendInterpolation(value)
        }
    }
    
    /// Interpolates the given value’s textual representation, if it presents, into the string literal being created, based on the `map` closure.
    ///
    /// - Parameters:
    ///   - value: any value that should be represented.
    ///   - map: the mapping applied when the `value` is non-`nil`.
    @inline(__always)
    public mutating func appendInterpolation<T>(_ value: Optional<T>, map: (T) -> Any) {
        if let value {
            appendInterpolation(map(value))
        }
    }
    
    /// Interpolates and formats the `value` using `format`.
    ///
    /// - Parameters:
    ///   - value: The raw value.
    ///   - format: The formatter applied.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inline(__always)
    public mutating func appendInterpolation<F>(_ value: F.FormatInput, format: F) where F: FormatStyle {
        appendInterpolation(format.format(value))
    }
    
}

/// The implies operator.
infix operator =>: LogicalConjunctionPrecedence

public extension Bool {
    
    /// The logical *implies*.
    ///
    /// The result is only false when `lhs` is `true` and `rhs` is `false`.
    ///
    /// | lhs | rhs | result |
    /// | --- | --- | ------ |
    /// | `true` | `true` | `true` |
    /// | `true` | `false` | `false` |
    /// | `false` | `true` | `true` |
    /// | `false` | `false` | `true` |
    static func => (lhs: Bool, rhs: Bool) -> Bool {
        return !lhs || rhs
    }
    
}

public extension Date {
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable
    func distanceToNow() -> String {
        "\(self.distance(to: Date()), format: .timeInterval)"
    }
    
    /// The the input string using custom strategy.
    ///
    /// For example, to parse `March 31, 2024`, you could do:
    ///
    /// ```swift
    /// let rawDate = "March 31, 2024"
    /// let date = try Date(rawDate, format: "\(month: .wide) \(day: .twoDigits), \(year: .defaultDigits)")
    /// ```
    ///
    /// - Important: The `timeZone` details to `gmt`. Which is the timezone that `Date` natively works with.
    @available(macOS 13, iOS 16, watchOS 9, *)
    @inlinable
    init(_ value: some StringProtocol,
         format: Date.FormatString,
         locale: Locale? = Locale(identifier: "en_us"),
         timeZone: TimeZone = .gmt,
         calendar: Calendar = Calendar(identifier: .gregorian),
         isLenient: Bool = true,
         twoDigitStartDate: Date = Date(timeIntervalSince1970: 0)) throws {
        try self.init(value, strategy: Date.ParseStrategy(format: format, locale: locale, timeZone: timeZone, calendar: calendar, isLenient: isLenient, twoDigitStartDate: twoDigitStartDate))
    }
    
    /// Creates the date using the following components.
    ///
    /// The default time zone is set to be `gmt`. Localizations are ignored.
    ///
    /// There is no such thing as *overflow* for the date components, for example, day 367 of year 2024 would indicate the first date of 2025.
    ///
    /// > Returns: The first match given the specifications
    ///
    /// > Example:
    /// > Use this initializer to form a date using its components. The first match will be returned.
    /// > ```swift
    /// > Date(year: 2024) // 2024-01-01
    /// > ```
    ///
    /// - SeeAlso: For date creation using other components, see `DateComponents`.
    @available(macOS 13, iOS 16, watchOS 9, *)
    init(timeZone: TimeZone = .gmt, year: Int, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        let calendar = Calendar(identifier: .gregorian)
        self = calendar.date(from: DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond))!
    }
    
    /// Creates the date using the following components.
    ///
    /// The default time zone is set to be `gmt`. Localizations are ignored.
    ///
    /// There is no such thing as *overflow* for the date components, for example, day 367 of year 2024 would indicate the first date of 2025.
    ///
    /// > Returns: The first match given the specifications
    ///
    /// > Example:
    /// > Use this initializer to form a date using its components. The first match will be returned.
    /// > ```swift
    /// > Date(year: 2024, quater: 1) // 2024-01-01
    /// > ```
    ///
    /// - SeeAlso: For date creation using other components, see `DateComponents`.
    @available(macOS 13, iOS 16, watchOS 9, *)
    init(timeZone: TimeZone = .gmt, year: Int, quater: Int) {
        let calendar = Calendar(identifier: .gregorian)
        self = calendar.date(from: DateComponents(calendar: calendar, year: year, quarter: quater))!
    }
    
}

@available(macOS 13, iOS 16, watchOS 9, *)
public extension Duration {
    
    /// The duration expressed in seconds.
    ///
    /// > Note:
    /// > Due to the nature of `Double`, precision is lost.
    @inlinable
    var seconds: Double {
        let (seconds, attoseconds) = self.components
        return Double(attoseconds) / 1e18 + Double(seconds)
    }
    
}


extension OptionSet {
    
    /// The option where none is selected.
    public static var none: Self { [] }
    
}


extension FileHandle {
    
    /// Writes the `utf-8` encoding string to the handler, with the terminator.
    @available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
    @inlinable
    public func write(_ value: String, terminator: String = "\n") throws {
        try self.write(contentsOf: (value + terminator).data(using: .utf8)!)
    }
    
}


public extension String {
    
    /// Returns a new string formed from the String by prepending as many occurrences as necessary of a given pad string.
    ///
    /// - Precondition: The `newLength` is longer than the length of the current `String`.
    @inlinable
    func prepadding(toLength newLength: Int, withPad padCharacter: Character) -> String {
        precondition(self.count <= newLength)
        
        return String(repeating: padCharacter, count: newLength - self.count) + self
    }
    
    static private func printChild<T>(_ child: T, header: String, into target: inout String, isLast: Bool, children: (T) -> [T]?, description: (T) -> String) {
        let childDescription = recursiveDescription(of: child, children: children, description: description)
        let components = childDescription.components(separatedBy: "\n").filter({ !$0.isEmpty })
        if let first = components.first {
            target += "\(header)\(first)\n"
        }
        for line in components.dropFirst() {
            target += "\(isLast ? " " : "│") \(line)\n"
        }
    }
    
    /// Print a tree hierarchy of tree.
    ///
    /// ```swift
    ///let node = Node.node([
    ///     .node([
    ///         .leaf(1),
    ///         .node([
    ///             .leaf(2)
    ///         ]),
    ///     ]),
    ///     .leaf(3)
    /// ])
    /// ```
    /// ```swift
    /// recursiveDescription(of: node, children: \.children, 
    ///                      description: \.description)
    /// ```
    /// ```
    /// ─Node
    ///  ├─Node
    ///  │ ├─1
    ///  │ ╰─Node
    ///  │   ╰─2
    ///  ╰─3
    /// ```
    static func recursiveDescription<T>(of target: T, children: (T) -> [T]?, description: (T) -> String) -> String {
        
        var value = "─" + description(target) + "\n"
        if let _children = children(target) {
            for child in _children.dropLast() {
                printChild(child, header: "├", into: &value, isLast: false, children: children, description: description)
            }
            if let last = _children.last {
                printChild(last, header: "╰", into: &value, isLast: true, children: children, description: description)
            }
        }
        return value
        
    }
    
    /// Print a tree hierarchy of tree.
    ///
    /// This is a variant of ``recursiveDescription(of:children:description:)``.
    static func recursiveDescription<T>(of target: T, children: (T) -> [T]?) -> String where T: CustomStringConvertible {
        self.recursiveDescription(of: target, children: children, description: \.description)
    }
    
}


extension Unicode.UTF8 {
    
    /// Returns `nil` if it is not a start byte, otherwise returns the byte length of the character.
    public static func width(startsWith byte: Unicode.UTF8.CodeUnit) -> Int? {
        guard byte & 0b1100_0000 != 0b1000_0000 else { return nil } // lead, starts with 10
        
        if (byte & 0b1000_0000) == 0b0000_0000 { // same as isASCII, starts with 0
            return 1
        } else if (byte & 0b1110_0000) == 0b1100_0000 { // starts with 110
            return 2
        } else if (byte & 0b1111_0000) == 0b1110_0000 { // starts with 1110
            return 3
        } else if (byte & 0b1111_1000) == 0b1111_0000 { // starts with 11110
            return 4
        }
        
        fatalError()
    }
    
}


extension UUID {
    
    /// The raw data that made up the UUID. The length is 16 bytes.
    @inlinable
    public var data: Data {
        withUnsafePointer(to: self.uuid) { buffer in
            Data(bytes: buffer, count: 16)
        }
    }
    
    /// Creates the UUID from raw data.
    @inlinable
    public init(data: Data) throws {
        assert(data.count == 16, "The data length is not 16 bytes.")
        
        let uuid = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            pointer.load(as: uuid_t.self)
        }
        self.init(uuid: uuid)
    }
    
}


extension UnsafeMutablePointer {
    
    /// Copy memory area
    ///
    /// The `memcpy()` function copies *n* bytes from memory area `self` to memory area `destination`.  If `destination` and `self` overlap, behavior is undefined. Applications in which `destination` and `self` might overlap should use `memmove(3)` instead.
    ///
    /// - Parameters:
    ///   - destination: The buffer pointer to the destination address.
    ///   - srcOffset: The offset of `self` base address. The value passed is `self.baseAddress! + srcOffset`.
    ///   - destOffset: The offset of `destination` base address. The value passed is `destination.baseAddress! + destOffset`.
    ///   - n: The number of elements to copy. The stride of `Element` is multiplied.
    ///
    /// - Returns: The `memcpy()` function returns the original value of `destination`.
    @inline(__always)
    @discardableResult
    public func copy(to destination: UnsafeMutablePointer<Pointee>, srcOffset: Int = 0, destOffset: Int = 0, count n: Int) -> UnsafeMutableRawPointer! {
        memcpy(destination + destOffset, self + srcOffset, n * MemoryLayout<Pointee>.stride)
    }
    
}

extension UnsafeMutableBufferPointer {
    
    /// Copy memory area
    ///
    /// The `memcpy()` function copies *n* bytes from memory area `self` to memory area `destination`.  If `destination` and `self` overlap, behavior is undefined. Applications in which `destination` and `self` might overlap should use `memmove(3)` instead.
    ///
    /// - Parameters:
    ///   - destination: The buffer pointer to the destination address.
    ///   - srcOffset: The offset of `self` base address. The value passed is `self.baseAddress! + srcOffset`.
    ///   - destOffset: The offset of `destination` base address. The value passed is `destination.baseAddress! + destOffset`.
    ///   - n: The number of elements to copy. The stride of `Element` is multiplied.
    ///
    /// - Returns: The `memcpy()` function returns the original value of `destination`.
    @inline(__always)
    @discardableResult
    public func copy(to destination: UnsafeMutablePointer<Element>, srcOffset: Int = 0, destOffset: Int = 0, count n: Int) -> UnsafeMutableRawPointer! {
        self.baseAddress!.copy(to: destination, srcOffset: srcOffset, destOffset: destOffset, count: n)
    }
    
}


#if canImport(Vision)
import Vision


public extension VNRectangleObservation {
    
    /// The rect that this observation represents
    @inlinable
    func rect(for image: CGImage) -> CGRect {
        VNImageRectForNormalizedRect(self.boundingBox, image.width, image.height)
    }
    
}
#endif
