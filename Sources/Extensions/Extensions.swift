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
    ///
    /// Please note that arm64 uses little-endian for the order of bytes.
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
    /// Please note that arm64 uses little-endian for the order of bytes.
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
    /// Please note that arm64 uses little-endian for the order of bytes.
    ///
    /// - Precondition: `data` length must equal to bit width, otherwise the result is undefined.
    @inlinable
    init(data: Data) {
        self = data.withUnsafeBytes { (tuple: UnsafeRawBufferPointer) in
            tuple.bindMemory(to: Self.self).baseAddress!.pointee
        }
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
    @inlinable
    static func => (lhs: Bool, rhs: @autoclosure () throws -> Bool) rethrows -> Bool {
        try !lhs || rhs()
    }
}


extension DefaultStringInterpolation {
    
    /// Interpolates the given value’s textual representation into the string literal being created. It would only be shown when `isShown` is `true`.
    ///
    /// - Parameters:
    ///   - value: any value that should be represented.
    ///   - isShown: Whether the value should be shown.
    @inlinable
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
    @inlinable
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
    @inlinable
    public mutating func appendInterpolation<F>(_ value: F.FormatInput, format: F) where F: FormatStyle {
        appendInterpolation(format.format(value))
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
    @inlinable
    init(timeZone: TimeZone = .gmt, year: Int, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        let calendar = Calendar(identifier: .gregorian)
        self = calendar.date(from: DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond))!
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


extension FileHandle {
    
    /// Writes the `utf-8` encoding string to the handler, with the terminator.
    @available(*, deprecated, message: "The signature is catastrophically different from that of TextOutputStream.write(_:).")
    @available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
    @inlinable
    public func write(_ value: String, terminator: String = "\n") throws {
        try self.write(contentsOf: (value + terminator).data(using: .utf8)!)
    }
    
}


@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
extension Logger {
    
    /// Creates a custom logger for logging to a specific subsystem and category of current function.
    @inlinable
    public init(subsystem: String, function: String = #function) {
        self.init(subsystem: subsystem, category: #function)
    }
    
}


extension OptionSet {
    
    /// The option where none is selected.
    @inlinable
    public static var none: Self { [] }
    
}

extension Optional {
    
    /// Returns `true` is `self == nil` or `predicate(self!)`.
    @inlinable
    public func isNil(or predicate: (Wrapped) -> Bool) -> Bool {
        switch self {
        case .none: true
        case .some(let wrapped): predicate(wrapped)
        }
    }
    
}


public extension String {
    
    /// Returns a new string formed from the String by prepending as many occurrences as necessary of a given pad string.
    ///
    /// - Precondition: The `newLength` is longer than the length of the current `String`.
    @inlinable
    func prepadding(toLength newLength: Int, withPad padCharacter: Character) -> String {
        guard self.count < newLength else { return self }
        return String(repeating: padCharacter, count: newLength - self.count) + self
    }
    
}


extension Unicode.UTF8 {
    
    /// Returns `nil` if it is not a start byte, otherwise returns the byte length of the character.
    @inlinable
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
    public init(data: Data) {
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
    ///   - n: The number of elements to copy. The stride of `Element` is multiplied.
    @inlinable
    public func copy(to destination: UnsafeMutableRawPointer, count n: Int) {
        memcpy(destination, self, n &* MemoryLayout<Pointee>.stride)
    }
    
    /// Copy memory area
    ///
    /// The `memcpy()` function copies *n* bytes from memory area `destination` to memory area `self`.  If `destination` and `self` overlap, behavior is undefined. Applications in which `destination` and `self` might overlap should use `memmove(3)` instead.
    ///
    /// - Parameters:
    ///   - source: The buffer pointer to the source address.
    ///   - n: The number of elements to copy. The stride of `Element` is multiplied.
    @inlinable
    public func copy(from source: UnsafeRawPointer, count n: Int) {
        memcpy(self, source, n &* MemoryLayout<Pointee>.stride)
    }
    
}

extension UnsafeMutableBufferPointer {
    
    /// Copy memory area
    ///
    /// The `memcpy()` function copies *n* bytes from memory area `self` to memory area `destination`.  If `destination` and `self` overlap, behavior is undefined. Applications in which `destination` and `self` might overlap should use `memmove(3)` instead.
    ///
    /// - Parameters:
    ///   - destination: The buffer pointer to the destination address.
    ///   - n: The number of elements to copy. The stride of `Element` is multiplied.
    @inlinable
    public func copy(to destination: UnsafeMutableRawPointer, count n: Int) {
        self.baseAddress!.copy(to: destination, count: n)
    }
    
    /// Copy memory area
    ///
    /// The `memcpy()` function copies *n* bytes from memory area `destination` to memory area `self`.  If `destination` and `self` overlap, behavior is undefined. Applications in which `destination` and `self` might overlap should use `memmove(3)` instead.
    ///
    /// - Parameters:
    ///   - source: The buffer pointer to the source address.
    ///   - n: The number of elements to copy. The stride of `Element` is multiplied.
    @inlinable
    public func copy(from source: UnsafeRawPointer, count n: Int) {
        self.baseAddress!.copy(from: source, count: n)
    }
    
    /// Change the size of the allocation.
    ///
    /// If there is not enough room to enlarge the memory allocation, this method creates a new allocation, copies as much of the old data as will fit to the new allocation, frees the old allocation, and changes `self` to a pointer to the allocated memory.
    ///
    /// When you reallocate memory, always remember to deallocate once you’re finished.
    ///
    /// - Parameters:
    ///   - capacity: The desired capacity, counted in instances of `Element`.
    @inlinable
    public mutating func reallocate(capacity: Int) {
        let ptr = Foundation.realloc(UnsafeMutableRawPointer(self.baseAddress!), capacity * MemoryLayout<Element>.stride)
        precondition(ptr != nil, "Failed to reallocate memory.")
        self = UnsafeMutableBufferPointer(start: ptr!.assumingMemoryBound(to: Element.self), count: capacity)
    }
    
}
