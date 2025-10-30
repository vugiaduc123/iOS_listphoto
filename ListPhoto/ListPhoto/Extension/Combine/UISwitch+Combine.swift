//
//  UISwitch+.swift
//  ListPhoto
//
//  Created by Đức Vũ on 13/5/25.
//

import Foundation
import Combine
import UIKit

extension UISwitch {
    var publisher: SwitchPublisher {
        return SwitchPublisher(uiSwitch: self)
    }
    struct SwitchPublisher: Publisher {
        typealias Output = Bool
        typealias Failure = Never
        
        let uiSwitch: UISwitch
        
        // nerver laf gi tai sao failure lai never
        func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, Bool == S.Input {
            let subcription = EventSubscription(subscriber: subscriber, uiSwitch: uiSwitch)
            subscriber.receive(subscription: subcription)
        }
    }
    
    private final class EventSubscription<S: Subscriber>: Subscription where S.Input == Bool, S.Failure == Never {
        private var subscriber: S?
        private let uiSwitch: UISwitch
        
        init(subscriber: S, uiSwitch: UISwitch) {
            self.subscriber = subscriber
            self.uiSwitch = uiSwitch
            uiSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
        }
        
        @objc func switchValueChanged() {
            _ = subscriber?.receive(uiSwitch.isOn)
        }
    }
}

