//
//  AttachmentClient.swift
//
//
//  Created by Saroar Khandoker on 27.01.2021.
//

import Combine
import Foundation
import AddaSharedModels
import UIKit
import InfoPlist
import KeychainClient
import URLRouting
import SotoS3

public struct AttachmentClient {

    static public let apiClient: URLRoutingClient<SiteRoute> = .live(
        router: siteRouter.baseRequestData(
            .init(
                scheme: EnvironmentKeys.rootURL.scheme,
                host: EnvironmentKeys.rootURL.host,
                port: EnvironmentKeys.setPort(),
                headers: ["Authorization": ["Bearer "]]
            )
        )
    )

    public static let bucket = "adda"
    public static var bucketWithEndpoint = "https://adda.nyc3.digitaloceanspaces.com/"

    static public let client = AWSClient(
        credentialProvider: .static(
          accessKeyId: EnvironmentKeys.accessKeyId,
          secretAccessKey: EnvironmentKeys.secretAccessKey
        ),
        httpClientProvider: .createNew
    )

    public static let awsS3 = S3(
        client: client,
        region: .useast1,
        endpoint: "https://nyc3.digitaloceanspaces.com"
    )

    public typealias UploadImageToS3Handler = @Sendable (UIImage, String?, String?) async throws -> String
    public typealias UpdateUserImageURLHandler = @Sendable (AttachmentInOutPut) async throws -> AttachmentInOutPut

    public let uploadImageToS3: UploadImageToS3Handler
    public let updateUserImageURL: UpdateUserImageURLHandler

    public init(
        uploadImageToS3: @escaping UploadImageToS3Handler,
        updateUserImageURL: @escaping UpdateUserImageURLHandler
    ) {
        self.uploadImageToS3 = uploadImageToS3
        self.updateUserImageURL = updateUserImageURL
    }
}
