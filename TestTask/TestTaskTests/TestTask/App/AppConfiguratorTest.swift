//
//  AppConfigurator.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 16.10.22.
//

import XCTest
@testable import TestTask

class AppConfiguratorTest: XCTestCase {
  func testConfigurator_Failed_FileNotFound() throws {
    do {
      _ = try AppConfigurator(fileName: "some.test.file")
    }
    catch {
      XCTAssertEqual(error as? ConfiguratorErrors, .configFileNotFound)
      return
    }
    XCTFail("Expected error: Config file was not found ")
  }

  func testConfigurator_Failed_DataMismatch() throws {
    do {
      _ = try MockConfigurator(fileName: "AppConfigurator")
    }
    catch {
      XCTAssertEqual(error as? ConfiguratorErrors, .configDataMismatch)
      return
    }
  }

  func testConfigurator_Success() throws {
    let config = try AppConfigurator(fileName: "AppConfigurator")
    XCTAssertEqual(config.model.host, "https://source.unsplash.com")
    XCTAssertEqual(config.model.service, "/random")
  }
}

struct TestModel: Decodable {
  let nonDecodeableMember: String
}

struct MockConfigurator: ConfiguratorProtocol {
  let model: TestModel
  init(fileName: String) throws {
    model = try Self.load(fileName)
  }
}
