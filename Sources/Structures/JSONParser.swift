
//
//  JSONParser.swift
//  The Stratum Module
//
//  Created by Vaida on 8/17/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import OSLog


/// The parser that can handle json and throw detailed errors.
///
/// - Tip: When working with top-level arrays, use `[JSONParser](data:)` initializer.
///
/// ## Components
///
/// There are four different ways to access different components.
///
/// | Component | function |
/// | ----------- | ----------- |
/// | obtain value | ``value(for:)`` |
/// | obtain object | ``object(_:)`` |
/// | obtain array of values | ``array(_:type:)`` |
/// | obtain array of objects | ``array(_:)`` |
///
/// With ``subscript(_:_:)`` similar to ``value(for:)``.
///
/// > Example:
/// >
/// > Decoding a json tree.
/// > ```swift
/// > let json = {
/// >     "pi": 3.1415
/// > }
/// >
/// > let parser = try JSONParser(data: json.data())
/// > try parser.value("pi") // 3.1415
/// > ```
///
/// > Throws:
/// > If there exists an error:
/// > ```swift
/// > try parser.value("pi", type: .bool)
/// > ```
/// > The parser would throw the error of ``ParserError/Code/typeMismatch(expected:actual:)``.
public final class JSONParser: CustomStringConvertible, @unchecked Sendable {
    
    private let key: String
    
    /// The dictionary that made up the object.
    private let dictionary: [String : Any]
    
    
    /// The pretty printed json object.
    public var description: String {
        guard let json = try? JSONSerialization.data(withJSONObject: self.dictionary, options: [.prettyPrinted]),
              let string = String(data: json, encoding: .utf8) else { return "Invalid JSON Parser Object" }
        return string
    }
    
    /// The keys in the current parser.
    public var keys: Dictionary<String, Any>.Keys {
        self.dictionary.keys
    }
    
    
    /// Creates the parser with the json data.
    ///
    /// - Parameters:
    ///   - data: A data object containing JSON data.
    ///   - options: Options for reading the JSON data and creating the Foundation objects.
    ///
    /// - throws: JSON parsing error.
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        let dictionary = object as! [String : Any]
        self.dictionary = dictionary
        self.key = "root"
    }
    
    /// Creates the parser with the json data.
    ///
    /// - Parameters:
    ///   - string: A data object containing JSON data.
    ///   - options: Options for reading the JSON data and creating the Foundation objects.
    ///
    /// - throws: JSON parsing error.
    public init(string: String, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: options)
        let dictionary = object as! [String : Any]
        self.dictionary = dictionary
        self.key = "root"
    }
    
    
    fileprivate init(key: String, dictionary: [String : Any]) {
        self.key = key
        self.dictionary = dictionary
    }
    
    
    /// Generates a JSON document using the container this parser.
    public func data() throws -> Data {
        try JSONSerialization.data(withJSONObject: self.dictionary)
    }
    
    
    /// Returns a bool determining if the parser has the given `key`.
    public func hasKey(_ key: String) -> Bool {
        self.dictionary[key] != nil
    }
    
    
    /// Assume this element is an object, and returns the value associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "pi": 3.1415
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > let value: Double = try parser.value("pi") // 3.1415
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    public func value<T>(for key: String) throws(ParserError) -> T {
        guard let value = dictionary[key] else { throw .init(code: .keyError, key: key, details: self.description) }
        guard let value = value as? T else { throw .init(code: .typeMismatch(expected: "\(T.self)", actual: "\(Swift.type(of: value))"), key: key, details: self.description) }
        return value
    }
    
    /// Assume this element is an object, and returns the object associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "Double" : {
    /// >         "pi": 3.1415
    /// >     }
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser.object("Double") // { "pi": 3.1415 }
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    public func object(_ key: String) throws(ParserError) -> JSONParser {
        guard let object = dictionary[key] else { throw .init(code: .keyError, key: key, details: self.description) }
        guard let dictionary = object as? [String: Any] else { throw .init(code: .typeMismatch(expected: "JSONParser", actual: "\(Swift.type(of: object))"), key: key, details: self.description) }
        return JSONParser(key: key, dictionary: dictionary)
    }
    
    /// Assume this element is an object, and returns the array of objects associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "values" : [{
    /// >         "pi": 3.1415
    /// >     }]
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > parser.array("values") // [{ "pi": 3.1415 }]
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    public func array(_ key: String) throws(ParserError) -> [JSONParser] {
        guard let object = dictionary[key] else { throw .init(code: .keyError, key: key, details: self.description) }
        guard let dictionaries = object as? [[String: Any]] else { throw .init(code: .typeMismatch(expected: "[JSONParser]", actual: "\(Swift.type(of: object))"), key: key, details: self.description) }
        return dictionaries.map { JSONParser(key: key, dictionary: $0) }
    }
    
    /// Assume this element is an object, and returns the array of `T` associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "values" : [
    /// >         3, 4, 5, 6
    /// >     ]
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser.array("values", type: .numeric) // [3, 4, 5, 6]
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - type: The type of each element in the array.
    public func array<T>(_ key: String, type: Object<T>) throws(ParserError) -> [T] {
        guard type.key != .parser else { return try self.array(key) as! [T] }
        guard let values = dictionary[key] else { throw .init(code: .keyError, key: key, details: self.description) }
        guard let values = values as? [T] else { throw .init(code: .typeMismatch(expected: "[\(T.self)]", actual: "\(Swift.type(of: values))"), key: key, details: self.description) }
        return values
    }
    
    /// Assume this element is an object, and returns the value associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "pi": 3.1415
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser["pi", .numeric] // 3.1415
    /// > ```
    ///
    /// This is similar to ``value(for:)``.
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - type: The type of the returned value.
    public subscript<T>(_ key: String, type: Object<T> = .string) -> T {
        get throws {
            guard type.key != .parser else { return try self.object(key) as! T }
            return try self.value(for: key)
        }
    }
    
    
    /// The only error thrown by ``JSONParser``.
    public struct ParserError: GenericError {
        
        /// The error code
        public let code: Code
        
        /// The JSON key that caused the error
        public let key: String
        
        /// The JSON string
        public let details: String
        
        public var title: String {
            switch self.code {
            case .keyError:
                "JSON Parsing Error: Key Not Found"
            case .typeMismatch:
                "JSON Parsing Error: Type Mismatch"
            }
        }
        
        public var message: String {
            switch self.code {
            case .keyError:
                "The key \"\(key)\" not found."
            case .typeMismatch(let expected, let actual):
                if actual == "NSNull" {
                    "The data associated with \"\(key)\" is `nil`."
                } else {
                    "The data associated with \"\(key)\" is \(actual), expected \(expected)."
                }
            }
        }
        
        public enum Code: Equatable, Sendable {
            
            /// The error when the given key to the dictionary is not fount.
            case keyError
            
            /// The error when the given key to the dictionary is associated with a value, but the type does not match.
            ///
            /// - Parameters:
            ///   - type: The expected type.
            ///   - actual: The found type
            case typeMismatch(expected: String, actual: String)
            
        }
    }
    
    /// The type of objects extracted from JSON.
    public struct Object<T> {
        
        fileprivate let key: Key
        
        
        /// Indicating extraction of `String`.
        public static var string: Object<String> { .init(key: .string) }
        
        /// Indicating extraction of `Double`.
        public static var numeric: Object<Double> { .init(key: .numeric) }
        
        /// Indicating extraction of `Int`.
        public static var integer: Object<Int> { .init(key: .integer) }
        
        /// Indicating extraction of `Bool`.
        public static var bool: Object<Bool> { .init(key: .bool) }
        
        /// Indicating extraction of anything.
        public static var any: Object<Any> { .init(key: .any) }
        
        /// Indicating extraction of `JSONParser`.
        public static var parser: Object<JSONParser> { .init(key: .parser) }
        
    }
    
    fileprivate enum Key: String, Equatable {
        case string
        case numeric
        case integer
        case bool
        case any
        case parser
    }
    
}


extension JSONParser: Codable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.key, forKey: .key)
        try container.encode(self.data(), forKey: .data)
    }
    
    public convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            key: container.decode(String.self, forKey: .key),
            dictionary: JSONSerialization.jsonObject(with: container.decode(Data.self, forKey: .data)) as! [String : Any]
        )
    }
    
    enum CodingKeys: CodingKey {
        case key
        case data
    }
    
}


extension Array where Element == JSONParser {
    
    /// Creates the parser array with the json data.
    ///
    /// - Parameters:
    ///   - data: A data object containing JSON data.
    ///   - options: Options for reading the JSON data and creating the Foundation objects.
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        guard let dictionaries = object as? [[String: Any]] else {
            throw JSONParser.ParserError(code: .typeMismatch(expected: "[JSONParser]", actual: "\(Swift.type(of: object))"), key: "", details: String(data: data, encoding: .utf8) ?? data.description)
        }
        self = dictionaries.map { JSONParser(key: "root", dictionary: $0) }
    }
    
}
