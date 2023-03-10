import Foundation

public struct AppConfiguration {
    public enum ApiEnvironment: String {
        case development
        case production

        var isTestEnvironment: Bool {
            self != .production
        }

        var url: String {
            switch self {
            case .development:
                //return "http://172.16.1.136:8080"
                //return "http://10.0.0.81:8080"
                //return "http://172.20.10.4:8080"
                //return "http://10.0.1.4:8080"
//                return "http://10.10.18.148:8080"
                return "http://192.168.9.78:8080"
            case .production:
                return "https://addame.com"
            }
        }


        var webSocketUrl: String {
            switch self {
            case .development:
                //return "ws://172.16.1.136:8080/v1/chat"
                //return "ws://10.0.0.81:8080/v1/chat"
                //return "ws://172.20.10.4:8080/v1/chat"
                //return "ws://10.0.1.4:8080/v1/chat"
//                return "ws://10.10.18.148:8080/v1/chat"
                return "ws://192.168.9.78:8080/v1/chat"
            case .production:
                return  "wss://addame.com/v1/chat"
            }
        }


        var shortDescription: String {
            switch self {
            case .development:
                return "Dev"
            case .production:
                return "Prod"
            }
        }

    }

    private enum Keys {
        static let appName = "ADDAME_IOS_APP_NAME"
        static let apiEnvironment = "ADDAME_IOS_ENVIRONMENT"
    }

    public let appName: String
    public let apiURL: String
    public let webSocketUrl: String
    public let apiEnvironment: ApiEnvironment
    public let completeAppVersion: String?

    public init(
        appName: String,
        apiURL: String,
        webSocketUrl: String,
        apiEnvironment: ApiEnvironment,
        completeAppVersion: String?
    ) {
        self.appName = appName
        self.apiURL = apiURL
        self.webSocketUrl = webSocketUrl
        self.apiEnvironment = apiEnvironment
        self.completeAppVersion = completeAppVersion
    }

}

extension AppConfiguration {

    public static func live(bundle: Bundle) -> AppConfiguration {
        AppConfiguration(bundle: bundle)
    }

    public init(bundle: Bundle) {
        guard
            let appName = bundle.object(forInfoDictionaryKey: Keys.appName) as? String,
            let apiEnvironmentKey = bundle.object(forInfoDictionaryKey: Keys.apiEnvironment) as? String,
            let apiEnvironment = ApiEnvironment(rawValue: apiEnvironmentKey)
        else {
            fatalError("Couldn't init environment from bundle: \(bundle.infoDictionary ?? [:])")
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            let appVersionString = "\(version) (\(buildNumber))"
            completeAppVersion = apiEnvironment.isTestEnvironment
            ? appVersionString + " (\(apiEnvironment.shortDescription))"
            : appVersionString
        } else {
            completeAppVersion = nil
        }

        self.appName = appName
        self.apiURL = apiEnvironment.url
        self.webSocketUrl = apiEnvironment.webSocketUrl
        self.apiEnvironment = apiEnvironment
    }

}

extension AppConfiguration {

    public static func mock() -> AppConfiguration {
        AppConfiguration(
            appName: "Addame2",
            apiURL: "http://10.0.1.4:8080",
            webSocketUrl: "ws://10.10.18.148:8080/v1/chat",
            apiEnvironment: .development,
            completeAppVersion: "1.2.6 (22)"
        )
    }

}

import Dependencies

private enum AppConfigurationKey: DependencyKey {
    public static let liveValue = AppConfiguration.live(bundle: Bundle.main)
    public static let testValue = AppConfiguration.mock()
}

extension DependencyValues {
    public var appConfiguration: AppConfiguration {
        get { self[AppConfigurationKey.self] }
        set { self[AppConfigurationKey.self] = newValue }
    }
}
