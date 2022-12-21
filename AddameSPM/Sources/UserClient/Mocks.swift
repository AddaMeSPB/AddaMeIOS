////
////  UserClient.swift
////
////
////  Created by Saroar Khandoker on 27.01.2021.
////
//
// import Combine
// import Foundation
// import AddaSharedModels
//
// extension UserClient {
//  public static let happyPath = Self(
//    userMeHandler: { _ in UserOutput.withAttachments },
//    update: { _ in
//        UserOutput.withAttachments.fullName = "HappyPath"
//      return UserOutput.withAttachments
//    },
//    delete: { _ in true }
//  )
//
//  public static let failed = Self(
//    userMeHandler: { _ in UserOutput.withAttachments },
//    update: { _ in UserOutput.withAttachments },
//    delete: { _ in false }
//  )
// }
