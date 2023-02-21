import ChatView
import ComposableArchitecture
import ComposableCoreLocation
import HangoutDetailsFeature
import EventFormView
import Foundation

import MapKit
import AddaSharedModels
import AdSupport
import AppTrackingTransparency

// swiftlint:disable:next superfluous_disable_command
extension Hangouts.Action {
//    init(action: NewGameView.ViewAction) {

    // swiftlint:disable:next cyclomatic_complexity function_body_length superfluous_disable_command
    init(action: HangoutsView.ViewAction) {
        switch action {
        case .alertDismissed:
            self =  .alertDismissed
        case .dismissHangoutDetails:
            self =  .dismissHangoutDetails
        case let .hangoutFormView(isNavigate):
            self =  .hangoutFormView(isNavigate: isNavigate)
        case let .hangoutForm(hFormAction):
            self =  .hangoutForm(hFormAction)
        case let .chatView(isNavigate: bool):
            self =  .chatView(isNavigate: bool)
        case let .chat(action):
            self =  .chat(action)
        case let .event(index: index, action: action):
            self =  .event(index: index, action: action)
        case .currentLocationButtonTapped:
            self =  .currentLocationButtonTapped
        case let .eventTapped(event):
            self =  .eventTapped(event)
        case .popupSettings:
            self =  .popupSettings
        case .dismissEvent:
            self =  .dismissEvent
        case .fetchEventOnAppear:
            self =  .fetchEventOnAppear
        case .onAppear:
            self =  .onAppear
        case .onDisAppear:
            self =  .onDisAppear
        case let .hangoutDetailsSheet(isPresented: isPresented):
            self = .hangoutDetailsSheet(isPresented: isPresented)
        case let .hangoutDetails(action):
            self =  .hangoutDetails(action)
        case let .fetchMoreEventsIfNeeded(item: item):
            self =  .fetchMoreEventsIfNeeded(item: item)
        }
    }
}
