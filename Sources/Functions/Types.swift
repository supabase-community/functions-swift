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
  let headers: [String: String]
  let body: Data?

  public init(headers: [String: String] = [:], body: some Encodable) {
    var headers = headers

    switch body {
    case let string as String:
      headers["Content-Type"] = "text/plain"
      self.body = string.data(using: .utf8)
    case let data as Data:
      headers["Content-Type"] = "application/octet-stream"
      self.body = data
    default:
      // default, assume this is JSON
      headers["Content-Type"] = "application/json"
      self.body = try? JSONEncoder().encode(body)
    }

    self.headers = headers
  }

  public init(headers: [String: String] = [:]) {
    self.headers = headers
    body = nil
  }
}
