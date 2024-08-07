// StatusCardCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class StatusCardCell: UITableViewCell {

    // MARK: Outlet declaration
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!

    // MARK: Propterty declaration
    var fontName: String = ""
    var textFontSize: Double = 0.0
    static let nibName = "StatusCardCell"
    static let identifier = "StatusCardCell"

    func configureCell(title: String) {
        self.lblTitle.font = UIFont(name: fontName, size: textFontSize)
        self.lblTitle.text = title
        self.bgView.layer.cornerRadius = 12
        self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
        self.lblTitle.textColor = VAColorUtility.themeTextIconColor
    }
}
