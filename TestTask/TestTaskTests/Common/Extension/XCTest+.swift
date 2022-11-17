//
//  XCTest+.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 15.10.22.
//

import XCTest
import Combine

extension XCTestCase {
  func awaitPublisher<T: Publisher>(
    _ publisher: T,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> T.Output {
    var result: Result<T.Output, Error>?
    let expectation = self.expectation(description: "Waiting for result")
    let cancelable = publisher.sink(
      
      receiveCompletion: {
        switch $0 {
        case .failure(let error):
          result = .failure(error)
        case .finished:
          break
        }
        expectation.fulfill()
      },
      receiveValue: {
        result = .success($0)
      }

    )
    waitForExpectations(timeout: timeout)
    cancelable.cancel()
    
    return try XCTUnwrap(result, "Awaited Publisher did not produce any output", file: file, line: line).get()
  }
}
