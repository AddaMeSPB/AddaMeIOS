// import ChatView
// import ComposableArchitecture
// import ComposableCoreLocation
// import HangoutDetailsFeature
// import EventFormView
// import MapKit
// import AddaSharedModels
// import AppTrackingTransparency
//
// public struct EventsState: Equatable {
//
//  public var alert: AlertState<EventsAction>?
//  public var isConnected = true
//  public var isLocationAuthorized = false
//  public var isRequestingCurrentLocation = false
//  public var waitingForUpdateLocation = true
//  public var isLoadingPage = false
//  public var isLoadingMyEvent = false
//  public var canLoadMorePages = true
//  public var isMovingChatRoom: Bool = false
//  public var isEFromNavigationActive = false
//  public var isIDFAAuthorized = false
//  public var isLocationAuthorizedCount = 0
//
//  public var currentPage = 1
//  public var currentAddress = ""
//  public var placeMark: CLPlacemark?
//  public var location: Location?
//  public var events: IdentifiedArrayOf<EventResponse> = []
//  public var myEvent: EventResponse?
//  public var event: EventResponse?
//  public var conversation: ConversationOutPut?
//
//  public var eventFormState: EventFormState?
//  public var eventDetailsState: HangoutDetailsState?
//  public var chatState: ChatState?
//
//  public var isHangoutDetailsSheetPresented: Bool { eventDetailsState != nil }
//
//  public init(
//    alert: AlertState<EventsAction>? = nil, isConnected: Bool = true,
//    isLocationAuthorized: Bool = false, isRequestingCurrentLocation: Bool = false,
//    waitingForUpdateLocation: Bool = true,
//    isMovingChatRoom: Bool = false,
//    isEFromNavigationActive: Bool = false,
//    isIDFAAuthorized: Bool = false,
//    isLoadingPage: Bool = false,
//    isLoadingMyEvent: Bool = false,
//    isLocationAuthorizedCount: Int = 0,
//    canLoadMorePages: Bool = true, currentPage: Int = 1,
//    currentAddress: String = "", placeMark: CLPlacemark? = nil,
//    location: Location? = nil, events: IdentifiedArrayOf<EventResponse> = [],
//    myEvent: EventResponse? = nil, event: EventResponse? = nil,
//    eventFormState: EventFormState? = nil,
//    eventDetailsState: HangoutDetailsState? = nil,
//    chatState: ChatState? = nil
//  ) {
//    self.alert = alert
//    self.isConnected = isConnected
//    self.isLocationAuthorized = isLocationAuthorized
//    self.isRequestingCurrentLocation = isRequestingCurrentLocation
//    self.waitingForUpdateLocation = waitingForUpdateLocation
//    self.isLoadingPage = isLoadingPage
//    self.isLoadingMyEvent = isLoadingMyEvent
//    self.canLoadMorePages = canLoadMorePages
//    self.isMovingChatRoom = isMovingChatRoom
//    self.isEFromNavigationActive = isEFromNavigationActive
//    self.isIDFAAuthorized = isIDFAAuthorized
//    self.isLocationAuthorizedCount = isLocationAuthorizedCount
//    self.currentPage = currentPage
//    self.currentAddress = currentAddress
//    self.placeMark = placeMark
//    self.location = location
//    self.events = events
//    self.myEvent = myEvent
//    self.event = event
//    self.eventFormState = eventFormState
//    self.eventDetailsState = eventDetailsState
//    self.chatState = chatState
//  }
//
// }
//
// extension EventsState {
//    func isIDFAAuthorization(_ status: ATTrackingManager.AuthorizationStatus) -> Bool {
//        switch status {
//        case .notDetermined, .restricted, .denied: return false
//        case .authorized: return true
//        @unknown default: return false
//        }
//    }
//
// }
//
// extension EventsState {
//  var view: EventView.ViewState {
//    EventView.ViewState(
//      alert: alert, isConnected: isConnected,
//      isLocationAuthorized: isLocationAuthorized,
//      waitingForUpdateLocation: waitingForUpdateLocation,
//      isLoadingPage: isLoadingPage,
//      isLoadingMyEvent: isLoadingMyEvent,
//      isMovingChatRoom: isMovingChatRoom,
//      isIDFAAuthorized: isIDFAAuthorized,
//      location: location,
//      events: events, myEvent: myEvent,
//      event: event,
//      placeMark: placeMark,
//      eventFormState: eventFormState,
//      eventDetailsState: eventDetailsState,
//      chatState: chatState,
//      conversation: conversation
//    )
//  }
// }
