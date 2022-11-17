//
//  NetworkSession.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation
import Combine

public protocol NetworkSessionManagerProtocol {
  func downLoadTask(request: URLRequest) -> AnyPublisher<(data: Data?, progress: Progress, response: URLResponse), URLError>
}

public struct DefaultNetworkSessionManager: NetworkSessionManagerProtocol {
  private let session: URLSession
  
  public init(configuration: URLSessionConfiguration) {
    session = URLSession(configuration: configuration)
  }

  public func downLoadTask(request: URLRequest) -> AnyPublisher<(data: Data?, progress: Progress, response: URLResponse), URLError> {
    session.downloadDataTaskPublisher(for: request).eraseToAnyPublisher()
  }
}
