//
//  UIControl+Combine.swift
//  ListPhoto
//
//  Created by Đức Vũ on 13/5/25.
//
import Combine
import UIKit

extension UIControl {
    func publisher(for event: UIControl.Event) -> UIControl.EventPublisher {
        return UIControl.EventPublisher(control: self, event: event)
    }

    struct EventPublisher: Publisher {
        typealias Output = UIControl
        typealias Failure = Never

        let control: UIControl
        let event: UIControl.Event

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = EventSubscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }

        private final class EventSubscription<S: Subscriber>: Subscription where S.Input == UIControl, S.Failure == Never {
            private var subscriber: S?
            weak private var control: UIControl?
            let event: UIControl.Event

            init(subscriber: S, control: UIControl, event: UIControl.Event) {
                self.subscriber = subscriber
                self.control = control
                self.event = event
                control.addTarget(self, action: #selector(eventHandler), for: event)
            }

            func request(_ demand: Subscribers.Demand) { }

            func cancel() {
                control?.removeTarget(self, action: #selector(eventHandler), for: event)
                subscriber = nil
            }

            @objc private func eventHandler() {
                _ = subscriber?.receive(control!)
            }
        }
    }
}
