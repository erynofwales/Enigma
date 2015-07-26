//
//  PickerViewController.swift
//  Picker
//
//  Created by Eryn Wells on 2015-07-23.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {
    var alphabet: [Character] = [] {
        didSet {
            if let picker = picker {
                picker.reloadComponent(0)
            }
        }
    }

    private let pickerMax = 10000

    @IBOutlet private weak var picker: UIPickerView!
    @IBOutlet private weak var pickerPositionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let middle = pickerMax / 2
        picker.selectRow(middle - (middle % alphabet.count), inComponent: 0, animated: false)
        updatePositionLabel()
    }

    private func updatePositionLabel() {
        self.pickerPositionLabel.text = String(picker.selectedRowInComponent(0) % alphabet.count)
    }

    @IBAction func advance() {
        picker.selectRow(picker.selectedRowInComponent(0) + 1, inComponent: 0, animated: true)
        updatePositionLabel()
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerMax
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updatePositionLabel()
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if alphabet.count == 0 {
            return nil
        }
        return String(alphabet[row % alphabet.count])
    }
}
