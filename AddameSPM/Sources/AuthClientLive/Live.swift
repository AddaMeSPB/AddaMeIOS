//
//  AuthAPI.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import AuthClient
import Combine
import Foundation
import FoundationExtension
import InfoPlist
import AddaSharedModels

// extension AuthClient {
//    public static var live: AuthClient = .init(
//        login: { input in
//            return try await AuthClient.apiClient.decodedResponse(
//                for: .authEngine(.authentication(.login(input: input))),
//                as: VerifySMSInOutput.self,
//                decoder: .iso8601
//            ).value
//        },
//        verification: { input in
//            return try await AuthClient.apiClient.decodedResponse(
//                for: .authEngine(.authentication(.verifySms(input: input))),
//                as: LoginResponse.self,
//                decoder: .iso8601
//            ).value
//        }
//    )
// }
