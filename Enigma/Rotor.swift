//
//  Rotor.swift
//  Enigma
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import Foundation


protocol Encoder {
    func encode(c: Character) throws -> Character
}


class Cryptor {
    enum Error: ErrorType {
        /** Thrown when encode() encounters a character that is not in the alphabet. */
        case InvalidCharacter(c: Character)
    }

    /** Array of all possible characters to encrypt. */
    static let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
}


/** Rotors are Cryptors that have a position, which offsets the alphabet from the series and changes which character is substituted for a given input. */
class Rotor: Cryptor, Encoder {
    enum Error: ErrorType {
        /** Thrown when the initializer is given an invalid series. */
        case InvalidSeries
    }

    /** The position of first letter in `series` in the `alphabet`. */
    var position: Int = 0

    /** The series of characters that this rotor cycles through. */
    let series: [Character]!

    convenience init(series: String) throws {
        try self.init(series: Array(series.characters))
    }

    init(series: [Character]) throws {
        self.series = series
        super.init()
        guard series.count == Cryptor.alphabet.count else {
            throw Error.InvalidSeries
        }
    }

    func advance(count: Int = 1) {
        position = (position + count) % Rotor.alphabet.count
    }

    func encode(c: Character) throws -> Character {
        let offset: Int! = Rotor.alphabet.indexOf(c)
        guard offset != nil else {
            throw Error.InvalidCharacter(c: c)
        }
        return series[(offset + position) % series.count]
    }
}


/** A Plugboard is a Cryptor that substitutes one character for another based on a set of pairs. A pair of characters is mutually exclusive of other pairs; that is, a character can only belong to one pair. Furthermore, the Plugboard always trades one character for the same character and vice versa. */
class Plugboard: Cryptor, Encoder {
    enum Error: ErrorType {
        case CharacterInMultiplePairs(c: Character)
        case PairContainsSameCharacter(c: Character)
    }

    var pairs: [(Character, Character)]!

    init(pairs: [(Character, Character)] = []) throws {
        super.init()
        try validatePairs(pairs)
        self.pairs = pairs
    }

    func validatePairs(pairs: [(Character, Character)]) throws {
        let alphabetSet = Set(Cryptor.alphabet)
        var charactersSeen = Set<Character>()
        for pair in pairs {
            if !alphabetSet.contains(pair.0) {
                throw Cryptor.Error.InvalidCharacter(c: pair.0)
            }
            if  !alphabetSet.contains(pair.1) {
                throw Cryptor.Error.InvalidCharacter(c: pair.1)
            }
            if pair.0 == pair.1 {
                throw Error.PairContainsSameCharacter(c: pair.0)
            }
            if charactersSeen.contains(pair.0) {
                throw Error.CharacterInMultiplePairs(c: pair.0)
            } else {
                charactersSeen.insert(pair.0)
            }
            if charactersSeen.contains(pair.1) {
                throw Error.CharacterInMultiplePairs(c: pair.1)
            } else {
                charactersSeen.insert(pair.1)
            }
        }
    }

    func encode(c: Character) throws -> Character {
        for pair in pairs {
            if c == pair.0 {
                return pair.1
            }
            if c == pair.1 {
                return pair.0
            }
        }
        // If no pair exists, just return the character itself.
        return c
    }
}