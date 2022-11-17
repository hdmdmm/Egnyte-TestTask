//
//  MockURLProtocol.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 14.10.22.
//

import Foundation
import XCTest

protocol MockURLResponder {
  static func respond(to request: URLRequest) throws -> (data: Data?, response: URLResponse?)
  static func decoupled(data: Data, to nextChunk: (_ chunk: Data) -> Void )
}

class MockedURLProtocol<Responder: MockURLResponder>: URLProtocol {

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func stopLoading() {}

  override func startLoading() {
    guard let client = client else {
      XCTFail("The URLProtocolClient was not initialized!")
      return
    }

    // Simulates response on a background thread
    DispatchQueue.global(qos: .default).async {
      do {
        let responder = try Responder.respond(to: self.request)
        if let response = responder.response {
          client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = responder.data {
          Responder.decoupled(data: data) {
            client.urlProtocol(self, didLoad: $0)
          }
        }

        client.urlProtocolDidFinishLoading(self)
      }
      catch {
        client.urlProtocol(self, didFailWithError: error)
      }
    }
  }
}
