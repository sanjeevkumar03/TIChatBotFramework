//  VAChatView+UITableView.swift
// Copyright © 2021 Telus International. All rights reserved.

import Foundation
import UIKit
import AVFoundation

extension VAChatViewController: UITableViewDelegate, UITableViewDataSource {

    /// This function is used to register table view cells
    func configureMessagesTable() {
        chatTableView.tableFooterView = UIView()
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 200

        chatTableView.register(UINib(nibName: ImageCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: ImageCardCell.identifier)

        chatTableView.register(UINib(nibName: ButtonCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: ButtonCardCell.identifier)

        chatTableView.register(UINib(nibName: DateFeedbackCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: DateFeedbackCell.identifier)

        chatTableView.register(UINib(nibName: URLCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: URLCardCell.identifier)

        chatTableView.register(UINib(nibName: TextCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: TextCardCell.identifier)

        chatTableView.register(UINib(nibName: SenderCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: SenderCardCell.identifier)

        chatTableView.register(UINib(nibName: SenderImageCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: SenderImageCell.identifier)

        chatTableView.register(UINib(nibName: SourceCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: SourceCardCell.identifier)

        chatTableView.register(UINib(nibName: CarouselCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: CarouselCardCell.identifier)

        chatTableView.register(UINib(nibName: ChoiceCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: ChoiceCardCell.identifier)

        chatTableView.register(UINib(nibName: VideoCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: VideoCardCell.identifier)

        chatTableView.register(UINib(nibName: StatusCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: StatusCardCell.identifier)

        chatTableView.register(UINib(nibName: AgentTextCardCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: AgentTextCardCell.identifier)

        suggestionTableView.tableFooterView = UIView()
        suggestionTableView.rowHeight = UITableView.automaticDimension
        suggestionTableView.estimatedRowHeight = 50
        suggestionTableView.register(UINib(nibName: SuggestionsTableCell.nibName, bundle: Bundle(for: VAChatViewController.self)), forCellReuseIdentifier: SuggestionsTableCell.identifier)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.chatTableView {
            return self.viewModel.arrayOfMessages2D.count
        } else if tableView == self.suggestionTableView {
            return 1
        } else if tableView == self.preChatFormTable {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.chatTableView {
            return self.viewModel.arrayOfMessages2D[section].count
        } else if tableView == self.suggestionTableView {
            return self.viewModel.arrayOfSuggestions.count > 3 ? 3 : self.viewModel.arrayOfSuggestions.count
        }  else if tableView == self.preChatFormTable {
            return self.viewModel.prechatForm?.settings?.props?.count ?? 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let superCell = UITableViewCell()
        if tableView == self.chatTableView {
            if !self.viewModel.arrayOfMessages2D.isEmpty && (self.viewModel.arrayOfMessages2D.count <= indexPath.section || self.viewModel.arrayOfMessages2D[indexPath.section].count <= indexPath.row) {
                return UITableViewCell()
            }
            let messageModal = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row]
            if messageModal.sender.id == VAConfigurations.userUUID { // sender cell
                switch messageModal.kind {
                case .text(let text):
                    if let cell = tableView.dequeueReusableCell(withIdentifier: SenderCardCell.identifier, for: indexPath) as? SenderCardCell {
                        cell.completeText = text
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.dateFontSize = self.dateTimeFontSize
                        cell.isChatToolChatClosed = self.viewModel.isChatToolChatClosed
                        cell.configure(indexPath: indexPath, sentiment: messageModal.sentiment, configIntegration: self.viewModel.configIntegrationModel, date: messageModal.sentDate, masked: messageModal.masked, repliedMessageDict: messageModal.repliedMessageDict)
                        cell.delegate = self
                        return cell
                    }
                case .imageItem(let item):
                    if let cell = tableView.dequeueReusableCell(withIdentifier: SenderImageCell.identifier, for: indexPath) as? SenderImageCell {
                        cell.fontName = self.fontName
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.dateFontSize = self.dateTimeFontSize
                        cell.locationData = item.imageProtocol?.message ?? ""
                        cell.configure(sentiment: messageModal.sentiment, date: messageModal.sentDate, image: item.imageProtocol?.image)
                        cell.delegate = self
                        return cell
                    }
                default:
                    return superCell
                }
            } else {
                switch messageModal.kind {
                case .textItem(let textItem): /// text item
                    if let cell = tableView.dequeueReusableCell(withIdentifier: TextCardCell.identifier, for: indexPath) as? TextCardCell {
                        cell.completeText = textItem.textProtocol?.title ?? ""
                        cell.completeAttributedText = textItem.textProtocol?.attributedText
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.isAgent = messageModal.isAgent
                        cell.textItem = textItem.textProtocol
                        cell.delegate = self
                        cell.chatTableSection = indexPath.section
                        cell.readMoreButton.tag = indexPath.row
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.configure()
                        return cell
                    }
                case .urlItem(let url): /// url item
                    if let cell = tableView.dequeueReusableCell(withIdentifier: URLCardCell.identifier, for: indexPath) as? URLCardCell {
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.delegate = self
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.configure(url: url.urlProtocol?.title ?? "")
                        return cell
                    }
                case .source(let prop): /// Source is not in use currently
                    if let cell = tableView.dequeueReusableCell(withIdentifier: SourceCardCell.identifier, for: indexPath) as? SourceCardCell {
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.configure(url: prop.propProtocol?.onesource ?? "")
                        return cell
                    }
                case .imageItem(let mediaItem): /// image card
                    if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCardCell.identifier, for: indexPath) as? ImageCardCell {
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.chatTableSection = indexPath.section
                        cell.msgImgView.tag = indexPath.row
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.delegate = self
                        cell.configure(imageURL: mediaItem.imageProtocol?.url ?? "")
                        return cell
                    }
                case .quickReply(let items): /// quick reply card
                    if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCardCell.identifier, for: indexPath) as? ButtonCardCell {
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.quickReplyResponse = items.quickReplyProtocol
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.isHideQuickReplyButton = messageModal.isHideQuickReplyButtons
                        cell.cardIndexPath = indexPath
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.allowUserActivity = self.allowUserActivity
                        cell.configure()
                        cell.delegate = self
                        return cell
                    }
                case .carouselItem(let items): /// carousel card
                    if let cell = tableView.dequeueReusableCell(withIdentifier: CarouselCardCell.identifier, for: indexPath) as? CarouselCardCell {
                        if let carousalArray = items.carousel?.carouselObjects {
                            cell.carouselArray = carousalArray
                        }
                        cell.delegate = self
                        cell.context = self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].context
                        cell.selectedImageIndex = messageModal.selectedCarouselItemIndex
                        cell.carouselCardIndexPath = indexPath
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.configure()
                        return cell
                    }
                case .dateFeedback: /// date and feedback cell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: DateFeedbackCell.identifier, for: indexPath) as? DateFeedbackCell {
                        cell.delegate = self
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.fontName = self.fontName
                        cell.textFontSize = self.dateTimeFontSize
                        if (indexPath.row == self.viewModel.arrayOfMessages2D[indexPath.section].count - 1) && indexPath.section == self.viewModel.arrayOfMessages2D.count-1 {
                            cell.configure(model: messageModal, isShowFeedback: self.viewModel.messageData?.feedback?["click_feedback"] ?? false, indexPath: indexPath)
                        } else {
                            cell.configure(model: messageModal, isShowFeedback: false, indexPath: indexPath)
                        }
                        return cell
                    }
                case .multiOps(let items): /// Multi options card
                    if let cell = tableView.dequeueReusableCell(withIdentifier: ChoiceCardCell.identifier, for: indexPath) as? ChoiceCardCell {
                        let isMultiOpsTapped: Bool = messageModal.isMultiOpsTapped
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.delegate = self
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.configure(model: items.multiOps, isMultiSelect: messageModal.isMultiSelect, indexPath: indexPath, isMultiOpsTapped: isMultiOpsTapped, allowSkip: messageModal.allowSkip)
                        return cell
                    }
                case .video(let item): /// Video card
                    if let cell = tableView.dequeueReusableCell(withIdentifier: VideoCardCell.identifier, for: indexPath) as? VideoCardCell {
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.isShowBotImage = messageModal.showBotImage
                        cell.delegate = self
                        cell.configureCell(
                            videoUrl: item.videoProtocol?.urlStr ?? "",
                            index: indexPath.row)
                        return cell
                    }
                case .agentMessage(let item): /// agent text cell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: AgentTextCardCell.identifier, for: indexPath) as? AgentTextCardCell {
                        cell.completeText = item.agentMessage?.message ?? ""
                        cell.configurationModal = self.viewModel.configurationModel
                        cell.repliedMessageDict = messageModal.repliedMessageDict
                        cell.msgDate = messageModal.sentDate
                        cell.dateFontSize = self.dateTimeFontSize
                        cell.readMoreButton.tag = indexPath.row
                        cell.delegate = self
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.isDoNotRespond = !messageModal.enableSpecificMsgReply//item.agentMessage?.doNotRespond ?? false
                        cell.isChatToolChatClosed = self.viewModel.isChatToolChatClosed
                        cell.configure(indexPath: indexPath)
                        return cell
                    }
                case .agentStatus(let item): /// agent status cell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: StatusCardCell.identifier, for: indexPath) as? StatusCardCell {
                        cell.fontName = self.fontName
                        cell.textFontSize = self.textFontSize
                        cell.configureCell(title: item.statusMessage?.status ?? "")
                        return cell
                    }
                default:
                    return superCell
                }
            }
        } else if tableView == self.suggestionTableView { /// suggestion cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: SuggestionsTableCell.identifier, for: indexPath) as? SuggestionsTableCell {
                cell.fontName = self.fontName
                cell.textFontSize = self.autoSuggestionFontSize
                if self.viewModel.arrayOfSuggestions.count > indexPath.row {
                    cell.configure(title: self.viewModel.arrayOfSuggestions[indexPath.row].originalText ?? "", searchText: searchedText)
                }
                return cell
            }
        } else if tableView == self.preChatFormTable {
            let formFieldDetails = self.viewModel.prechatForm?.settings?.props?[indexPath.row]
            switch formFieldDetails?.inputType?.label {
            case PreChatFormFieldType.textField:
                let cell: TextFieldFormCell = tableView.dequeueReusableCell(withIdentifier: TextFieldFormCell.cellIdentifier, for: indexPath) as! TextFieldFormCell
                cell.fieldDetails = formFieldDetails
                cell.fieldIndexPath = indexPath
                self.hasErrorsInPrechatFormDuringSubmit ? cell.configureFormField(isShowErrorLabel: true) : cell.configureFormField()
                cell.delegate  = self
                return cell
            case PreChatFormFieldType.textView:
                let cell: TextAreaFormCell = tableView.dequeueReusableCell(withIdentifier: TextAreaFormCell.cellIdentifier, for: indexPath) as! TextAreaFormCell
                cell.fieldDetails = formFieldDetails
                cell.fieldIndexPath = indexPath
                self.hasErrorsInPrechatFormDuringSubmit ? cell.configureFormField(isShowErrorLabel: true) : cell.configureFormField()
                cell.delegate = self
                return cell
            case PreChatFormFieldType.dropDown:
                let cell: DropdownFormCell = tableView.dequeueReusableCell(withIdentifier: DropdownFormCell.cellIdentifier, for: indexPath) as! DropdownFormCell
                cell.fieldDetails = formFieldDetails
                cell.fieldIndexPath = indexPath
                self.hasErrorsInPrechatFormDuringSubmit ? cell.configureFormField(isShowErrorLabel: true) : cell.configureFormField()
                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
            }
        }
        return superCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.suggestionTableView {
            if (self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAI || self.viewModel.configurationModel?.result?.nluBackend == NLUTypes.GenAINLU) {
                if genAISendMsgDelayCounter == 0 {
                    self.startGenAISendMsgDelayTimer()
                    self.showSuggestionsOnUserTyping(indexPath: indexPath)
                }
            } else {
                self.showSuggestionsOnUserTyping(indexPath: indexPath)
            }
        }
    }
    private func showSuggestionsOnUserTyping(indexPath: IndexPath) {
        self.hideChoiceCardOptionsOfLastResponseBeforeSendingMessage()
        self.viewSuggestions.isHidden = true
        self.searchedText = ""
        let text = self.viewModel.arrayOfSuggestions[indexPath.row].originalText
        var model = self.viewModel.arrayOfSuggestions[indexPath.row]
        self.viewModel.arrayOfSuggestions.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, text] in
            if model.isLocalSearch == true {
                let context = ["intent_id": model.intent_id ?? 0, "intent_name": model.intentName ?? "", "intent_uid": model.intent_uid ?? ""] as [String: Any]
                if model.type == "multi_ops" {
                    if let choiceIndex = model.allChoiceOptions?.firstIndex(where: {$0.label.lowercased() == text?.lowercased()}) {
                        model.allChoiceOptions![choiceIndex].isSelected = true
                        
                        let messageModel = self?.viewModel.arrayOfMessages2D[(self?.viewModel.arrayOfMessages2D.count ?? 0) - 1]
                        var indexPath: IndexPath!
                        for index in 0..<(messageModel?.count ?? 0) {
                            let model = messageModel?[index]
                            switch model?.kind {
                            case .multiOps:
                                indexPath = IndexPath(row: index, section: (self?.viewModel.arrayOfMessages2D.count)! - 1)
                            default: break
                            }
                        }
                        if let cell = self!.chatTableView.cellForRow(at: indexPath) as? ChoiceCardCell {
                            cell.delegate?.didTapConfirmButton(response: model.allChoiceOptions!, indexPath: indexPath)
                        }
                    }
                } else {
                    self?.handlePersistQuickReplyButtons()
                    
                    var message = MockMessage(text: text!, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.displayName ?? VAConfigurations.userUUID), messageId: UUID().uuidString, date: Date())
                    if self?.viewModel.arrayOfMessages2D.count == 0 {
                        message.messageSequance = 1
                    } else {
                        message.messageSequance = (self?.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1
                    }
                    message.masked = self?.viewModel.messageData?.masked ?? nil
                    self?.viewModel.arrayOfMessages2D.append([message])
                    
                    // let isTextFeedback = self?.viewModel.messageData?.feedback?["text_feedback"] ?? false
                    let isTextFeedback = self?.viewModel.messageData?.feedback?["click_feedback"] ?? false
                    self?.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
                    if model.type == "goto" {
                        self?.sendDataToServer(data: text!, templateId: Int(model.displayText!), context: [context], senderMessageType: SenderMessageType.text)
                    } else if model.type == "query" {
                        self?.sendDataToServer(data: text!, isQuery: true, context: [context], senderMessageType: SenderMessageType.text)
                    }
                }
            } else {
                self?.handlePersistQuickReplyButtons()
                
                var message = MockMessage(text: text!, sender: Sender(id: VAConfigurations.userUUID, displayName: VAConfigurations.customData?.displayName ?? VAConfigurations.userUUID), messageId: UUID().uuidString, date: Date())
                
                if self?.viewModel.arrayOfMessages2D.count == 0 {
                    message.messageSequance = 1
                } else {
                    message.messageSequance = (self?.viewModel.arrayOfMessages2D.last?.first?.messageSequance ?? 0)+1// (self?.viewModel.arrayOfMessages2D.count ?? 0) + 1
                }
                message.masked = self?.viewModel.messageData?.masked ?? nil
                self?.viewModel.arrayOfMessages2D.append([message])
                                
                // let isTextFeedback = self?.viewModel.messageData?.feedback?["text_feedback"] ?? false
                let isTextFeedback = self?.viewModel.messageData?.feedback?["click_feedback"] ?? false
                self?.reloadAndScrollToBottom(isAnimate: false, isFeedback: isTextFeedback)
                self?.sendDataToServer(data: text!, templateId: model.intent_id ?? 0, senderMessageType: SenderMessageType.text)
            }
            self?.txtViewMessage.text = ""
            self?.viewModel.isMessageTyping = true
            self?.txtViewMessage.resignFirstResponder()
            self?.setCircularProgress()
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == self.chatTableView && VAConfigurations.isChatTool && self.viewModel.arrayOfMessages2D[indexPath.section][indexPath.row].enableSpecificMsgReply == true && self.viewTextInputBG.isHidden == false {
            return true
        } else {
            return false
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
        })
        closeAction.backgroundColor = VAColorUtility.themeColor
        let swipeConfig = UISwipeActionsConfiguration(actions: [closeAction])
        swipeConfig.performsFirstActionWithFullSwipe = true
        
        self.didTapOnReplyButton(indexPath: indexPath)
        let generator = UIImpactFeedbackGenerator(style:.rigid)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            tableView.isEditing = false
        }
        return swipeConfig
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }
}
// end

