//
//  AppDIContainer.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import UIKit

struct AppDIContainer {
  let config: AppConfigurator
  let source: ImageNameSource

  lazy var rootViewController: UINavigationController = {
    UINavigationController(rootViewController: makeViewController())
  }()

  private func makeDownloaderSessionConfiguration() -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    
    // Use existing cache data, regardless or age or expiration date,
    // loading from originating source only if there is no cached data.
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    
    // Handover mode seamlessly transitions between WiFi and cellular,
    // allowing an uninterrupted user experience.
    configuration.multipathServiceType = .handover
    
    // The request will now timeout when there’s no additional data received
    // for 30 seconds due to missing connectivity.
    configuration.waitsForConnectivity = true
    configuration.timeoutIntervalForRequest = 30
    
    // Use custom parameters in new instance of URLCache
    // and apply it for your configuration
//    configuration.urlCache = URLCache(memoryCapacity: 200_000_000, diskCapacity: 500_000_000)
    
    return configuration
  }
  
  private func makeNetworkLayer() -> NetworkServiceProtocol {
    let config = makeDownloaderSessionConfiguration()
    let sessionManager = DefaultNetworkSessionManager(configuration: config)
    return DefaultNetworkService(sessionManager: sessionManager)
  }
  
  private func makeDataLoadService() -> DownloadingDataServiceProtocol {
    DownloadingDataService(networkService: makeNetworkLayer())
  }
  
  private func makeRequestModel() -> DataRequestModel {
    // TODO: Add the list of screenshot files from plist
    // It's better to load the list from some clouds like firebase.storage, aws.s3 or any other.
    // 
    //return DataRequestModel(path: "/content/images", fileName: "Screenshot+2022-05-21+at+15.11.51.png")
    return DataRequestModel(path: nil, fileName: "800x800")
  }
  
  private func makeViewModel() -> RootViewModel {
    let loader = makeDataLoadService()
    let useCase = FetchDataUseCase(dataLoader: loader, configurator: config)
    return RootViewModel(source: source, fetchDataUseCase: useCase)
  }

  private func makeViewController() -> UIViewController {
    let viewModel = makeViewModel()
    return RootViewController(viewModel: viewModel)
  }
}
