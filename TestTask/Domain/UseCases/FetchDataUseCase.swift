//
//  FetchDataUseCase.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation
import Combine

public protocol FetchDataUseCaseProtocol {
  func fetchData(by resourceName: String) -> AnyPublisher<DataProgressEntity, Error>
}

public struct SourceRequest: Request {
  public var url: URL
}

public struct FetchDataUseCase: FetchDataUseCaseProtocol {
  private var dataLoader: DownloadingDataServiceProtocol
  private var configurator: SourcePathConfiguratorProtocol
  public init(
    dataLoader: DownloadingDataServiceProtocol,
    configurator: SourcePathConfiguratorProtocol
  ) {
    self.dataLoader = dataLoader
    self.configurator = configurator
  }
  
  public func fetchData(by resourceName: String) -> AnyPublisher<DataProgressEntity, Error> {
    guard let url = configurator.urlDataSource(path: resourceName) else {
      return Fail(error: UseCasesErrors.wrongResourceName).eraseToAnyPublisher()
    }

    let sourceRequest = SourceRequest(url: url)
    return dataLoader.downloadData(by: sourceRequest)
      .map { DataProgressEntity(data: $0.data, progress: $0.progress) }
      .eraseToAnyPublisher()
  }
}

