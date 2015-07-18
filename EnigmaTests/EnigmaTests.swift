//
//  EnigmaTests.swift
//  EnigmaTests
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import XCTest
@testable import Enigma

class RotorTests: XCTestCase {
    let rotorSeries = "EKMFLGDQVZNTOWYHXUSPAIBRCJ"
    var rotor: Enigma.Rotor!

    override func setUp() {
        rotor = try! Enigma.Rotor(series: rotorSeries)
    }

    override func tearDown() {
        rotor = nil
    }

    func testThatUnadvancedSubstitutionWorks() {
        for (plainCharacter, cipherCharacter) in zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters, rotorSeries.characters) {
            XCTAssertEqual(try! rotor.encode(plainCharacter), cipherCharacter)
        }
    }
}