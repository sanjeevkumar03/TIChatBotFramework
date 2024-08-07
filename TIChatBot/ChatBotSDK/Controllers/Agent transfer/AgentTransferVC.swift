// AgentTransferVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import WebKit
import SDWebImage

// MARK: Protocol definition
protocol AgentTransferDelegate: AnyObject {
    func backButtonTapped()
}

class AgentTransferVC: UIViewController {
    // MARK: Outlet Declaration
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!
    @IBOutlet var closeButton: UIButton!

    // MARK: Property Declaration
    var webUrl: String = ""
    var titleString: String = ""
    weak var delegate: AgentTransferDelegate?

    // MARK: View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.titleString
        self.configureUI()
        self.configureWebView()
        self.overrideUserInterfaceStyle = .light
    }

    override func viewWillDisappear(_ animated: Bool) {
        CustomLoader.hide()
    }
    // end

    // MARK: - Configure the UI with custom UIColor
    /// This function is used to confirm UI
    func configureUI() {
        // Background Color
        self.view.backgroundColor = VAColorUtility.themeColor

        // Header Color
        self.viewNavigation.backgroundColor = VAColorUtility.defaultHeaderColor

        self.imgClose.image = UIImage(named: "leftArrow", in: Bundle(for: AgentTransferVC.self), with: nil)
        self.imgClose.tintColor = VAColorUtility.themeTextIconColor

        self.titleLabel.textColor =  VAColorUtility.themeTextIconColor

        // Header Seperator Color
        self.viewHeaderSeperator.backgroundColor = VAColorUtility.defaultThemeTextIconColor

    }
    // end

    // MARK: Custom Methods
    func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        let validUrlString = (webUrl.hasPrefix("http") || webUrl.hasPrefix("https")) ? webUrl : "https://\(webUrl)"

        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            webView.configuration.preferences.javaScriptEnabled = true
        }

        if let url = URL(string: validUrlString) {
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: Button Actions
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.backButtonTapped()
    }
}
// end

// MARK: WKNavigationDelegate
extension AgentTransferVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        CustomLoader.show(isUserInterationEnabled: true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        CustomLoader.hide()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        CustomLoader.hide()
    }
}
// end
