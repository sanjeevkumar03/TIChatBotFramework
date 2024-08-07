//  VAPopoverViewController.swift
// Copyright © 2021 Telus International. All rights reserved.

import Foundation
import UIKit

class VAPopoverListVC: UIViewController {

    // MARK: Outlet declaration
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            self.listTableView.delegate = self
            self.listTableView.dataSource = self
            // self.listTableView.showsVerticalScrollIndicator = false
            // self.listTableView.showsHorizontalScrollIndicator = false
        }
    }
    
    // MARK: Property declaration
    private var arrayOfData: [String] = []
    private var completionBlock: VAPopoverCompletionBlock!
    internal typealias VAPopoverCompletionBlock  = (_ index: Int, _ item: String) -> Void
    private var openFromSideMenu: Bool = false
    private var totalItemsCount: Int = 0
    private var fontName: String = ""
    private var textFontSize: Double = 0.0

    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.overrideUserInterfaceStyle = .light
    }

    // MARK: - SETUP VIEW
    /// This function is used to setupview
    func setupView() {
    }

    class func openPopoverListView(arrayOfData: [String], viewController: UIViewController, sender: UIView, 
                                   fontName: String, textFontSize: Double,
                                   completionHandler: @escaping VAPopoverCompletionBlock) {
        let story = UIStoryboard(name: "Main", bundle: Bundle(for: VAPopoverListVC.self))
        var alert: VAPopoverListVC!

        if #available(iOS 13, *) {
            alert = story.instantiateViewController(identifier: "VAPopoverListVC") as? VAPopoverListVC
        } else {
            alert = story.instantiateViewController(withIdentifier: "VAPopoverListVC") as? VAPopoverListVC
        }

        alert.completionBlock = completionHandler

        alert.openPopoverListView(arrayOfData: arrayOfData, viewController: viewController, sender: sender, fontName: fontName, textFontSize: textFontSize, completionHandler: completionHandler)
    }

    private func openPopoverListView(arrayOfData: [String], viewController: UIViewController, sender: UIView, 
                                     fontName: String, textFontSize: Double,
                                     completionHandler: @escaping VAPopoverCompletionBlock) {
        self.arrayOfData = arrayOfData
        self.fontName = fontName
        self.textFontSize = textFontSize
        if self.arrayOfData.count > 5 {
            self.preferredContentSize = CGSize(width: 220, height: 225)
        } else {
            self.preferredContentSize = CGSize(width: 220, height: 44 * self.arrayOfData.count)
        }

        // present the viewController as popup
        self.modalPresentationStyle = .popover

        if let popoverPresentationController = self.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            // update UI
            popoverPresentationController.backgroundColor = VAColorUtility.themeColor
            popoverPresentationController.backgroundColor = .white

            popoverPresentationController.sourceView = sender
            popoverPresentationController.delegate = self
            viewController.present(self, animated: true, completion: nil)
        }
    }

    // end
}
// end

// MARK: - VAPopoverListVC extension of UITableView Delegate and DataSource
extension VAPopoverListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VAPopoverListCell", for: indexPath) as? VAPopoverListCell {
            cell.titleLabel.text = self.arrayOfData[indexPath.row]
            cell.titleLabel.font = UIFont(name: fontName, size: textFontSize)
            cell.titleLabel.textColor = VAColorUtility.themeTextIconColor
            cell.viewSeperator.backgroundColor = VAColorUtility.themeColor

            // Show or hide seperartor line
            if indexPath.row == self.arrayOfData.count - 1 {
                // last call then hide seperator line
                cell.viewSeperator.isHidden = true
            } else {
                // show seperator line
                cell.viewSeperator.isHidden = false
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // dismiss the UIViewController
        self.dismiss(animated: true) {
            // completion block
            self.completionBlock(indexPath.row, self.arrayOfData[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
// end

// MARK: - VAPopoverListVC extension of UIPopoverPresentationControllerDelegate
extension VAPopoverListVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        NotificationCenter.default.post(name: Notification.Name("AgentStatus"), object: nil)
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
// end

// MARK: - VAPopoverListCell
class VAPopoverListCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewSeperator: UIView!
}
// end
