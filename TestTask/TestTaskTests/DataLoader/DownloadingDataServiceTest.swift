//
//  DownloadingDataServiceTest.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 18.10.22.
//

import XCTest
import Combine

@testable import TestTask


class DownloadingDataServiceTest: XCTestCase {
  let expectedData = Data(repeating: 0, count: 200)
  let expectedProgress = Progress(totalUnitCount: 200)
  var mockNetworkService: MockNetworkService?
  
  let mockRequest = MockRequest(url: URL(string: "http://some.host.com/")!)
  
  var targetService: DownloadingDataServiceProtocol?

  
  override func setUpWithError() throws {
    let mockNetworkService = MockNetworkService(data: expectedData, progress: expectedProgress)
    targetService = DownloadingDataService(networkService: mockNetworkService)
    self.mockNetworkService = mockNetworkService
  }

  func testDownloadData_success() throws {
    expectedProgress.completedUnitCount = 100
    let publisher = try XCTUnwrap(targetService?.downloadData(by: mockRequest),
                                  "Couldn't unwrap the DownloadingDataService reference")
    let result = try awaitPublisher(publisher)

    XCTAssertEqual(result.data, expectedData)
    XCTAssertEqual(result.progress.fractionCompleted, 0.5)
  }

  func testDownloadData_failed() throws {
    mockNetworkService?.mockError = MockError.testError
    let publisher = try XCTUnwrap(targetService?.downloadData(by: mockRequest),
                                  "Couldn't unwrap the DownloadingDataService reference")
    do {
      _ = try awaitPublisher(publisher)
    }
    catch {
      XCTAssertEqual(error as? MockError, .testError)
      return
    }
    XCTFail("Expected error as result")
  }
}

class MockNetworkService: NetworkServiceProtocol {
  var mockData: Data?
  var mockProgress: Progress
  var mockError: Error?
  
  init(data: Data? = nil, progress: Progress = Progress(), error: Error? = nil) {
    self.mockError = error
    self.mockData = data
    self.mockProgress = progress
  }
  
  func request(endpoint: Request) -> AnyPublisher<(data: Data?, progress: Progress), Error> {
    guard let error = mockError else {
      return Just((data: mockData, progress: mockProgress))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    return Fail(error: error).eraseToAnyPublisher()
  }
}
