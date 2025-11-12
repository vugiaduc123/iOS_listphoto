//
//  TextField+Combine.swift
//  ListPhoto
//
//  Created by Đức Vũ on 13/5/25.
//

import UIKit
import Combine

extension UITextField {
    func publisher(for event: UIControl.Event) -> UITextField.TextFieldPublisher {
        return UITextField.TextFieldPublisher(textField: self, event: event)
    }

    struct TextFieldPublisher: Publisher {
        typealias Output = String?
        typealias Failure = Never

        let textField: UITextField
        let event: UIControl.Event

        func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == String? {
            let subscription = TextFieldSubscription(subscriber: subscriber, textField: textField, event: event)
            subscriber.receive(subscription: subscription)
        }

        private final class TextFieldSubscription<S: Subscriber>: Subscription where S.Input == String?, S.Failure == Never {
            private var subscriber: S?

            private let textField: UITextField

            let event: Event

            init(subscriber: S, textField: UITextField, event: UIControl.Event) {
                self.subscriber = subscriber
                self.textField = textField
                self.event = event
                textField.addTarget(self, action: #selector(textFieldChanged), for: event)
            }

            func request(_ demand: Subscribers.Demand) { }

            func cancel() {
                subscriber = nil
            }

            @objc func textFieldChanged() {
                _ = subscriber?.receive(textField.text)
            }
        }
    }
}
