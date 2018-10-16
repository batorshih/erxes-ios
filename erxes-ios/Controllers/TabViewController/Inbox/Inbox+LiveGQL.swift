//
//  Inbox+LiveGQL.swift
//  erxes-ios
//
//  Created by alternate on 10/16/18.
//  Copyright © 2018 soyombo bat-erdene. All rights reserved.
//

import Foundation
import LiveGQL

extension InboxController: LiveGQLDelegate {
    
    public func receivedRawMessage(text: String) {
        do {
            
            if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
                
                let item = try JSONDecoder().decode(ConvSubs.self, from: dataFromString)
                //                self.getInbox(limit: self.conversationLimit)
                let result = item.payload?.data?.conversationsChanged
                
                
                switch result?.type {
                    
                case "newMessage":
                    self.getLast()
                    
                case "open":
                    print("open")
                case "closed":
                    print("close")
                case "assigneeChanged":
                    print("changed")
                default:
                    print("default")
                }
                self.getUnreadCount()
                
            }
        }
        catch {
            print(error)
        }
    }
}