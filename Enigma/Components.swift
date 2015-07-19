//
//  Components.swift
//  Enigma
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import Foundation


enum EncoderError: ErrorType {
    /** Input character is not in the alphabet. */
    case CharacterNotInAlphabet(ch: Character)
    /** Input character is not found in a rotor's series. */
    case CharacterNotInSeries(ch: Character)
}


protocol Encoder {
    func encode(c: Character) throws -> Character
    func inverseEncode(c: Character) throws -> Character
}


class Cryptor {
    /** Array of all possible characters to encrypt. */
    static let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)

    func indexOfInAlphabet(c: Character) throws -> Int {
        if let index = Cryptor.alphabet.indexOf(c) {
            return index
        } else {
            throw EncoderError.CharacterNotInAlphabet(ch: c)
        }
    }
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
        return series[try indexOfInAlphabet(c)]
    }

    func inverseEncode(c: Character) throws -> Character {
        return Cryptor.alphabet[try indexOfInSeries(c)]
    }

    func indexOfInSeries(c: Character) throws -> Int {
        if let index = series.indexOf(c) {
            return index
        } else {
            throw EncoderError.CharacterNotInSeries(ch: c)
        }
    }
}


/** Rotors are FixedRotors that have a variable position, which offsets the alphabet from the series and changes which character is substituted for a given input. */
class Rotor: FixedRotor {
    /** Standard rotor wirings for various iterations of Enigma machine. Most Enigma machines had three rotors in place. Some variations also had additional rotors that could be swapped in. UKW is the reflector, the _Umkehrwalze_ in German. ETW is the entry plate, the _Eintrittswalze_ in German. The ETW was a simple pass-through in the German Enigma machine, but in other variations did another substitution. */
    enum Wiring: String {
        // Commercial Enigma
        case CommercialI = "DMTWSILRUYQNKFEJCAZBPGXOHV"
        case CommercialII = "HQZGPJTMOBLNCIFDYAWVEUSRKX"
        case CommercialIII = "UQNTLSZFMREHDPXKIBVYGJCWOA"
        // German Railway
        case RocketI = "JGDQOXUSCAMIFRVTPNEWKBLZYH"
        case RocketII = "NTZPSFBOKMWRCJDIVLAEYUXHGQ"
        case RocketIII = "JVIUBHTCDYAKEQZPOSGXNRMWFL"
        case RocketUKW = "QYHOGNECVPUZTFDJAXWMKISRBL"
        case RocketETW = "QWERTZUIOASDFGHJKPYXCVBNML"
        // Swiss K
        case SwissKI = "PEZUOHXSCVFMTBGLRINQJWAYDK"
        case SwissKII = "ZOUESYDKFWPCIQXHMVBLGNJRAT"
        case SwissKIII = "EHRVXGAOBQUSIMZFLYNWKTPDJC"
        case SwissKUKW = "IMETCGFRAYSQBZXWLHKDVUPOJN"
        //case SwissKETW = "QWERTZUIOASDFGHJKPYXCVBNML"
        // German Army/Navy Enigma
        case EnigmaI = "EKMFLGDQVZNTOWYHXUSPAIBRCJ"
        case EnigmaII = "AJDKSIRUXBLHWTMCQGZNPYFVOE"
        case EnigmaIII = "BDFHJLCPRTXVZNYEIWGAKMUSQO"
        case EnigmaM3IV = "ESOVPZJAYQUIRHXLNFTGKDCMWB"
        case EnigmaM3V = "VZBRGITYUPSDNHLXAWMJQOFECK"
        case EnigmaM4VI = "JPGVOUMFYQBENHZRDKASXLICTW"
        case EnigmaM4VII = "NZJHGRCXMYSWBOUFAIVLPEKQDT"
        case EnigmaM4VIII = "FKQHTLXOCBJSPDZRAMEWNIUYGV"
        case EnigmaM4R2Beta = "LEYJVCNIXWPBQMDRTAKZGFUHOS"
        case EnigmaM4R2Gamma = "FSOKANUERHMBTIYCWLQPZXVGJD"
        case EnigmaETW = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }

    convenience init(_ wiring: Wiring) throws {
        try self.init(series: wiring.rawValue)
    }

    /** The position of first letter in `series` in the `alphabet`. */
    var position: Int = 0 {
        willSet {
            self.position = newValue % series.count
        }
    }

    /** Ring position, the Ringstellung. This offsets the alphabet. */
    var ringPosition: Int = 0 {
        willSet {
            self.ringPosition = newValue % series.count
        }
    }

    func advance(count: Int = 1) {
        position = (position + count) % Rotor.alphabet.count
    }

    override func encode(c: Character) throws -> Character {
        return series[(try indexOfInAlphabet(c) + ringPosition + position) % series.count]
    }

    override func inverseEncode(c: Character) throws -> Character {
        return Cryptor.alphabet[(try indexOfInSeries(c) + ringPosition + position) % Rotor.alphabet.count]
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

    convenience init(_ wiring: Wiring) throws {
        try self.init(series: wiring.rawValue)
    }

    override init(series: [Character]) throws {
        try super.init(series: series)
        try validateReflector(series)
    }

    func validateReflector(series: [Character]) throws {
        for (offset, c) in series.enumerate() {
            if series[try indexOfInAlphabet(c)] != Cryptor.alphabet[offset] {
                throw Error.InvalidReflection
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
            throw EncoderError.CharacterNotInAlphabet(ch: c)
        }
    }

    func inverseEncode(c: Character) throws -> Character {
        return try encode(c)
    }
}