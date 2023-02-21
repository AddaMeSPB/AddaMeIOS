//
//  EventForm.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import Foundation
import MapKit
import SwiftUI
import BSON
import ComposableArchitecture
import ComposableArchitectureHelpers
import MapView
import AddaSharedModels
import SwiftUIExtension
import SwiftUIHelpers
import FoundationExtension

extension EventFormView {

    public struct ViewState: Equatable {
        public var title: String
        public var maxTitleCharacters: Int
        public var textFieldHeight: CGFloat
        public var durationRawValue: String
        public var selectedDurationIndex: Int
        public var selectedCateforyID: ObjectId?
        public var showCategorySheet: Bool
        public var liveLocationToggleisOn: Bool
        public var selectLocationtoggleisOn: Bool

        public var selectedTag: String?
        public var showSuccessActionSheet: Bool
        public var placeMark: Placemark

        public var selectedPlace: EventResponse?
        public var currentPlace: EventResponse?
        public var eventAddress: String
        public var selectedDutaionButtons: DurationButtons
        public var actionSheet: ConfirmationDialogState<HangoutForm.Action>?
        public var alert: AlertState<HangoutForm.Action>?
        public var locationSearchState: LocationSearch.State?
        public var isPostRequestOnFly: Bool
        public var isEventCreatedSuccessfully: Bool
        public var category: String

        public var isSheetPresented: Bool
        public var isAllFeildsAreValid: Bool
        public var currentUser: UserOutput
        public var isLocationSearchNavigate: Bool

        init(state: HangoutForm.State) {
            self.title = state.title
            self.maxTitleCharacters = state.maxTitleCharacters
            self.textFieldHeight = state.textFieldHeight
            self.durationRawValue = state.durationRawValue
            self.selectedDurationIndex = state.selectedDurationIndex
            self.selectedCateforyID = state.selectedCateforyID
            self.showCategorySheet = state.showCategorySheet
            self.liveLocationToggleisOn = state.liveLocationToggleisOn
            self.selectLocationtoggleisOn = state.selectLocationtoggleisOn
            self.selectedTag = state.selectedTag
            self.showSuccessActionSheet = state.showSuccessActionSheet
            self.placeMark = state.placeMark
            self.selectedPlace = state.selectedPlace
            self.currentPlace = state.currentPlace
            self.eventAddress = state.eventAddress
            self.selectedDutaionButtons = state.selectedDutaionButtons
            self.actionSheet = state.actionSheet
            self.alert = state.alert
            self.locationSearchState = state.locationSearchState
            self.isPostRequestOnFly = state.isPostRequestOnFly
            self.isEventCreatedSuccessfully = state.isEventCreatedSuccessfully
            self.category = state.category
            self.isSheetPresented = state.locationSearchState != nil
            self.isAllFeildsAreValid = !state.title.isEmpty
                && state.title.count > 3
                && !state.eventAddress.isEmpty
                && !state.durationRawValue.isEmpty
                && !state.category.isEmpty

            self.currentUser = state.currentUser
            self.isLocationSearchNavigate = state.locationSearchState != nil
        }
  }

    public enum ViewAction: Equatable {
        case onAppear
        case onDisappear
        case titleChanged(String)
        case textFieldHeightChanged(CGFloat)
        case selectedDurations(DurationButtons)
        case selectedDurationIndex(Int)
        case selectedCategory(AddaSharedModels.CategoryResponse)
        case showCategorySheet(Bool)
        case liveLocationToggleChanged(Bool)
        case isLocationSearch(navigate: Bool)
        case locationSearch(LocationSearch.Action)

        case submitButtonTapped
        case actionSheetButtonTapped
        case actionSheetDismissed
    }
}

public struct EventFormView: View {
    @Environment(\.colorScheme) var colorScheme
    let liveLocationNote = """
    📍 we will use your curent location as your event location if you want to choice other place,
    then please click and turn off to get new window for choice your EVENT location
    """

    let store: StoreOf<HangoutForm>

      public init(store: StoreOf<HangoutForm>) {
        self.store = store
      }

    public var body: some View {

        //self.store, observe: ViewState.init, send: Hangouts.Action.init

        WithViewStore(self.store, observe: ViewState.init, send: HangoutForm.Action.init) { viewStore in
        
        ZStack(alignment: viewStore.state.isEventCreatedSuccessfully ? .top : .bottomTrailing) {

            if viewStore.state.isPostRequestOnFly {
                ProgressView()
            }

            Form {
                Section {

                    VStack(alignment: .leading) {
                        Text("I want to 👇🏼")
                            .font(.title2).fontWeight(.medium)
                            .padding(.top, 10)
                            .padding(.bottom, -5)

                        titleInput(viewStore)

                        Text("Max of \(viewStore.maxTitleCharacters) Characters")
                            .font(Font.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(viewStore.maxTitleCharacters <= 27 ? Color.blue : Color(UIColor.systemRed))
                            .padding(.top, -5)
                    }

                    HStack {

                        Text("Event Duration")
                            .font(.title).bold()

                        Text(viewStore.durationRawValue)
                            .font(.title).bold()
                            .foregroundColor(Color.blue)
                    }
                    .padding(.vertical)

                    Picker(
                        "Duration",
                        selection: viewStore.binding(
                            get: \.selectedDutaionButtons,
                            send: EventFormView.ViewAction.selectedDurations
                        ).animation()
                    ) {
                        ForEach(DurationButtons.allCases, id: \.self) { button in
                            Text(button.rawValue).tag(button)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)

                    Button {viewStore.send(.actionSheetButtonTapped)} label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Select your")
                                Text("Categoris")
                            }
                            Spacer()
                            Text("⇡ \(viewStore.category)")
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
                            send: EventFormView.ViewAction.liveLocationToggleChanged
                        )
                    ) {
                        VStack(alignment: .leading) {
                            Text("Event address")
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.vertical, 3)


                            Text("\(viewStore.state.eventAddress)")
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    viewStore.send(.isLocationSearch(navigate: true))
                                }

                        }
                    }

                    if viewStore.state.liveLocationToggleisOn {
                        Text(liveLocationNote)
                            .font(.system(size: 13, weight: .light, design: .rounded))
                            .foregroundColor(Color.red)
                            .padding([.top, .bottom], 10)
                    }

                    Spacer()
                }
            }
            .padding(.top, 50)
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture().onChanged { _ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
            .disabled(viewStore.state.isPostRequestOnFly)

            if viewStore.state.isEventCreatedSuccessfully {
                successfullyCreatedNoticeView(viewStore)
                    .padding(.top, 30)
            } else {
                sendButton(viewStore)
                    .padding(.bottom, 100)
            }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          .onAppear { ViewStore(self.store).send(.onAppear) }
          
          .alert(self.store.scope(state: { $0.alert }), dismiss: .alertDismissed)
          .navigationTitle("Hangout Form")
          .navigationBarTitleDisplayMode(.inline)
          .background(
            NavigationLink(
              destination: IfLetStore(
                self.store.scope(
                  state: \.locationSearchState,
                  action: HangoutForm.Action.locationSearch
                )
              ) {
                  LocationSearchView(store: $0)
              },
              isActive: viewStore.binding(
                get: \.isLocationSearchNavigate,
                send: { .isLocationSearch(navigate: $0) }
              )
            ) {}
          )
    //      .sheet(
    //        store.scope(state: \.locationSearchState, action: HangoutForm.Action.locationSearch),
    //        mapState: replayNonNil(),
    //        onDismiss: { ViewStore(store.stateless).send(.isSearchSheet(isPresented: true)) },
    //        content: LocationSearchView.init(store:)
    //      )
          .edgesIgnoringSafeArea(.all)

        }
    }

    fileprivate func titleInput(_ viewStore: ViewStore<EventFormView.ViewState, EventFormView.ViewAction>) -> some View {

        let isValid = viewStore.maxTitleCharacters <= 27

        if #available(iOS 16.0, *) {
            return TextField(
                "Hangout Name",
                text: viewStore.binding(
                    get: \.title,
                    send: EventFormView.ViewAction.titleChanged
                )
                .removeDuplicates(),
                axis: .vertical
            )
            .padding()
            .padding(.leading, -5)
            .font(Font.system(size: 25, weight: .medium, design: .serif))
            .lineLimit(2)
            .background(
              colorScheme == .dark ?
              Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
              : Color(.systemGray6)
            )
            .foregroundColor(isValid ? Color.blue : Color(UIColor.systemRed))
            .accentColor(Color.green)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(isValid ? Color.blue : Color(UIColor.systemRed), lineWidth: 1)
            )
            .padding(.vertical, 10)

        } else {
            return TextViewFromUIKit(
                text: viewStore.binding(
                    get: \.title,
                    send: EventFormView.ViewAction.titleChanged
                )
                .removeDuplicates()
              )
              .padding(.leading, 5)
              .padding(.top, 5)
              .padding(.bottom, -5)
              .background(
                colorScheme == .dark ?
                Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
                : Color(.systemGray6)
              )
              .foregroundColor(isValid ? Color.blue : Color(UIColor.systemRed))
              .accentColor(Color.green)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isValid ? Color.blue : Color(UIColor.systemRed), lineWidth: 1)
              )
              .padding(.vertical, 10)
        }
    }

    fileprivate func sendButton(_ viewStore: ViewStore<EventFormView.ViewState, EventFormView.ViewAction>) -> some View {
    return VStack {
      Button {
        viewStore.send(.submitButtonTapped)
      } label: {
        if viewStore.isAllFeildsAreValid {
          HStack(spacing: 10) {
            Text("Submit")
              .foregroundColor(.white)
              .padding(.horizontal, 10)
          }
          .font(.system(size: 26, weight: .bold, design: .rounded))
          .padding(10)

        }
      }
      .background(viewStore.isAllFeildsAreValid ? Color.blue : Color.red)
      .clipShape(viewStore.isAllFeildsAreValid ? AnyShape(Capsule()) : AnyShape(Circle()))
      .animation(.default)
      .disabled(!viewStore.isAllFeildsAreValid)
      .opacity(!viewStore.isAllFeildsAreValid && !viewStore.isPostRequestOnFly ? 0 : 1)
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

  fileprivate func successfullyCreatedNoticeView(_ viewStore: ViewStore<EventFormView.ViewState, EventFormView.ViewAction>) -> some View {
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
    static var store = Store(
        initialState: HangoutForm.State.validEventForm,
        reducer: HangoutForm()
    )

  static var previews: some View {
    NavigationView {
        EventFormView(store: store)
    }
  }
}
