//
//  Mocks.swift
//
//
//  Created by Saroar Khandoker on 28.01.2021.
//

import Combine
import Foundation
import HTTPRequestKit
import AddaSharedModels

extension AuthClient {
  public static let happyPath = Self(
    login: { _ in .draff },
    verification: { _ in .draff }
  )

  public static let failing = Self(
    login: { _ in .draff },
    verification: { _ in .draff }
  )
}

extension String: Error {}
