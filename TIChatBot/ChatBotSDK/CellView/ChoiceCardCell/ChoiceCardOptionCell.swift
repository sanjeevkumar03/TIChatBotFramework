// ChoiceCardOptionCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class ChoiceCardOptionCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkboxImgView: UIImageView!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var checkboxViewWidth: NSLayoutConstraint!
    @IBOutlet weak var seperatorView: UIView!

    // MARK: Property declaration
    static let nibName = "ChoiceCardOptionCell"
    static let identifier = "ChoiceCardOptionCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkboxButton.setTitle("", for: .normal)
        self.seperatorView.backgroundColor = VAColorUtility.defaultThemeTextIconColor
    }

    func configure(title: String, isMultiSelect: Bool, isSelect: Bool, isFromPopup: Bool? = false) {
        self.titleLabel.attributedText = createNormalAttributedString(text: title)
        self.titleLabel.textColor = VAColorUtility.receiverBubbleTextIconColor

        // Change background on the basic of multiple selected allowed or not
        if isFromPopup ?? false == true {
            self.backgroundColor = VAColorUtility.defaultTextInputColor
        } else {
            self.backgroundColor = VAColorUtility.receiverBubbleColor
        }
        // Update UI on the basic of cell multiple selection is allowed
        if isMultiSelect {
            // change text alignment
            self.titleLabel.textAlignment = .left
            // show checkbox view
            self.checkboxViewWidth.constant = 46
            self.checkboxButton.isHidden = false
            self.checkboxImgView.tintColor = VAColorUtility.receiverBubbleTextIconColor
            // set image on the basic of cell selected or not
            if isSelect {
                self.checkboxImgView.image = UIImage(named: "checked", in: Bundle(for: ChoiceCardOptionCell.self), with: nil)
            } else {
                self.checkboxImgView.image = UIImage(named: "unchecked", in: Bundle(for: ChoiceCardOptionCell.self), with: nil)
            }
        } else {
            // change text alignment
            self.titleLabel.textAlignment = .center
            // hide checkbox view
            self.checkboxButton.isHidden = true
            self.checkboxViewWidth.constant = 8
        }
    }
}
