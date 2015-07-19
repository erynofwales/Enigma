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


class MachineTests: XCTestCase {
    func testThatItTurnsOn() {
        let machine = try! Machine(rotors: [Rotor(.EnigmaI), Rotor(.EnigmaII), Rotor(.EnigmaIII)], reflector: Reflector(.EnigmaB), plugboard: Plugboard())
        print(try! machine.encode("A"))
    }
}


class RotorTests: XCTestCase {
    let rotorSeries = "EKMFLGDQVZNTOWYHXUSPAIBRCJ"
    let rot13Series = "NOPQRSTUVWXYZABCDEFGHIJKLM"

    func makeRotorWithSeries(series: String) -> Rotor! {
        do {
            return try Rotor(series: series)
        } catch let error {
            XCTFail("Unable to create rotor: \(error)")
        }
        return nil
    }

    func testThatUnadvancedSubstitutionWorks() {
        let rotor = makeRotorWithSeries(rotorSeries)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rotorSeries.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }

    func testThatRotorCanAdvanceToRot13() {
        let rotor = makeRotorWithSeries(alphaSeries)
        rotor.advance(13)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rot13Series.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }

    func testThatRotorCanSetToRot13() {
        let rotor = makeRotorWithSeries(alphaSeries)
        rotor.position = 13
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rot13Series.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }

    func testThatRotorCanDoInverseEncoding() {
        let rotor = makeRotorWithSeries(rotorSeries)
        for (plainCharacter, cipherCharacter) in zip(alphaSeries.characters, rotorSeries.characters) {
            do {
                let encodedCharacter = try rotor.inverseEncode(cipherCharacter)
                XCTAssertEqual(encodedCharacter, plainCharacter)
            } catch let error {
                XCTFail("Error inverse-encoding \(cipherCharacter) -> \(plainCharacter): \(error)")
            }
        }
    }

    func testThatRingSettingWorks() {
        let rotor = makeRotorWithSeries(alphaSeries)
        rotor.ringPosition = 1
        let characters = Array(alphaSeries.characters)
        for (index, c) in alphaSeries.characters.enumerate() {
            do {
                let encodedCharacter = try rotor.encode(c)
                XCTAssertEqual(encodedCharacter, characters[(index + 1) % characters.count])
            } catch let error {
                XCTFail("Error encoding with ring setting = 1: \(error)")
            }
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