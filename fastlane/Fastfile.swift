// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {

  let appleID = environmentVariable(get: "appleID")
  let teamId = environmentVariable(get: "teamId")

  func swiftLintLane() {
    desc("Run SwiftLint")
    swiftlint(configFile: ".swiftlint.yml",
              strict: true,
              ignoreExitStatus: false,
              raiseIfSwiftlintError: true,
              executable: "swiftlint"
    )
  }

  func buildLane() {
    desc("Build for testing")
    scan(workspace: "Addame.xcworkspace",
         scheme: "Addame",
         derivedDataPath: "derivedData",
         buildForTesting: .userDefined(true),
         xcargs: "CI=true")
  }

  func unitTestLane() {
    desc("Run unit tests")
    scan(
      workspace: "Addame.xcworkspace",
      scheme: "Addame",
      device: "iPhone 12 Pro",
      resetSimulator: false,
      onlyTesting: ["EventFormViewTests"],
      derivedDataPath: "derivedData",
      testWithoutBuilding: .userDefined(false)
    )
  }

  func betaLane(withOptions options: [String: String]?) {
    let appVersion = options?["appVersion"]
    let dumpTypeOptional = options?["dumpType"]
    let dumpType = dumpTypeOptional ?? "patch"

    if appVersion != nil, dumpTypeOptional != nil {
      echo(message: "Only one parameter can be used: appVersion or dumpType")
      return
    }

    if !["major", "minor", "patch"].contains(dumpType) {
      echo(message: "Unknown parameter value \(dumpType)")
      return
    }

    desc("Push a new beta build to TestFlight")
    incrementBuildNumber(xcodeproj: "Addame.xcodeproj")
    incrementVersionNumber(bumpType: "minor", xcodeproj: "Addame.xcodeproj")
    buildApp(workspace: "Addame.xcworkspace", scheme: "Addame")
    uploadToTestflight(username: "\(appleID)", teamId: "\(teamId)")
  }

  func sandbox() {
    desc("Sandbox start")
    captureScreenshots()
    frameScreenshots(white: .userDefined(true))
    frameit(path: "./fastlane/screenshots")
  }

  func submit_review() {
    desc("Submit for rreview")
    frameit(white: .userDefined(true))
    deliver(
      skipBinaryUpload: .userDefined(true),
      skipScreenshots: .userDefined(false),
      skipMetadata: .userDefined(true),
      force: .userDefined(true),
      submitForReview: .userDefined(true),
      automaticRelease: .userDefined(true)
    )
  }
}

// platform :ios do
//  desc "Push a new beta build to TestFlight"
//  lane :tf do
//    increment_build_number(xcodeproj: "AddaMeIOS.xcodeproj")
//    build_app(scheme: "AddaMeIOS")
//    upload_to_testflight
//  end
//
//  desc "Push a new release build"
//  lane :release do
//    precheck
//    increment_build_number(xcodeproj: "AddaMeIOS.xcodeproj")
//    snapshot
//    frameit
//    deliver(
//      submit_for_review: true,
//      automatic_release: true,
//      force: true, # Skip HTMl report verification
//      skip_metadata: true,
//      skip_screenshots: false,
//      skip_binary_upload: true
//    )
//  end
//
//  desc "Generate new localized screenshots"
//  lane :screenshots do
//    capture_screenshots(workspace: "AddaMeIOS.xcodeproj", scheme: "AddaMeIOSUITests")
//  end
//
//  lane :sandbox do
//    capture_screenshots
//    frame_screenshots(white: true)
//    frameit(path: "./fastlane/screenshots")
//  end
//
//  lane :submit_review do
//    frame_screenshots(white: true)
//    frameit(path: "./fastlane/screenshots")
//    deliver(
//      submit_for_review: true,
//      automatic_release: true,
//      force: true, # Skip HTMl report verification
//      skip_metadata: true,
//      skip_screenshots: false,
//      skip_binary_upload: true
//    )
//  end
// end
