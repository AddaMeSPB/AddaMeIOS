//
//  Categories.swift
//  Categories
//
//  Created by Saroar Khandoker on 06.08.2021.
//

import Foundation

public enum Categories: String, CaseIterable, Codable, Equatable, Hashable {
  // swiftlint:disable identifier_name
  case General, Hangouts
  case LookingForAcompany = "Looking for a company"
  case Acquaintances, Work,
       Question, News, Services, Meal,
       Children, Shop, Mood, Sport, Accomplishment, Ugliness,
       Driver, Discounts, Warning, Health, Animals, Weekend,
       Education, Walker, Realty, Charity, Accident, Weather

  case GetTogether = "Get Together"
  case TakeOff = "Take Off"
  case IWillbuy = "I will buy"
  case AcceptAsAgift = "Accept as a gift"
  case TheCouncil = "The Council"
  case GiveAway = "Give Away"
  case LifeHack = "Life hack"
  case SellOff = "Sell Off"
  case Found
}
