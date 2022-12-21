import Foundation
import Dependencies
import UIKit
import AddaSharedModels

extension URLRequest {

   fileprivate mutating func getToken() -> String? {
        let identifier = DependencyValues._current.build.identifier()
        let token = try? DependencyValues._current
            .keychainClient
            .readCodable(.token, identifier, RefreshTokenResponse.self)
        return token?.accessToken
    }

    mutating func setHeaders() {
        let token = getToken() ?? ""
        guard let infoDictionary = Bundle.main.infoDictionary else { return }

        let bundleName = infoDictionary[kCFBundleNameKey as String] ?? "NotifyWord"
        let marketingVersion = infoDictionary["CFBundleShortVersionString"].map { "/\($0)" } ?? ""
        let bundleVersion = infoDictionary[kCFBundleVersionKey as String].map { " bundle/\($0)" } ?? ""
        let gitSha = (infoDictionary["GitSHA"] as? String).map { $0.isEmpty ? "" : "git/\($0)" } ?? ""
        let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString ?? ""
        self.setValue(
          "\(bundleName)\(marketingVersion)\(bundleVersion)\(gitSha)",
          forHTTPHeaderField: "User-Agent"
        )
        self.setValue("\(identifierForVendor)", forHTTPHeaderField: "IdentifierForVendor")
        self.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
   }
}
