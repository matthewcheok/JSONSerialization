//
//  String.swift
//  JSONSerialization
//
//  Created by Matthew Cheok on 19/6/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

extension Character {
    public static var newlineCharacterSet: Set<Character> {
        return ["\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}", "\u{0085}"]
    }
    
    public static var whiteSpaceCharacterSet: Set<Character> {
        return ["\u{0020}", "\u{0009}"]
    }
    
    public static var whiteSpaceAndNewlineCharacterSet: Set<Character> {
        return self.newlineCharacterSet.union(self.whiteSpaceCharacterSet)
    }
}

extension String {
    public func trimCharactersInSet(characterSet: Set<Character>) -> String {
        var startIndex = self.startIndex
        var endIndex = self.endIndex
        
        while startIndex < endIndex && characterSet.contains(self[startIndex]) {
            startIndex = startIndex.successor()
        }
        
        while endIndex > startIndex && characterSet.contains(self[endIndex.predecessor()]) {
            endIndex = endIndex.predecessor()
        }
        
        return self[startIndex..<endIndex]
    }
    
    public func trimWhiteSpaceAndNewline() -> String {
        return trimCharactersInSet(Character.whiteSpaceAndNewlineCharacterSet)
    }
}

public func +(lhs: String.CharacterView.Index, rhs: Int) -> String.CharacterView.Index {
    return advance(lhs, rhs)
}