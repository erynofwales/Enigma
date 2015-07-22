//
//  MachineViewController.swift
//  Enigma
//
//  Created by Eryn Wells on 2015-07-18.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import UIKit

class MachineViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var outputTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.delegate = self
        //outputTextField.delegate = self
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidEndEditing(textField: UITextField) {
        print("textFieldDidEndEditing")
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        return true
    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === inputTextField {
            var machine: Machine! = nil
            do {
                machine = Machine(rotors: [try Rotor(.EnigmaI), try Rotor(.EnigmaII), try Rotor(.EnigmaIII)], reflector: try Reflector(.EnigmaB), plugboard: Plugboard())
            } catch let error {
                print("Error setting up machine: \(error)")
                return true
            }
            if let inputText = textField.text {
                do {
                    outputTextField.text = try machine.encode(inputText)
                } catch let error {
                    print("Error encoding: \(error)")
                    return true
                }
            }
            return false
        }
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("textFieldShouldClear")
        if textField === inputTextField {
            return true
        }
        return false
    }
}

