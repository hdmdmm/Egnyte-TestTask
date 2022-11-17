//
//  NetworkService.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation
import Combine

public struct DefaultNetworkService {
  private let sessionManager: NetworkSessionManagerProtocol
  init( sessionManager: NetworkSessionManagerProtocol ) {
    self.sessionManager = sessionManager
  }
}

extension DefaultNetworkService: NetworkServiceProtocol {
  public func request(endpoint: Request) -> AnyPublisher<(data: Data?, progress: Progress), Error> {
    let urlRequest = URLRequest(url: endpoint.url)
    return sessionManager.downLoadTask(request: urlRequest)
      .tryMap(transform(_:))
      .mapError(transform(_:))
      .map { ($0.data, $0.progress) }
      .eraseToAnyPublisher()
  }

  private func transform(_ error: Error) -> NetworkError {
    if let error = error as? NetworkError {
      return error
    }
    guard let error = error as? URLError else {
      return .generic(error)
    }
    if error.code == .notConnectedToInternet
        || error.code == .networkConnectionLost {
      return .notConnected
    }
    if error.code == .cancelled {
      return .cancelled
    }
    if error.code == .badURL
        || error.code == .unsupportedURL {
      return .urlGeneration
    }
    return .generic(error)
  }

  private func transform( _ element: (data: Data?, progress: Progress, response: URLResponse)
  ) throws -> (data: Data?, progress: Progress, response: URLResponse) {
    guard let statusCode = statusCode(from: element.response) else { return element }
    throw NetworkError.error(statusCode: statusCode, data: element.data)
  }

  private func statusCode(from response: URLResponse) -> Int? {
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
          !((200 ..< 300) ~= statusCode)
    else {
      return nil
    }
    return statusCode
  }
}
