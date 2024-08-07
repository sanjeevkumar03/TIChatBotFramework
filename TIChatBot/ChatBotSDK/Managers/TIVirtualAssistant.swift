//  TIVirtualAssistant.swift
//  Copyright © 2021 Telus International. All rights reserved.

import Foundation
import UIKit

/// TIVirtualAssistant Protocols
@objc public protocol TIVirtualAssistantDelegate {
    /// This function is called once chatbot is closed
    func didTapCloseChatbot()
    /// This function is called once user taps on minimize button of chatbot
    func didTapMinimizeChatbot()
    /// This function is called once user taps on maximize button of chatbot
    func didTapMaximizeChatbot()
    /// Native(Internal) call transfer - Genesys
    @objc optional func initiateNativeCallTransfer(data: [String: Any]?)
    /// This delegate method is called once user is not able to claim existing session in case of chat tool
    @objc optional func oldSessionNotClaimedStartNewConversationWithNewJID()
    /// This delegate method is called once chat is closed by agent.
    @objc optional func chatClosedByAgent()
}

public class TIVirtualAssistant {
    public init() {}
    public var delegate: TIVirtualAssistantDelegate?

    /// This is Initialize function for TIVirtualAssistant
    /// - Parameters:
    ///   - botId: VirtualAssistant Id used to differentiate between different ChatBots
    ///   - serverEndPoint: Backend Server URL
    ///   - port: This is used by XMPP
    /// - Returns: UIViewController
    public func initWith(botId: String,
                         environment: BotEnv? = .mqa,
                         customData: VACustomData? = nil,
                         isChatTool: Bool = false,
                         jid: String = "",
                         query: String = "",
                         isStartNewSession: Bool = false) -> UIViewController {

        // Update VAConfigurations
        VAConfigurations.botId = botId
        VAConfigurations.customData = customData
        VAConfigurations.environment = environment
        VAConfigurations.language = customData?.language
        VAConfigurations.isChatTool = isChatTool
        VAConfigurations.jid = jid
        VAConfigurations.query = query
        
        if (VAConfigurations.isChatTool || VAConfigurations.customData?.isGroupSSO == true), VAConfigurations.jid.isEmpty == false {
            //Get UUID from Jid
            let splitJid = VAConfigurations.jid.split(separator: "@")
            if splitJid.count > 1 {
                VAConfigurations.userUUID = String(splitJid[0])
            } else {
                VAConfigurations.userUUID = VAConfigurations.jid
            }
        } else {
            VAConfigurations.userUUID = VAConfigurations.generateUUID()
        }
        if isStartNewSession {
            UserDefaultsManager().resetSessionID()
        }
        debugPrint("User UUID: \(VAConfigurations.userUUID)")
        if VAConfigurations.customData != nil {
            if VAConfigurations.customData?.extraData.count ?? 0 > 0 {
                if let skill = VAConfigurations.customData?.extraData["queue"] as? String {
                    VAConfigurations.skill = skill
                }
            }
        }
        VAConfigurations.password = VAConfigurations.userUUID

        let env = VAEnvironmentManager.shared.getEnvironmentDetails(environment ?? .mqa)
        VAConfigurations.XMPPHostName = env.xmppServer
        VAConfigurations.XMPPHostPort = env.port
        VAConfigurations.apiBaseURL = env.apiBaseUrl
        VAConfigurations.SSOAuthURL = env.ssoAuthURL
        VAConfigurations.OneLoginSSOAuthURL = env.oneLoginSSOAuthURL
        VAConfigurations.parentHost = env.parentHost
        VAConfigurations.virtualAssistant = self

        // Open ChatViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: VAChatViewController.self))
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "VAChatViewController")
        return chatViewController
    }
}
