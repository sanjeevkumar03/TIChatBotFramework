// VAExpandedTextVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit

// MARK: Protocol definition
protocol VAExpandedTextVCDelegate: AnyObject {
    func didTapOnExpandedTextQueryLink(displayText: String, dataQuery: String, indexPath: IndexPath)
    func didTapOnExpandedTextURL(url: String)
}

class VAExpandedTextVC: UIViewController {
    // MARK: Outlet declaration
    @IBOutlet weak var seperatorTitleView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!

    // MARK: Property declaration
    var htmlText: NSAttributedString?
    var normalText: String = ""
    var originalText: String = ""
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var chatTableIndexPath: IndexPath? = nil
    weak var delegate: VAExpandedTextVCDelegate?

    // MARK: View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        textView.tintColor = #colorLiteral(red: 0, green: 0.3647058824, blue: 1, alpha: 1)
        textView.delegate = self
        if htmlText == nil {
            textView.text = normalText
            textView.font = UIFont(name: fontName, size: textFontSize)
        } else {
            let attributedStr: NSMutableAttributedString = htmlText as? NSMutableAttributedString ?? NSMutableAttributedString(string: "")
            //attributedStr.addAttribute(.font, value: UIFont(name: fontName, size: textFontSize)!, range: NSRange(location: 0, length: attributedStr.length))
            textView.attributedText = htmlText
        }

        self.closeButtonImg.image = UIImage(named: "crossIcon", in: Bundle(for: VAExpandedTextVC.self), with: nil)
        self.closeButtonImg.tintColor = VAColorUtility.defaultButtonColor

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil)
        self.overrideUserInterfaceStyle = .light
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bgView.isHidden = false
        if textView.contentSize.height > self.view.bounds.height * 0.8 {
            scrollViewHeight.constant = self.view.bounds.height * 0.8
        } else {
            scrollViewHeight.constant = textView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }

    // MARK: - Handle Session Expired State
    @objc func handleSessionExpiredState(notification: Notification) {
        /// Dismiss UIViewController
        self.dismiss(animated: false, completion: nil)
    }

    // MARK: Custom methods
    func setupView() {
        self.bgView.backgroundColor = VAColorUtility.receiverBubbleColor
    }

    // MARK: Button Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false) {
        }
    }
}

// MARK: - VAExpandedTextVC extension
extension VAExpandedTextVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let attachment = textAttachment.image {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle(for: VAChatViewController.self))
            if let vcObj = storyBoard.instantiateViewController(withIdentifier: "VAImageViewerVC") as? VAImageViewerVC {
                vcObj.image = attachment
                if attachment.size.width <= 200 && attachment.size.height <= 200 {
                    vcObj.imageContentMode = .center
                }
                vcObj.modalPresentationStyle = .overCurrentContext
                self.present(vcObj, animated: true, completion: nil)
            }
        }
        return true
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print(URL)
        if UIApplication.shared.canOpenURL(URL) == false {
            let newRange = Range(characterRange, in: textView.text ?? "")!
            let subString = textView.text[newRange]
            let queryLink = String(subString)

            let dataQuery = self.getDataQueryAttributeFromHtmlString(queryText: queryLink)
            if let indexPath = chatTableIndexPath {
                delegate?.didTapOnExpandedTextQueryLink(displayText: queryLink, dataQuery: dataQuery, indexPath: indexPath)
            }
            self.dismiss(animated: false) {
            }
            return false
        } else {
            self.dismiss(animated: false) { [self] in
                delegate?.didTapOnExpandedTextURL(url: URL.absoluteString)
            }
            return false
        }
        //return true
    }

    func getDataQueryAttributeFromHtmlString(queryText: String) -> String {
        var splittedText = originalText.components(separatedBy: "data-query")
        splittedText.removeFirst()
        for item in splittedText {
            if item.contains("data-displayname=\"\(queryText)\"") || item.contains("data-displayname=\" \(queryText)\"") ||
                item.contains("data-displayname=\"\(queryText) \"") ||
                item.contains("data-displayname=\" \(queryText) \"") {
                let splittedItem = item.components(separatedBy: "data-displayname")
                let dataQuery = splittedItem.first ?? ""
                return dataQuery.replacingOccurrences(of: "=\"", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
}
