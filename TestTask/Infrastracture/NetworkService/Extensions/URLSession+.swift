//
//  URLSession+extension.swift
//  ImageLoader
//
//  Created by Dmitry Kh on 10.10.22.
//

import Foundation
import Combine

extension URLSession {
  public func downloadDataTaskPublisher(for request: URLRequest) -> URLSession.DownloadDataTaskPublisher {
    .init(request: request, session: self)
  }
  
  public struct DownloadDataTaskPublisher: Publisher {
    public typealias Output = (data: Data?, progress: Progress, response: URLResponse)
    public typealias Failure = URLError
    
    public let request: URLRequest
    public let session: URLSession
    
    init (request: URLRequest, session: URLSession) {
      self.request = request
      self.session = session
    }
    
    public func receive<S>(subscriber: S) where
    S : Subscriber, DownloadDataTaskPublisher.Failure == S.Failure, DownloadDataTaskPublisher.Output == S.Input {
      let subscription = DownloadDataTaskSubscription(subscriber: subscriber, session: session, request: request)
      subscriber.receive(subscription: subscription)
    }
  }
  
  final class DownloadDataTaskSubscription<S: Subscriber>: Subscription where
  S.Input == (data: Data?, progress: Progress, response: URLResponse),
  S.Failure == URLError {
    private var observation: NSKeyValueObservation?
    private var subscriber: S
    private weak var session: URLSession?
    private var request: URLRequest
    private var task: URLSessionDownloadTask?
    
    init(subscriber: S, session: URLSession, request: URLRequest) {
      self.request = request
      self.session = session
      self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
      guard demand > Subscribers.Demand.none else { return }
      
      task = session?.downloadTask(with: request) { [weak self] url, response, error in
        guard let subscriber = self?.subscriber,
              let task = self?.task
        else { return }
        if let error = error as? URLError {
          subscriber.receive(completion: .failure(error))
          return
        }
        guard let response = response else {
          subscriber.receive(completion: .failure(URLError(.badServerResponse)))
          return
        }
        guard let url = url else {
          subscriber.receive(completion: .failure(URLError(.badURL)))
          return
        }
        guard let data = try? Data(contentsOf: url), !data.isEmpty else {
          subscriber.receive(completion: .failure(URLError(.dataNotValid)))
          return
        }
        _ = subscriber.receive((data: data, progress: task.progress, response: response))
        subscriber.receive(completion: .finished)
      }
      observation = observeProgress()
      task?.resume()
    }
    
    func cancel() {
      task?.cancel()
    }
    
    deinit {
      observation?.invalidate()
    }
    
    private func observeProgress() -> NSKeyValueObservation? {
      task?.progress.observe(\.fractionCompleted) { [subscriber, task] progress, _ in
        guard let response = task?.response,
              let statusCode = (response as? HTTPURLResponse)?.statusCode,
              ((200..<300) ~= statusCode)
        else {
          return
        }
        _ = subscriber.receive((data: nil, progress: progress, response: response))
      }
    }
  }
}

extension URLError.Code {
  public static var dataNotValid = URLError.Code (rawValue: -20001)
}
