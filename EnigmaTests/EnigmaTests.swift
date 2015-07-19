//
//  EnigmaTests.swift
//  EnigmaTests
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import XCTest
@testable import Enigma

let alphaSeries = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

class RotorTests: XCTestCase {
    let rotorSeries = "EKMFLGDQVZNTOWYHXUSPAIBRCJ"

    func testThatUnadvancedSubstitutionWorks() {
        let rotor = try! Enigma.Rotor(series: rotorSeries)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rotorSeries.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }

    func testThatRotorCanDoRot13() {
        let rot13Series = "NOPQRSTUVWXYZABCDEFGHIJKLM"
        let rotor = try! Enigma.Rotor(series: alphaSeries)
        rotor.advance(13)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rot13Series.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }
}


class PlugboardTests: XCTestCase {
    func testThatEmptyPlugboardPassesThroughAllCharacters() {
        let plugboard = try! Enigma.Plugboard()
        for c in alphaSeries.characters {
            XCTAssertEqual(try! plugboard.encode(c), c)
        }
    }

    func testThatPlugboardPairsAreBidirectional() {
        let plugboard = try! Enigma.Plugboard(pairs: [("A", "H")])
        XCTAssertEqual(try! plugboard.encode("A"), "H")
        XCTAssertEqual(try! plugboard.encode("H"), "A")
    }
}