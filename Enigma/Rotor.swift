//
//  Rotor.swift
//  Enigma
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import Foundation


class Rotor {
    enum Error: ErrorType {
        /** Thrown when the initializer is given an invalid series. */
        case InvalidSeries
        case InvalidCharacter
    }

    static let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)

    /** The position of first letter in `series` in the `alphabet`. */
    var position: Int
    /** The series of characters that this rotor cycles through. */
    let series: [Character]!

    convenience init(series: String) throws {
        try self.init(series: Array(series.characters))
    }

    init(series: [Character]) throws {
        self.position = 0
        guard series.count == Rotor.alphabet.count else {
            self.series = nil
            throw Error.InvalidSeries
        }
        self.series = series
    }

    func advance(count: Int = 1) {
        position = (position + count) % Rotor.alphabet.count
    }

    func encode(c: Character) throws -> Character {
        let offset: Int! = Rotor.alphabet.indexOf(c)
        guard offset != nil else {
            throw Error.InvalidCharacter
        }
        return series[(offset + position) % series.count]
    }
}