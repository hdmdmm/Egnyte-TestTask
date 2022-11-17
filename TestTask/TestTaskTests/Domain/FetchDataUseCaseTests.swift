//
//  FetchDataUseCaseTests.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 18.10.22.
//

import XCTest
import Combine
@testable import TestTask

class FetchDataUseCaseTests: XCTestCase {
  private let data = Data(repeating: 0, count: 200)
  private let progress = Progress(totalUnitCount: 200)
  private let configurator = MockSourcePathConfigurator()
  
  private var downloadingDataService: MockDownloadingDataService?
  
  private var testableFetchDataUserCase: FetchDataUseCaseProtocol?

  
  override func setUpWithError() throws {
    let downloadingDataService = MockDownloadingDataService(data: data, progress: progress)
    testableFetchDataUserCase = FetchDataUseCase(dataLoader: downloadingDataService, configurator: configurator)
    self.downloadingDataService = downloadingDataService
  }
  
  override func tearDownWithError() throws {

  }
  
  func testFetchDataUseCase_Fail_EmptyResourceName() throws {
    let useCase = try XCTUnwrap(testableFetchDataUserCase,
                            "Couldn't unwrap reference to the instance of FetchDataUserCase")

    let publisher = useCase.fetchData(by: "")
    
    do {
      _ = try awaitPublisher(publisher)
    }
    catch {
      XCTAssertEqual(error as? UseCasesErrors, .wrongResourceName)
      return
    }
    XCTFail("Expected error as result")
  }

  func testFetchDataUseCase_Fail() throws {
    downloadingDataService?.mockError = MockError.testError
    let useCase = try XCTUnwrap(testableFetchDataUserCase,
                            "Couldn't unwrap reference to the instance of FetchDataUserCase")

    let publisher = useCase.fetchData(by: "ResourceNameTest")
    
    do {
      _ = try awaitPublisher(publisher)
    }
    catch {
      XCTAssertEqual(error as? MockError, .testError)
      return
    }
    XCTFail("Expected error as result")
  }

  func testFetchDataUseCase_Success() throws {
    let useCase = try XCTUnwrap(testableFetchDataUserCase,
                            "Couldn't unwrap reference to the instance of FetchDataUserCase")

    let publisher = useCase.fetchData(by: "ResourceNameTest")
    let result = try awaitPublisher(publisher)

    XCTAssertEqual(result.data, data)
    XCTAssertEqual(result.progress, progress)
  }
}

struct MockSourcePathConfigurator: SourcePathConfiguratorProtocol {
  
  func urlDataSource(path: String) -> URL? {
    URL(string: path)
  }
}

class MockDownloadingDataService: DownloadingDataServiceProtocol {
  var mockData: Data?
  var mockProgress: Progress
  var mockError: Error?
  
  init(data: Data? = nil, progress: Progress = Progress(), error: Error? = nil) {
    self.mockError = error
    self.mockData = data
    self.mockProgress = progress
  }

  func downloadData(by request: Request) -> AnyPublisher<(data: Data?, progress: Progress), Error> {
    guard let error = mockError else {
      return Just((data: mockData, progress: mockProgress))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    return Fail(error: error).eraseToAnyPublisher()
  }
}
