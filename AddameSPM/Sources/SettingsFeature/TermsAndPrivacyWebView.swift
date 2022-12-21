import SwiftUI
import ComposableArchitecture
import SwiftUIExtension
import WebKit

public class WebViewModel: ObservableObject {
    @Published public var link: String
    @Published public var didFinishLoading: Bool = true

    public init (link: String) {
        self.link = link
    }
}

extension WebViewModel: Equatable {
    public static func == (lhs: WebViewModel, rhs: WebViewModel) -> Bool {
        return lhs.link == rhs.link && lhs.didFinishLoading == rhs.didFinishLoading
    }
}

public struct WebView: UIViewRepresentable {
    public func updateUIView(_ uiView: UIView, context: Context) {}

    @ObservedObject var viewModel: WebViewModel
    let webView = WKWebView()

    public func makeCoordinator() -> Coordinator {
        Coordinator(self.viewModel)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.viewModel.didFinishLoading = webView.isLoading
        }
    }

    public func makeUIView(context: Context) -> UIView {
        self.webView.navigationDelegate = context.coordinator

        if let url = URL(string: self.viewModel.link) {
            self.webView.load(URLRequest(url: url))
        }

        return self.webView
    }
}

public struct TermsAndPrivacy: ReducerProtocol {

    public struct State: Equatable {

        @BindableState public var wbModel: WebViewModel

        public init(wbModel: WebViewModel) {
            self.wbModel = wbModel
        }
    }


    public enum Action: Equatable, BindableAction {
      case binding(BindingAction<State>)
      case leaveCurentPageButtonClick
      case terms
      case privacy
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .leaveCurentPageButtonClick:
                return .none
            case .terms, .privacy:
                return .none
            }
        }
    }

}

public struct TermsAndPrivacyWebView: View {


  public let store: StoreOf<TermsAndPrivacy>
  @ObservedObject var viewStore: ViewStoreOf<TermsAndPrivacy>
  @ObservedObject var wbModel: WebViewModel

    public init(store: StoreOf<TermsAndPrivacy>) {
        self.store = store
        let viewStore = ViewStore(store, observe: { $0 })
        self.viewStore = viewStore
        self.wbModel = viewStore.wbModel
    }


  public var body: some View {
    WithViewStore(self.store) { viewStore in

        WebView(viewModel: viewStore.wbModel)
                .overlay(
                    Button(
                        action: {
                            viewStore.send(.leaveCurentPageButtonClick)
                        },
                        label: {
                            Image(systemName: "xmark.circle").font(.title)
                        }
                    )
                    .padding(.bottom, 10)
                    .padding(),

                    alignment: .bottomTrailing
                )
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        .font(.largeTitle)
                        .opacity(viewStore.wbModel.didFinishLoading ? 1 : 0)
                    ,

                    alignment: .center
                )

    }
  }
}

// struct TermsAndPrivacyWebView_Previews: PreviewProvider {
//
//  static let store = Store(
//    initialState: TermsAndPrivacyState(urlString: "http://10.0.1.3:3030/privacy"),
//    reducer: termsAndPrivacyReducer, environment: .init()
//  )
//
//  static var previews: some View {
//    TermsAndPrivacyWebView(store: store)
//  }
// }

