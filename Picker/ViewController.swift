//
//  ViewController.swift
//  Picker
//
//  Created by Eryn Wells on 2015-07-22.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!

    let alphabets: [String] = ["EKMFLGDQVZNTOWYHXUSPAIBRCJ",
                               "AJDKSIRUXBLHWTMCQGZNPYFVOE",
                               "BDFHJLCPRTXVZNYEIWGAKMUSQO"]

    var pickerViewControllers: [PickerViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        for al in alphabets {
            let picker = PickerViewController()
            picker.alphabet = Array(al.characters)

            self.addChildViewController(picker)
            pickerViewControllers.append(picker)
            stackView.addArrangedSubview(picker.view)
            picker.didMoveToParentViewController(self)
        }
    }
}