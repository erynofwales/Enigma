//
//  Enigma.swift
//  Enigma
//
//  Created by Eryn Wells on 7/18/15.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import Foundation


class Enigma {
    let rotors: [Rotor]
    let reflector: Reflector
    let plugboard: Plugboard

    init(rotors: [Rotor], reflector: Reflector, plugboard: Plugboard) {
        self.rotors = rotors
        self.reflector = reflector
        self.plugboard = plugboard
    }

    func encode(c: Character) throws -> Character {
        var output = c
        output = try plugboard.encode(output)
        for rotor in rotors {
            output = try rotor.encode(output)
        }
        output = try reflector.encode(output)
        for rotor in rotors.reverse() {
            output = try rotor.encode(output)
        }
        output = try plugboard.encode(output)
        advanceRotors()
        return output
    }

    func encode(string: String) throws -> String {
        var output = ""
        for character in string.characters {
            output += String(try encode(character))
        }
        return output
    }

    private func advanceRotors() {

    }
}