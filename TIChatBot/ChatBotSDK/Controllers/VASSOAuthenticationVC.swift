// VASSOAuthenticationVC
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import WebKit

// MARK: Protocol definition
protocol VASSOAuthenticationVCDelegate: AnyObject {
    func ssoLoggedInSuccessfullyWith(sessionId: String, isAuthenticateOnLaunch: Bool, selectedCardIndexPath: IndexPath?)
    func ssoLogInCancelled(isAuthenticateOnLaunch: Bool)
}

class VASSOAuthenticationVC: UIViewController {

    // MARK: Outlet Declaration
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    // MARK: Property Declaration
    var ssoURLStr = ""
    var isAuthenticateOnLaunch: Bool = false
    var isOneLoginSSO: Bool = false
    var delegate: VASSOAuthenticationVCDelegate?
    var selectedCardIndexPath: IndexPath?

    // MARK: View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureWebView()
        self.cancelButton.setTitleColor(VAColorUtility.defaultButtonColor, for: .normal)
        self.cancelButton.setTitle(LanguageManager.shared.localizedString(forKey: "Cancel"), for: .normal)
        self.overrideUserInterfaceStyle = .light
    }

    override func viewWillDisappear(_ animated: Bool) {
        CustomLoader.hide()
    }

    // MARK: Custom methods
    func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        if let link = URL(string: ssoURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            webView.load(URLRequest(url: link))
        }
    }

    // MARK: Button Actions
    @IBAction func backButton(_ sender: Any) {
        webView.stopLoading()
        CustomLoader.hide()
        if webView.canGoBack {
            webView.goBack()
        } else {
            /// dismiss UIViewController
            self.dismiss(animated: !self.isAuthenticateOnLaunch, completion: nil)
            /// send info to source UIViewController
            delegate?.ssoLogInCancelled(isAuthenticateOnLaunch: self.isAuthenticateOnLaunch)
        }

    }
}

// MARK: WKNavigationDelegate
extension VASSOAuthenticationVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Start Loader
        CustomLoader.show(isUserInterationEnabled: true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Stop loader
        CustomLoader.hide()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        debugPrint(error.localizedDescription)
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            /// hide loader
            CustomLoader.hide()
            /// show alert for error message
            UIAlertController.openAlertWithOk(LanguageManager.shared.localizedString(forKey: "Error"),
                                              LanguageManager.shared.localizedString(forKey: "Sorry, the requested URL not found!"),
                                              LanguageManager.shared.localizedString(forKey: "OK"),
                                              view: self) {
                /// dismiss the UIViewController
                self.dismiss(animated: !self.isAuthenticateOnLaunch, completion: nil)
                /// send info to source UIViewController
                self.delegate?.ssoLogInCancelled(isAuthenticateOnLaunch: self.isAuthenticateOnLaunch)
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print(url.absoluteString)
            if url.absoluteString.hasPrefix(VAConfigurations.SSOAuthURL) || url.absoluteString.hasPrefix(VAConfigurations.OneLoginSSOAuthURL) {
                debugPrint("Auth SUCCESS")
                // check query parameters here
                if let params = url.queryParameters as NSDictionary? {
                    debugPrint(params)
                    guard let token = params["data"] as? String, params["type"] as? String == "auth" else {
                        return
                    }
                    debugPrint("Token =  \(token)")
                    delegate?.ssoLoggedInSuccessfullyWith(sessionId: token, isAuthenticateOnLaunch: isAuthenticateOnLaunch, selectedCardIndexPath: selectedCardIndexPath)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            debugPrint(navigationAction.request.url as Any)
            decisionHandler(.allow)
        }
    }
}
// end

// MARK: - URL extension
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
