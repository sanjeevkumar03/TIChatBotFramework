// SuggestionsTableCell.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

class SuggestionsTableCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSeperator: UIView!

    // MARK: Property Declaration
    static let nibName = "SuggestionsTableCell"
    static let identifier = "SuggestionsTableCell"
    var fontName: String = ""
    var textFontSize: Double = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.textColor = VAColorUtility.black// VAColorUtility.themeTextIconColor
        self.viewSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor
    }

    func configure(title: String, searchText: String) {
        self.lblTitle.font = UIFont(name: fontName, size: textFontSize)
        if  searchText != "" {
            lblTitle.attributedText = boldSearchResult(searchString: searchText, resultString: title)
        } else {
            lblTitle.text = title
        }
    }

    func boldSearchResult(searchString: String, resultString: String) -> NSMutableAttributedString {
        var boldFont = ""
        let fontArray = fontName.components(separatedBy: "-")
        if fontArray.count > 1 {
            boldFont = fontArray.first! + "-Bold"
        } else {
            boldFont = fontName + "-Bold"
        }
        let searchedWords = searchString.components(separatedBy: " ").filter({$0 != ""})
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: resultString)
        for query in searchedWords {
            let pattern = query.lowercased()
            let range: NSRange = NSRange(location: 0, length: resultString.count)
            let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
            regex?.enumerateMatches(in: resultString.lowercased(), options: NSRegularExpression.MatchingOptions(), range: range) { (textCheckingResult, _, _) in
                let subRange = textCheckingResult?.range
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: boldFont, size: textFontSize) ?? UIFont.boldSystemFont(ofSize: textFontSize), range: subRange!)
            }
        }
        return attributedString
    }
}
