//
//  PlugboardViewController.swift
//  Plugboard
//
//  Created by Eryn Wells on 7/25/15.
//  Copyright © 2015 Eryn Wells. All rights reserved.
//

import UIKit

class PlugboardViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var alphabet: [Character]? = nil {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    private var plugViews: [PlugLineView] = []

    convenience init(alphabet: [Character]) {
        self.init(nibName: nil, bundle: nil)
        self.alphabet = alphabet
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
    }

    @IBAction func connectPlugsPanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            print("drag began")
            let plugView = PlugLineView(frame: view.bounds)
            let start = recognizer.locationInView(self.view)
            let translation = recognizer.translationInView(self.view)
            plugView.startPoint = start
            plugView.endPoint = CGPoint(x: start.x + translation.x, y: start.y + translation.y)
            view.addSubview(plugView)
            plugViews.append(plugView)
        case .Changed:
            print("drag changed")
            if let plugView = plugViews.last {
                if let start = plugView.startPoint {
                    let translation = recognizer.translationInView(self.view)
                    plugView.endPoint = CGPoint(x: start.x + translation.x, y: start.y + translation.y)
                }
            }
        case .Ended:
            print("drag ended")
            if let plugView = plugViews.last {
                if let start = plugView.startPoint {
                    let translation = recognizer.translationInView(self.view)
                    plugView.endPoint = CGPoint(x: start.x + translation.x, y: start.y + translation.y)
                }
            }
        case .Failed:
            print("drag failed")
        case .Cancelled:
            print("drag cancelled")
        case .Possible:
            print("drag possible")
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let alphabet = alphabet {
            return alphabet.count
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlugCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
        if let plugCell = cell as? PlugCollectionViewCell, alphabet = alphabet {
            plugCell.label.text = String(alphabet[indexPath.row])
        }
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if let size = sizeOfCellInCollectionView(collectionView) {
            let lineSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: section)
            let verticalInset = CGFloat(collectionView.bounds.height - lineSpacing - size.height * 2) / 2.0
            return UIEdgeInsets(top: verticalInset, left: 0.0, bottom: verticalInset, right: 0.0)
        }
        return UIEdgeInsets()
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let size = sizeOfCellInCollectionView(collectionView) {
            return size
        }
        return CGSize()
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if sizeOfCellInCollectionView(collectionView) != nil {
            return 10
        }
        return 0
    }

    private func sizeOfCellInCollectionView(collectionView: UICollectionView) -> CGSize? {
        if let alphabet = alphabet {
            if alphabet.count == 0 {
                return nil
            }
            let columns = CGFloat(ceil(Double(alphabet.count) / 2.0))
            let size = floor(collectionView.bounds.width / columns)
            return CGSize(width: size, height: size)
        }
        return nil
    }
}


class PlugCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PlugCell"
    @IBOutlet weak var label: UILabel!
}


class PlugLineView: UIView {
    var startPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    var endPoint: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }

    private func initCommon() {
        opaque = false
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = false
    }

    override func drawRect(rect: CGRect) {
        if let startPoint = startPoint, endPoint = endPoint {
            let path = UIBezierPath()
            path.moveToPoint(startPoint)
            path.addLineToPoint(endPoint)

            UIColor.blackColor()
            path.stroke()
        }
    }
}