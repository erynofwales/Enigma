//
//  RotorViewController.swift
//  Enigma
//
//  Created by Eryn Wells on 2015-07-19.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import UIKit

class RotorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rotorPickerView: UIPickerView!

    let rotor: Rotor

    init(rotor: Rotor) {
        self.rotor = rotor
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Rotor.alphabet.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(Rotor.alphabet[row])
    }
}
