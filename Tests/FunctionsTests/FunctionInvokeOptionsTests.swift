import XCTest

@testable import Functions

final class FunctionInvokeOptionsTests: XCTestCase {
  func testStringBody() {
    let options = FunctionInvokeOptions(body: "string value")
    XCTAssertEqual(options.headers["Content-Type"], "text/plain")
    XCTAssertNotNil(options.body)
  }

  func testDataBody() {
    let options = FunctionInvokeOptions(body: "binary value".data(using: .utf8)!)
    XCTAssertEqual(options.headers["Content-Type"], "application/octet-stream")
    XCTAssertNotNil(options.body)
  }

  func testEncodableBody() {
    struct Body: Encodable {
      let value: String
    }
    let options = FunctionInvokeOptions(body: Body(value: "value"))
    XCTAssertEqual(options.headers["Content-Type"], "application/json")
    XCTAssertNotNil(options.body)
  }

  func testMultipartFormDataBody() {
    let boundary = "Boundary-\(UUID().uuidString)"
    let contentType = "multipart/form-data; boundary=\(boundary)"
    let options = FunctionInvokeOptions(
      headers: ["Content-Type": contentType],
      body: "binary value".data(using: .utf8)!
    )
    XCTAssertEqual(options.headers["Content-Type"], contentType)
    XCTAssertNotNil(options.body)
  }
}
