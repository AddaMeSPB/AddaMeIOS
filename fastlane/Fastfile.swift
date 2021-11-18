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
         scheme: "AddameCI",
         derivedDataPath: "derivedData",
         buildForTesting: .userDefined(true),
         xcargs: "CI=true")
  }

  func unitTestLane() {
    desc("Run unit tests")
    scan(
      workspace: "Addame.xcworkspace",
      scheme: "AddameCI",
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
//    incrementBuildNumber(xcodeproj: "Addame.xcodeproj")
    echo(message: "DumpType parameter value \(dumpType)")
    incrementVersionNumber(bumpType: dumpType, xcodeproj: "Addame.xcodeproj")
    buildApp(workspace: "Addame.xcworkspace", scheme: "AddamePro")
    uploadToTestflight(username: "\(appleID)", teamId: "\(teamId)")
  }

  func releaseLane() {
//    lane :release do
//      capture_screenshots # generate new screenshots for the App Store
//      sync_code_signing(type: "appstore")
// # see code signing guide for more information
//      build_app(scheme: "MyApp")
//      upload_to_app_store # upload your app to App Store Connect
//      slack(message: "Successfully uploaded a new App Store build")
//    end
    // getPushCertificate(appIdentifier: <#String#>, username: <#String#>, p12Password: <#String#>)
    buildApp()
    uploadToAppStore()
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
