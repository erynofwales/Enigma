//
//  Components.swift
//  Enigma
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import Foundation


enum EncoderError: ErrorType {
    /** Thrown when an input character is found that is not in the alphabet. */
    case InvalidCharacter(ch: Character)
}


protocol Encoder {
    func encode(c: Character) throws -> Character
}


class Cryptor {
    /** Array of all possible characters to encrypt. */
    static let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
}


class FixedRotor: Cryptor, Encoder {
    enum Error: ErrorType {
        /** Thrown when the initializer is given an invalid series. */
        case InvalidSeries
    }

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

    func encode(c: Character) throws -> Character {
        if let offset = FixedRotor.alphabet.indexOf(c) {
            return series[offset]
        } else {
            throw EncoderError.InvalidCharacter(ch: c)
        }
    }
}


/** Rotors are FixedRotors that have a variable position, which offsets the alphabet from the series and changes which character is substituted for a given input. */
class Rotor: FixedRotor {
    /** The position of first letter in `series` in the `alphabet`. */
    var position: Int = 0 {
        willSet {
            self.position = newValue % Cryptor.alphabet.count
        }
    }

    func advance(count: Int = 1) {
        position = (position + count) % Rotor.alphabet.count
    }

    override func encode(c: Character) throws -> Character {
        if let offset = Rotor.alphabet.indexOf(c) {
            return series[(offset + position) % series.count]
        } else {
            throw EncoderError.InvalidCharacter(ch: c)
        }
    }
}


class Reflector: FixedRotor {
    enum Wiring: String {
        case EnigmaA = "EJMZALYXVBWFCRQUONTSPIKHGD"
        case EnigmaB = "YRUHQSLDPXNGOKMIEBFZCWVJAT"
        case EnigmaC = "FVPJIAOYEDRZXWGCTKUQSBNMHL"
        case EnigmaM4R1BThin = "ENKQAUYWJICOPBLMDXZVFTHRGS"
        case EnigmaM4R1CThin = "RDOBJNTKVEHMLFCWZAXGYIPSUQ"
    }

    enum Error: ErrorType {
        case InvalidReflection
    }

    override init(series: [Character]) throws {
        try super.init(series: series)
        try validateReflector(series)
    }

    func validateReflector(series: [Character]) throws {
        for (offset, c) in series.enumerate() {
            if let alphabetOffset = Reflector.alphabet.indexOf(c) {
                if series[alphabetOffset] != Reflector.alphabet[offset] {
                    throw Error.InvalidReflection
                }
            } else {
                throw EncoderError.InvalidCharacter(ch: c)
            }
        }
    }
}


/** A Plugboard is a Cryptor that substitutes one character for another based on a set of pairs. A pair of characters is mutually exclusive of other pairs; that is, a character can only belong to one pair. Furthermore, the Plugboard always trades one character for the same character and vice versa. */
class Plugboard: Cryptor, Encoder {
    private(set) var plugs: [Character: Character] = [:]

    func addPlug(a: Character, b: Character) {
        plugs[a] = b
        plugs[b] = a
    }

    func encode(c: Character) throws -> Character {
        if let output = plugs[c] {
            return output
        } else if Plugboard.alphabet.contains(c) {
            return c
        } else {
            throw EncoderError.InvalidCharacter(ch: c)
        }
    }
}