//  VAEnvironmentManager.swift
//  Copyright © 2021 Telus International. All rights reserved.

import Foundation

public enum BotEnv: CaseIterable {
    case mdev
    case mqa
    case stage
    case tiiaProd, tiiaprod
    case tvaProd, tvaprod
    case kvaProd, kvaprod
    case chatGPT
}

class VAEnvironmentManager {
    static let shared = VAEnvironmentManager()
    typealias EnvironmentDetails = (apiBaseUrl: String, xmppServer: String, 
                                    port: String, ssoAuthURL: String, deeplinkURL: String,
                                    parentHost: String, oneLoginSSOAuthURL: String)

    func getEnvironmentDetails (_ environment: BotEnv) -> EnvironmentDetails {

        switch environment {
        case .mdev:
            let apiUrl = "https://mdev.xavlab.xyz"
            let xmppServer = "107.178.214.42"
            let port = "5222"// 5280
            let ssoAuthUrl = "https://widget-mdev.xavlab.xyz/auth.html"
            let oneLoginSSOAuthUrl = "https://mdev.xavlab.xyz/auth.html"
            let deepLinkUrl = ""
            let parentHost = "widget-mdev.xavlab.xyz"
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)

        case .mqa:
            let apiUrl = "https://mqa2.xavlab.xyz"
            let xmppServer = "appmqa.xavlab.xyz"
            let port = "5222"
            let ssoAuthUrl = "https://widget-mqa2.xavlab.xyz/auth.html"
            let oneLoginSSOAuthUrl = "https://mqa2.xavlab.xyz/auth.html"
            let deepLinkUrl = ""
            let parentHost = "widget-mqa2.xavlab.xyz"
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)

        case .stage:
            let apiUrl = "https://kb.xavlab.xyz"
            let xmppServer = "34.173.220.38"
            let port = "5222"// 5222,5280,5281
            let ssoAuthUrl = "https://widget-kb.xavlab.xyz/auth.html"
            let oneLoginSSOAuthUrl = "https://kb.xavlab.xyz/auth.html"
            let deepLinkUrl = ""
            let parentHost = "widget-kb.xavlab.xyz"
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)
        /// SARA  TIP Bot
        case .tiiaProd, .tiiaprod:
            let apiUrl = "https://wbot.itia.ai"
            let xmppServer = "34.172.134.116"
            let port = "5222"
            let ssoAuthUrl = "https://widget.bot.itia.ai/"
            let oneLoginSSOAuthUrl = "https://bot.itia.ai/auth.html"
            let deepLinkUrl = ""
            let parentHost = "widget.bot.itia.ai"
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)

        case .tvaProd, .tvaprod:
            let apiUrl = "https://tva.tiia.ai"
            let xmppServer = "wss://tva.tiia.ai/ws"
            let port = "5222"
            let ssoAuthUrl = "https://w-tva.tiia.ai/auth.html"
            let oneLoginSSOAuthUrl = "https://tva.tiia.ai/auth.html"
            let deepLinkUrl = ""
            let parentHost = "w-tva.tiia.ai"
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)

        case .kvaProd, .kvaprod:
            let apiUrl = "https://kva.tiia.ai"
            let xmppServer = "wss://kva.tiia.ai/ws"
            let port = "5222"
            let ssoAuthUrl = "https://w-kva.tiia.ai/auth.html"
            let oneLoginSSOAuthUrl = "https://kva.tiia.ai/auth.html"
            let deepLinkUrl = ""
            let parentHost = "w-kva.tiia.ai"
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)

        case .chatGPT:
            let apiUrl = "https://widget-demo.itia.ai"
            let xmppServer = "35.224.164.189"
            let port = "5222"
            let ssoAuthUrl = ""
            let oneLoginSSOAuthUrl = ""
            let deepLinkUrl = ""
            let parentHost = ""
            return EnvironmentDetails(apiUrl, xmppServer, port, ssoAuthUrl, deepLinkUrl, parentHost, oneLoginSSOAuthUrl)
        }
    }
}
