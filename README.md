# Adda2 iOS app
Adda2 is a free, open source, messaging app for simple private communication with friends. 

[![Available on the App Store](http://cl.ly/WouG/Download_on_the_App_Store_Badge_US-UK_135x40.svg)](https://apps.apple.com/app/id1538487173)

## Technical overview
- [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)
- Swift Package Manager
- Unit tests
- UI tests
- Modularisation


This is a project demonstrating the capabilities of [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) and Swift Package Manager.
TCA allows developers to fully encapsulate state, actions and environment to control its side effects.

This allows for easier dependency management where we can have more control of what goes where when needed.

Compared to other ways of building and developing applications, TCA allows for building new **Features** in parallel in a big team.
Productivity increases while cognitive load stays at a manageable level.

### Use Adda to:
* Discover users who live nearby
* You can see nearby stories anonymously
* You can see any place on the map to explore new friends and events
* Locate content anywhere on the map
* Build your own local social network
* Be social, Be Friendly

Adda2, a new way location-based network to meet new people and know more about them.  With real-time events, hangouts, and communication. You can post what you want to do, nearby so people can see: Grabbing a taxi, selling, buying, events around you, hangouts or helping out those near you are some examples.​ We believe with this app you can meet people in real life much easier. Our goal is to let people connect in real life as opposed to just connecting on your screen.

Meeting new neighbors​ is easier than ever.

## Requirements

### Build
- Xcode 12
- SwiftUI 100%
- Swift 5

### Deployment target
- iOS 14.0

### Privacy - Contacts Usage Description
Importent Note: Adda2 uses your contacts to find users you konw. We do not store your contacts on the server.
code here: https://github.com/AddaMeSPB/AddaMeAuth/blob/master/Sources/App/Controllers/ContactController.swift#L21


### SwiftUI Test for create screenshot with fastlane
[YouTube Link](https://youtu.be/A_Xvjs6frCQ)

![SwiftUI Test](https://user-images.githubusercontent.com/8770772/102008996-91051800-3d45-11eb-8bd0-1fd05d7acfbc.gif)
