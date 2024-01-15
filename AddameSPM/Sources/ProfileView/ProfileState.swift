//
//  ProfileState.swift
//
//
//  Created by Saroar Khandoker on 06.04.2021.
//

import ComposableArchitecture
import AddaSharedModels
import SwiftUI
import ImagePicker
import MyEventsView

// swiftlint:disable all
extension Profile.State {
    private static var userWithoutAvatar = UserOutput.withFirstName

    private static var userWithAvatar = UserOutput.withAttachments

    public static let profileStateWithUserWithAvatar = Self(
        alert: nil,
        user: userWithAvatar,
        imageURLs: [
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338279849.heic",
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1607338304864.heic",
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605875164101.heic",
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605811106589.jpeg",
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/1605796266916.jpeg",
            "https://adda.nyc3.digitaloceanspaces.com/uploads/images/5fabb05d2470c17919b3c0e2/5fabb05d2470c17919b3c0e2_1605792619988.jpeg"
        ], 
        settingsState: .init()
    )

    public static let profileStateWithUserWithoutAvatar = Self(
        alert: nil,
        user: userWithoutAvatar,
        settingsState: .init()
    )
}
