import Foundation

public enum FunctionsError: Error, LocalizedError {
  case relayError
  case httpError(code: Int, data: Data)

  public var errorDescription: String? {
    switch self {
    case .relayError: return "Relay Error invoking the Edge Function"
    case let .httpError(code, _): return "Edge Function returned a non-2xx status code: \(code)"
    }
  }
}

public struct FunctionInvokeOptions {
  let method: Method?
  let headers: [String: String]
  let body: Data?

  public init(method: Method? = nil, headers: [String: String] = [:], body: some Encodable) {
    var defaultHeaders = [String: String]()

    switch body {
    case let string as String:
      defaultHeaders["Content-Type"] = "text/plain"
      self.body = string.data(using: .utf8)
    case let data as Data:
      defaultHeaders["Content-Type"] = "application/octet-stream"
      self.body = data
    default:
      // default, assume this is JSON
      defaultHeaders["Content-Type"] = "application/json"
      self.body = try? JSONEncoder().encode(body)
    }

    self.method = method
    self.headers = defaultHeaders.merging(headers) { _, new in new }
  }

  public init(method: Method? = nil, headers: [String: String] = [:]) {
    self.method = method
    self.headers = headers
    body = nil
  }

  public enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
  }
}
