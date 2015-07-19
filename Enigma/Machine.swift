//
//  Machine.swift
//  Enigma
//
//  Created by Eryn Wells on 7/18/15.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import Foundation


class Machine {
    let rotors: [Rotor]
    let reflector: Reflector
    let plugboard: Plugboard

    var rotorAdvanceEnabled: Bool = true

    init(rotors: [Rotor], reflector: Reflector, plugboard: Plugboard) {
        self.rotors = rotors
        self.reflector = reflector
        self.plugboard = plugboard
    }

    func encode(c: Character) throws -> Character {
        if rotorAdvanceEnabled {
            advanceRotors()
        }
        var output = c
        output = try plugboard.encode(output)
        for rotor in rotors.reverse() {
            output = try rotor.encode(output)
        }
        output = try reflector.encode(output)
        for rotor in rotors {
            output = try rotor.inverseEncode(output)
        }
        output = try plugboard.inverseEncode(output)
        return output
    }

    func encode(string: String) throws -> String {
        var output = ""
        for character in string.characters {
            output += String(try encode(character))
        }
        return output
    }

    func advanceRotors() {
        var shouldAdvance = true    // Always advance the first rotor
        for rotor in rotors.reverse() {
            if shouldAdvance {
                rotor.advance()
            }
            // Advance the next rotor if this rotor is in the notch position.
            if let notch = rotor.notch {
                shouldAdvance = rotor.position == notch
            } else {
                shouldAdvance = false
            }
        }
    }
}