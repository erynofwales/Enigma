//
//  EnigmaTests.swift
//  EnigmaTests
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import XCTest
@testable import Enigma


class EnigmaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}


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