//
//  EventForm.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Combine
import ComposableArchitecture
import ComposablePresentation
import ComposableArchitectureHelpers
import EventClient
import EventClientLive
import Foundation
import HTTPRequestKit
import KeychainService
import MapKit
import MapView
import SharedModels
import SwiftUI
import SwiftUIExtension

extension EventFormView {
  public struct ViewState: Equatable {
    public var title = ""
    public var textFieldHeight: CGFloat = 30
    public var durationRawValue: String = DurationButtons.FourHours.rawValue
    public var categoryRawValue: String = Categories.General.rawValue
    public var selectedCateforyIndex: Int = 0
    public var selectedDurationIndex: Int = 0
    public var showCategorySheet = false
    public var liveLocationToggleisOn = true
    public var moveMapView = false
    public var selectLocationtoggleisOn = false {
      willSet {
        liveLocationToggleisOn = false
      }
    }

    public var selectedTag: String?
    public var showSuccessActionSheet = false
    public var placeMark: CLPlacemark?

    public var selectedPlace: EventResponse.Item?
    public var currentPlace: EventResponse.Item?
    public var eventAddress: String = ""
    public var selectedDutaionButtons: DurationButtons = .FourHours
    public var actionSheet: ConfirmationDialogState<EventFormAction>?
    public var alert: AlertState<EventFormAction>?
    public var locationSearchState: LocationSearchState?
    public var isPostRequestOnFly: Bool = false
    public var isEventCreatedSuccessfully: Bool = false

    public var isSheetPresented: Bool { locationSearchState != nil }
    public var isAllFeildsAreValid: Bool {
      return !title.isEmpty && title.count > 4
        && !eventAddress.isEmpty
        && !durationRawValue.isEmpty
        && !categoryRawValue.isEmpty
    }

    public var currentUser: User = .draff
  }

  public enum ViewAction: Equatable {
    case didAppear
    case didDisappear
    case titleChanged(String)
    case textFieldHeightChanged(CGFloat)
    case selectedDurations(DurationButtons)
    case selectedCategories(Categories)
    case selectedDurationIndex(Int)
    case showCategorySheet(Bool)
    case liveLocationToggleChanged(Bool)
    case isSearchSheet(isPresented: Bool)
    case locationSearch(LocationSearchAction)

    case submitButtonTapped
    case actionSheetButtonTapped
    case actionSheetDismissed
  }
}

public struct EventFormView: View {
  @Environment(\.colorScheme) var colorScheme

  public init(store: Store<EventFormState, EventFormAction>) {
    self.store = store
  }

  let store: Store<EventFormState, EventFormAction>

  public var body: some View {
    WithViewStore(
      self.store.scope(
        state: { $0.view },
        action: EventFormAction.view
      )
    ) { viewStore in
      ZStack(alignment: viewStore.state.isEventCreatedSuccessfully ? .top : .bottomTrailing) {

        if viewStore.state.isPostRequestOnFly {
          ProgressView()
        }

        Form {

          Text("Create Event Form")
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .center)

          Section {
            HStack {
              TextField(
                "Title",
                text: viewStore.binding(
                  get: \.title,
                  send: ViewAction.titleChanged
                )
              )
              .padding(5)
              .font(Font.system(size: 25, weight: .medium, design: .serif))
              // .hideKeyboardOnTap()
              .lineLimit(3)
              //              .background(
              //                colorScheme == .dark ?
              //                  Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
              //                  : Color(.systemGray6)
              //              )
              .foregroundColor(Color(UIColor.systemRed))
              .accentColor(Color.green)
//              .textFieldStyle(.roundedBorder)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.gray, lineWidth: 1)
              )
            }
            .padding(.vertical)

            HStack {
              Text("Event Duration")
                .font(.title).bold()

              Text(viewStore.durationRawValue)
                .font(.title).bold()
                .foregroundColor(
                  Color(
                    #colorLiteral(
                      red: 0.9154241085, green: 0.2969468832, blue: 0.2259359956, alpha: 1)))
            }
            .padding(.vertical)

            Picker(
              "Duration",
              selection: viewStore.binding(
                get: \.selectedDutaionButtons,
                send: ViewAction.selectedDurations
              ).animation()

            ) {
              ForEach(DurationButtons.allCases, id: \.self) { button in
                Text(button.rawValue).tag(button)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical)

            Button {
              viewStore.send(.actionSheetButtonTapped)
            } label: {
              HStack {
                VStack(alignment: .leading) {
                  Text("Select your")
                  Text("Categoris")
                }
                Spacer()
                Text("??? \(viewStore.categoryRawValue)")
                  .font(.title)
                  .foregroundColor(
                    Color(
                      #colorLiteral(
                        red: 0.9154241085,
                        green: 0.2969468832,
                        blue: 0.2259359956,
                        alpha: 1)
                    )
                  )
              }
              .padding(.vertical)
            }
            .confirmationDialog(
              self.store.scope(state: \.actionSheet),
              dismiss: .actionSheetDismissed
            )

            Toggle(
              isOn: viewStore.binding(
                get: \.liveLocationToggleisOn,
                send: ViewAction.liveLocationToggleChanged
              )
            ) {
              HStack {
                VStack(alignment: .leading) {
                  Text("Your event address \(viewStore.state.eventAddress)" as String)
                    .onTapGesture {
                      viewStore.send(.isSearchSheet(isPresented: true))
                    }
                }
                Spacer()
                Text("\(viewStore.state.liveLocationToggleisOn ? "  On" : "  Off")").font(.title)
              }
            }

            if viewStore.state.liveLocationToggleisOn {
              // swiftlint:disable line_length
              Text(
                "???? we will use your curent location as your event location if you want to choice other place then please click and turn off to get new window for choice your EVENT location"
              )
              .font(.system(size: 13, weight: .light, design: .rounded))
              .foregroundColor(Color.red)
              .padding([.top, .bottom], 10)
            }
          }
        }
        .padding(.bottom, 20)
        .disabled(viewStore.state.isPostRequestOnFly)

        if viewStore.state.isEventCreatedSuccessfully {
          successfullyCreatedNoticeView(viewStore)
        } else {
          sendButton(viewStore)
        }
      }
      .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
      .navigationTitle("Event Form")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        viewStore.send(.didAppear)
      }
      .sheet(
        store.scope(state: \.locationSearchState, action: EventFormAction.locationSearch),
        mapState: replayNonNil(),
        onDismiss: { ViewStore(store.stateless).send(.isSearchSheet(isPresented: true)) },
        content: LocationSearchView.init(store:)
      )
      .edgesIgnoringSafeArea(.all)
    }
  }

  fileprivate func sendButton(
    _ viewStore: ViewStore<EventFormView.ViewState, EventFormView.ViewAction>
  ) -> some View {
    return VStack {
      Button {
        viewStore.send(.submitButtonTapped)
      } label: {
        if viewStore.state.isAllFeildsAreValid {
          HStack(spacing: 10) {
            Text("Submit")
              .foregroundColor(.white)
              .padding(.leading, 10)

            Image(systemName: "chevron.right")
              .padding(.trailing, 8)
              .font(.system(size: 30, weight: .bold, design: .rounded))
              .foregroundColor(.white)
          }
          .font(.system(size: 26, weight: .bold, design: .rounded))
          .padding(10)

        } else {
          Image(systemName: "dot.circle")
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
        }
      }
      .background(viewStore.state.isAllFeildsAreValid ? Color.blue : Color.red)
      .clipShape(viewStore.state.isAllFeildsAreValid ? AnyShape(Capsule()) : AnyShape(Circle()))
      .animation(.default)
      .disabled(!viewStore.state.isAllFeildsAreValid && viewStore.isPostRequestOnFly)
      .opacity(viewStore.isPostRequestOnFly ? 0 : 1)
      .overlay(
        ActivityIndicator()
          .frame(maxWidth: .infinity)
          .padding()
          .opacity(viewStore.isPostRequestOnFly ? 1 : 0)
      )
      .padding()
      .padding(.bottom, 16)

    }
  }

  fileprivate func successfullyCreatedNoticeView(
    _ viewStore: ViewStore<EventFormView.ViewState, EventFormView.ViewAction>
  ) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack {
        HStack {
          Image(systemName: "checkmark.shield.fill")
            .font(.title3.bold())
            .foregroundColor(Color(UIColor.systemBlue))
          Text("Your '\(viewStore.title)' event have successfully created!")
            .font(.title3.bold())
            .foregroundColor(Color(UIColor.systemBlue))
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(UIColor.systemBackground))
    .cornerRadius(8)
    .shadow(
      color: colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3),
      radius: 20
    )
    .padding()
    .padding(.top, 65)
  }
}

struct EventFormView_Previews: PreviewProvider {
  static let store = Store(
    initialState: EventFormState.validEventForm,
    reducer: eventFormReducer,
    environment: EventFormEnvironment(
      eventClient: .empty,
      mainQueue: .immediate
    )
  )

  static var previews: some View {
    Text("Background").sheet(isPresented: .constant(true)) {
      EventFormView(store: store)
        // .redacted(reason: .placeholder)
        // .redacted(reason: EventsState.events.isLoadingPage ? .placeholder : [])
//        .environment(\.colorScheme, .dark)
    }
  }
}
