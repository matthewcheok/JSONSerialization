//
//  JSONSerialization.swift
//  JSONSerialization
//
//  Created by Matthew Cheok on 19/6/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

private enum InternalError: ErrorType {
    case CannotFindCharacter(character: Character)
    case MalformedString
}

extension CollectionType {
    private func throwingMap<T>(@noescape transform: (Generator.Element) throws -> T) throws -> [T] {
        var ts: [T] = []
        for x in self {
            ts.append(try transform(x))
        }
        return ts
    }
}

extension String {
    private func splitByCharacter(character: Character) throws -> [String] {
        if self.isEmpty {
            return []
        }
        
        var results: [String] = []
        var arrayCount = 0
        var objectCount = 0
        var stringOpen = false
        
        var start = startIndex, end = startIndex
        while end < endIndex {
            let c = self[end]
            
            switch c {
            case "\"":
                stringOpen = !stringOpen
                
            case "[":
                arrayCount++
                
            case "]":
                arrayCount--
                
            case "{":
                objectCount++
                
            case "}":
                objectCount--
                
            default:
                ()
            }
            
            if c == character
                && !stringOpen
                && arrayCount == 0
                && objectCount == 0 {
                    results.append(self[start..<end])
                    start = end.successor()
            }
            
            if arrayCount < 0 || objectCount < 0 {
                throw InternalError.MalformedString
            }
            
            end = end.successor()
        }
        
        results.append(self[start..<end])
        return results
    }
    
    private func matchesFirstAndLastCharacters(first: Character, _ last: Character) -> Bool {
        guard let f = characters.first else {
            return false
        }
        
        guard let l = characters.last else {
            return false
        }
        
        return f == first && l == last
    }
    
    private func trimFirstAndLastCharacters() -> String {
        if endIndex > startIndex.successor() {
            return self[startIndex.successor()..<endIndex.predecessor()]
        }
        else {
            return ""
        }
    }
}

public struct JSONSerialization {
    typealias JSONObject = [String: Any]
    typealias JSONArray = [Any]
    
    public struct JSONNull {
        public init() {}
    }
    
    enum DecodeError: ErrorType {
        case MalformedJSON
    }
    
    enum EncodeError: ErrorType {
        case IncompatibleType
    }
    
    public static func decode(JSON: String) throws -> Any {
        let trimmed = JSON.trimWhiteSpaceAndNewline()
        
        // empty
        if trimmed.isEmpty {
            throw DecodeError.MalformedJSON
        }
            
            // object
        else if trimmed.matchesFirstAndLastCharacters("{", "}") {
            // split by key, value pairs
            let pairs: [String]
            do {
                pairs = try trimmed.trimFirstAndLastCharacters().splitByCharacter(",")
            }
            catch {
                throw DecodeError.MalformedJSON
            }
            
            var object: [String: Any] = [:]
            for pair in pairs {
                // split into tokens
                let tokens: [String]
                do {
                    tokens = try pair.trimWhiteSpaceAndNewline().splitByCharacter(":")
                }
                catch {
                    throw DecodeError.MalformedJSON
                }
                
                // pair must have exactly 2 tokens
                guard tokens.count == 2 else {
                    throw DecodeError.MalformedJSON
                }
                
                // first token in pair must be a string
                guard tokens[0].matchesFirstAndLastCharacters("\"", "\"") else {
                    throw DecodeError.MalformedJSON
                }
                
                let key = tokens[0].trimFirstAndLastCharacters()
                object[key] = try decode(tokens[1])
            }
            
            return object
        }
            
            // array
        else if trimmed.matchesFirstAndLastCharacters("[", "]") {
            // split into tokens
            let tokens: [String]
            do {
                tokens = try trimmed.trimFirstAndLastCharacters().splitByCharacter(",")
            }
            catch {
                throw DecodeError.MalformedJSON
            }
            
            return try tokens.throwingMap { try decode($0) }
        }
            
            // boolean literals
        else if trimmed == "true" {
            return true
        }
        else if trimmed == "false" {
            return false
        }
            
            // integer
        else if let number = Int(trimmed) {
            return number
        }
            
            // double
        else if let number = Double(trimmed) {
            return number
        }
            
            // null
        else if trimmed == "null" {
            return JSONNull()
        }
            
            // string
        else {
            return trimmed
        }
    }
    
    public static func encode(JSON: Any, prettyPrint: Bool = false) throws -> String {
        if prettyPrint {
            let result = try _encodePretty(JSON)
            return "\n".join(result)
        }
        else {
            return try _encode(JSON)
        }
    }
    
    private static func _flattenWithCommas(array: [[String]]) -> [String] {
        var result = [String]()
        for (index, sub) in array.enumerate() {
            if index < array.count-1 {
                let last = sub.count-1
                result.extend(sub[0..<last])
                result.append(sub[last] + ", ")
            }
            else {
                result.extend(sub)
            }
        }
        return result
    }
    
    private static func _encodePretty(JSON: Any) throws -> [String] {
        let kIndentationString = "   "
        
        // object
        if let object = JSON as? JSONObject {
            let result = try object.throwingMap {
                (key, value) -> [String] in
                let encoded = try _encodePretty(value)
                return ["\"\(key)\": " + encoded[0]] + encoded[1..<encoded.count]
            }
            let indented = _flattenWithCommas(result).map { kIndentationString + $0 }
            return ["{"] + indented + ["}"]
        }
            
            // array
        else if let array = JSON as? JSONArray {
            // nested array of lines
            let result = try array.throwingMap { try _encodePretty($0) }
            let indented = _flattenWithCommas(result).map { kIndentationString + $0 }
            return ["["] + indented + ["]"]
        }
            
            // others
        else {
            return [try _encode(JSON)]
        }
    }
    
    private static func _encode(JSON: Any) throws -> String {
        // object
        if let object = JSON as? JSONObject {
            let result = try object.throwingMap {
                (key, value) in
                return "\"\(key)\": " + (try _encode(value))
            }
            return "{" + ", ".join(result) + "}"
        }
            
            // array
        else if let array = JSON as? JSONArray {
            let result = try array.throwingMap { try _encode($0) }
            return "[" + ", ".join(result) + "]"
        }
            
            // bool
        else if let bool = JSON as? Bool {
            return bool ? "true" : "false"
        }
            
            // integer
        else if let int = JSON as? Int {
            return int.description
        }
            
            // double
        else if let double = JSON as? Double {
            return double.description
        }
            
            // null
        else if JSON is JSONNull {
            return "null"
        }
            
            // string
        else if let string = JSON as? String {
            return string
        }
            
        else {
            throw EncodeError.IncompatibleType
        }
    }
}