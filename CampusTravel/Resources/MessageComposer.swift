//
//  MessageComposer.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/25/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import Foundation
import MessageUI

public class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    public func configuredMessageComposeViewController(person: String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = [person]
        return messageComposeVC
    }
}
