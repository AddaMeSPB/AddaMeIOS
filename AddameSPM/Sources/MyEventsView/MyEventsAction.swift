//
//  MyEventsAction.swift
//  
//
//  Created by Saroar Khandoker on 15.06.2022.
//

import SharedModels
import HTTPRequestKit

public enum MyEventAction: Equatable {}

public enum MyEventsAction: Equatable {
    case onApper
    case event(id: EventResponse.Item.ID, action: MyEventAction)
    case myEventsResponse(Result<EventResponse, HTTPRequest.HRError>)
}
