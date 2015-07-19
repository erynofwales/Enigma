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


/** Rotors are FixedRotors that _not_ fixed. They have a variable position, which offsets the alphabet from the series and changes which character is substituted for a given input. Rotors also have a variable `ringPosition`, _Ringstellung_ in German, which offsets the alphabet further. The Ringstellung was set as part of the machine setup, while the position changed based on how many characters were encoded. */
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
        // TODO: The SwissK ETW was the same as the Rocket ETW. How to represent this in an enum?
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
        case EnigmaETW = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        // M4 fourth roters, used with the "thin" reflectors
        case EnigmaM4R2Beta = "LEYJVCNIXWPBQMDRTAKZGFUHOS"
        case EnigmaM4R2Gamma = "FSOKANUERHMBTIYCWLQPZXVGJD"
    }

    override init(series: [Character]) throws {
        try super.init(series: series)
        rotatedSeries = series
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
        didSet {
            rotatedSeries = Array(series[ringPosition..<series.endIndex]) + Array(series[0..<ringPosition])
        }
    }

    /** An offset at which the adjacent rotor should be advanced by one position. */
    var notch: Int? {
        willSet {
            if let newInt = newValue {
                self.notch = newInt % series.count
            }
        }
    }

    private var rotatedSeries: [Character]!

    func advance(count: Int = 1) {
        position = (position + count) % series.count
    }

    func getIndexAdjustedForRotation(c: Character) throws -> Int {
        let entryPosition = try indexOfInAlphabet(c)
        let adjustedPosition = (entryPosition + position) % Cryptor.alphabet.count
        return adjustedPosition
    }

    func getInverseIndexAdjustedForRotation(c: Character) throws -> Int {
        let entryPosition = try indexOfInAlphabet(c)
        let adjustedPosition = (entryPosition + position) % Cryptor.alphabet.count
        let adjustedChar = Cryptor.alphabet[adjustedPosition]
        let inversePosition = try indexOfInSeries(adjustedChar)
        return inversePosition
    }

    func convertToExitCharacter(c: Character) throws -> Character {
        let encodedPosition = try indexOfInAlphabet(c)
        var adjustedPosition = (encodedPosition - position) % Cryptor.alphabet.count
        if adjustedPosition < 0 {
            adjustedPosition += Cryptor.alphabet.count
        }
        return Cryptor.alphabet[adjustedPosition]
    }

    func convertToInverseExitCharacter(c: Character) throws -> Character {
        let encodedPosition = try indexOfInAlphabet(c)
        var adjustedPosition = (encodedPosition - position) % Cryptor.alphabet.count
        if adjustedPosition < 0 {
            adjustedPosition += Cryptor.alphabet.count
        }
        return Cryptor.alphabet[adjustedPosition]
    }

    override func encode(c: Character) throws -> Character {
        let adjustedPosition = try getIndexAdjustedForRotation(c)
        let encodedChar = rotatedSeries[adjustedPosition]
        let finalChar = try convertToExitCharacter(encodedChar)
        print("Encode (pos \(position): \(c) -> \(finalChar)")
        return finalChar
    }

    override func inverseEncode(c: Character) throws -> Character {
        let adjustedPosition = try getInverseIndexAdjustedForRotation(c)
        let adjustedChar = rotatedSeries[adjustedPosition]
        let lookMeUp = try indexOfInSeries(adjustedChar)
        let decodedChar = Cryptor.alphabet[lookMeUp]
        let finalChar = try convertToInverseExitCharacter(decodedChar)
        print("Encode (pos \(position): \(c) -> \(finalChar)")
        return finalChar
    }

    override func indexOfInSeries(c: Character) throws -> Int {
        if let index = rotatedSeries.indexOf(c) {
            return index
        } else {
            throw EncoderError.CharacterNotInSeries(ch: c)
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
        // Plugboards are symmetric. That is, if "A" -> "H", then "H" -> "A".
        return try encode(c)
    }
}