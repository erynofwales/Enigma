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
        let rotor = try! Rotor(series: rotorSeries)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rotorSeries.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }

    func testThatRotorCanAdvanceToRot13() {
        let rot13Series = "NOPQRSTUVWXYZABCDEFGHIJKLM"
        let rotor = try! Rotor(series: alphaSeries)
        rotor.advance(13)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rot13Series.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }

    func testThatRotorCanSetToRot13() {
        let rot13Series = "NOPQRSTUVWXYZABCDEFGHIJKLM"
        let rotor = try! Rotor(series: alphaSeries)
        rotor.position = 13
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rot13Series.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }
}


class ReflectorTests: XCTestCase {
    func testThatReflectorReflects() {
        var reflector: Reflector! = nil
        do {
            reflector = try Reflector(series: Reflector.Wiring.EnigmaA.rawValue)
        } catch let error {
            XCTFail("Error creating reflector: \(error)")
        }
        do {
            let encodeA = try reflector.encode("A")
            let encodeE = try reflector.encode("E")
            XCTAssertEqual(encodeA, "E")
            XCTAssertEqual(encodeE, "A")
        } catch {
            XCTFail("Reflector encoding failed")
        }
    }
}


class PlugboardTests: XCTestCase {
    func testThatEmptyPlugboardPassesThroughAllCharacters() {
        let plugboard = Plugboard()
        for c in alphaSeries.characters {
            XCTAssertEqual(try! plugboard.encode(c), c)
        }
    }

    func testThatPlugboardPairsAreBidirectional() {
        let plugboard = Plugboard()
        plugboard.addPlug("A", b: "H")
        XCTAssertEqual(try! plugboard.encode("A"), "H")
        XCTAssertEqual(try! plugboard.encode("H"), "A")
    }
}