//
//  AppDelegate.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import UIKit

  @main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var container: AppDIContainer!

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let appConfig: AppConfigurator
    let source: ImageNameSource
    do {
      appConfig = try AppConfigurator(fileName: "AppConfigurator")
      source = try ImageNameSource(fileName: "images")
    }
    catch {
      // TODO: Notice the error message via Logger.
      // This is a critical issue for the normal working application
      // Message: "Due to issues in the application config, the application was stopped"
      // ApplicationLogger(error.localizedError)
      // Or another way of assertion delivery process,
      // this is a crash using fatalError(error.localizedError)
      return true
    }
    
    container = AppDIContainer(config: appConfig, source: source)
    
    createWindow(with: container.rootViewController)
    
    return true
  }

  // MARK: private API helper
  private func createWindow(with rootViewController: UIViewController) {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = rootViewController
    window?.makeKeyAndVisible()
  }
}

