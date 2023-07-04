import XCTest

@testable import Functions

final class FunctionsClientTests: XCTestCase {
  let url = URL(string: "http://localhost:5432/functions/v1")!
  let apiKey = "supabase.anon.key"

  func testInvoke() async throws {
    var _request: URLRequest?
    let sut = FunctionsClient(url: url, headers: ["apikey": apiKey]) {
      _request = $0
      return (Data(), HTTPURLResponse.mock(url: self.url))
    }

    let body = ["name": "Supabase"]

    try await sut.invoke(
      functionName: "hello_world",
      invokeOptions: .init(headers: ["X-Custom-Key": "value"], body: body)
    )

    let request = try XCTUnwrap(_request)

    XCTAssertEqual(request.url, URL(string: "http://localhost:5432/functions/v1/hello_world"))
    XCTAssertEqual(request.httpMethod, "POST")
    XCTAssertEqual(request.value(forHTTPHeaderField: "apikey"), apiKey)
    XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom-Key"), "value")
    XCTAssertEqual(
      request.value(forHTTPHeaderField: "X-Client-Info"), "functions-swift/\(Functions.version)")
  }

  func testInvoke_shouldThrow_URLError_badServerResponse() async {
    let sut = FunctionsClient(url: url) { _ in
      (Data(), URLResponse())
    }

    do {
      try await sut.invoke(functionName: "hello_world")
    } catch let urlError as URLError {
      XCTAssertEqual(urlError.code, .badServerResponse)
    } catch {
      XCTFail("Unexpected error thrown \(error)")
    }
  }

  func testInvoke_shouldThrow_FunctionsError_httpError() async {
    let sut = FunctionsClient(url: url) { _ in
      (
        "error".data(using: .utf8)!,
        HTTPURLResponse.mock(url: self.url, statusCode: 300)
      )
    }

    do {
      try await sut.invoke(functionName: "hello_world")
      XCTFail("Invoke should fail.")
    } catch let FunctionsError.httpError(code, data) {
      XCTAssertEqual(code, 300)
      XCTAssertEqual(data, "error".data(using: .utf8))
    } catch {
      XCTFail("Unexpected error thrown \(error)")
    }
  }

  func testInvoke_shouldThrow_FunctionsError_relayError() async {
    let sut = FunctionsClient(url: url) { _ in
      (
        Data(),
        HTTPURLResponse.mock(url: self.url, headerFields: ["x-relay-error": "true"])
      )
    }

    do {
      try await sut.invoke(functionName: "hello_world")
      XCTFail("Invoke should fail.")
    } catch FunctionsError.relayError {
    } catch {
      XCTFail("Unexpected error thrown \(error)")
    }
  }
}

extension HTTPURLResponse {
  static func mock(
    url: URL,
    statusCode: Int = 200,
    headerFields: [String: String]? = nil
  ) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)!
  }
}
