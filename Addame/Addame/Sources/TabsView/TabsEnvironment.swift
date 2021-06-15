//
//  TabsEnvironment.swift
//  
//
//  Created by Saroar Khandoker on 04.06.2021.
//

import Combine
import ComposableArchitecture

public struct TabsEnvironment {
  
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  
  public init(
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
  }
    
}
