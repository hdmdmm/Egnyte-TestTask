//
//  DataLoader.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation
import Combine

public protocol NetworkServiceProtocol {
  func request(endpoint: Request) -> AnyPublisher<(data: Data?, progress: Progress), Error>
}

public struct DownloadingDataService: DownloadingDataServiceProtocol {
  private let networkService: NetworkServiceProtocol

  public init( networkService: NetworkServiceProtocol ) {
    self.networkService = networkService
  }

  public func downloadData(by request: Request) -> AnyPublisher<(data: Data?, progress: Progress), Error> {
    return networkService.request(endpoint: request).eraseToAnyPublisher()
  }
}
