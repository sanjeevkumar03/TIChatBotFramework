// VAWebViewerVC.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import WebKit
import SDWebImage

class VAWebViewerVC: UIViewController {

    // MARK: Outlet Declaration
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewHeaderSeperator: UIView!

    // MARK: Property Declaration
    var webUrl: String = ""
    var titleString: String = ""
    var fontName: String = ""
    var textFontSize: Double = 0.0
    var videoFormats = ["mp4", "m4p", "webm", "mkv", "flv", "avi", "mov", "mpg", "mpeg", "3gp"]
    var isVideoUrl: Bool = false
    // end

    // MARK: View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // set title
        self.titleLabel.text = self.titleString
        self.titleLabel.font = UIFont(name: fontName, size: textFontSize)
        self.configureUI()

        self.configureWebView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleSessionExpiredState(notification:)),
            name: Notification.Name("sessionExpired"),
            object: nil)
        self.overrideUserInterfaceStyle = .light
    }
    override func viewWillDisappear(_ animated: Bool) {
        CustomLoader.hide()
    }
    // end
    /// Notification selector
    @objc func handleSessionExpiredState(notification: Notification) {
        self.dismiss(animated: false, completion: nil)
    }

    // MARK: - Configure the UI with custom UIColor
    /// This function is used to confirm UI
    func configureUI() {
        // Background Color
        self.view.backgroundColor = VAColorUtility.white// VAColorUtility.themeColor

        // Header Color
        self.viewNavigation.backgroundColor = VAColorUtility.defaultHeaderColor

        self.imgClose.image = UIImage(named: "leftArrow", in: Bundle(for: VAWebViewerVC.self), with: nil)
        self.imgClose.tintColor = VAColorUtility.defaultButtonColor

        self.titleLabel.textColor =  VAColorUtility.defaultButtonColor
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
        // validate the url
        let validUrlString = (webUrl.hasPrefix("http") || webUrl.hasPrefix("https")) ? webUrl : "https://\(webUrl)"
        if let url = URL(string: validUrlString) {
            print(url.pathExtension)
            if videoFormats.contains(url.pathExtension) {
                isVideoUrl = true
            }
            webView.load(URLRequest(url: url))
        }
    }
    // end

    // MARK: Button Actions
    @IBAction func closeTapped(_ sender: Any) {
        webView.stopLoading()
        CustomLoader.hide()
        // send agentstatus notification
        NotificationCenter.default.post(name: Notification.Name("AgentStatus"), object: nil)
        // dismiss the view
        self.dismiss(animated: true, completion: nil)
    }
    // end
}
// end

// MARK: WKNavigationDelegate
extension VAWebViewerVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Start Loader
        if !isVideoUrl {
            CustomLoader.show(isUserInterationEnabled: true)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Stop leader
        CustomLoader.hide()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        debugPrint(error.localizedDescription)
        // Stop leader
        CustomLoader.hide()
        let alert = UIAlertController.init(title: LanguageManager.shared.localizedString(forKey: "Error"), 
                                           message: LanguageManager.shared.localizedString(forKey: "Unable to load the requested URL"),
                                           preferredStyle: .alert)
        let action = UIAlertAction.init(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default) { _ in

        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
// end
