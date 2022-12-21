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
                return "http://10.0.1.4:8080"
//                return "http://192.168.1.29:8080"
            case .production:
//                ROOT_URL = https://addame.com/v1
//                WEB_SOCKET_URL = ws:/$()/addame.com/v1/chat

                return "https://addame.com"
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
    public let apiEnvironment: ApiEnvironment
    public let completeAppVersion: String?

    public init(
        appName: String,
        apiURL: String,
        apiEnvironment: ApiEnvironment,
        completeAppVersion: String?
    ) {
        self.appName = appName
        self.apiURL = apiURL
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
        self.apiEnvironment = apiEnvironment
    }

}

extension AppConfiguration {

    public static func mock() -> AppConfiguration {
        AppConfiguration(
            appName: "Addame2",
            apiURL: "http://10.0.1.4:8080",
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
