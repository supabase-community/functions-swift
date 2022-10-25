import Foundation

public final class FunctionsClient {
  let url: URL
  var headers: [String: String]
  let http: FunctionsHTTPClient

  public init(
    url: URL,
    headers: [String: String] = [:],
    http: FunctionsHTTPClient? = nil
  ) {
    self.url = url
    self.headers = headers
    self.http = http ?? DefaultFunctionsHTTPClient()

    self.headers["X-Client-Info"] = "functions-swift/\(version)"
  }

  /// Updates the authorization header.
  /// - Parameter token: the new JWT token sent in the authorization header
  public func setAuth(token: String) {
    headers["Authorization"] = "Bearer \(token)"
  }

  /// Invokes a function.
  /// - Parameters:
  ///   - functionName: the name of the function to invoke.
  public func invoke<Response>(
    functionName: String,
    invokeOptions: FunctionInvokeOptions = .init(),
    decode: (Data, HTTPURLResponse) throws -> Response
  ) async throws -> Response {
    let (data, response) = try await rawInvoke(
      functionName: functionName,
      invokeOptions: invokeOptions
    )
    return try decode(data, response)
  }

  /// Invokes a function.
  /// - Parameters:
  ///   - functionName: the name of the function to invoke.
  public func invoke<T: Decodable>(
    functionName: String,
    invokeOptions: FunctionInvokeOptions = .init(),
    decoder: JSONDecoder = JSONDecoder()
  ) async throws -> T {
    try await invoke(
      functionName: functionName,
      invokeOptions: invokeOptions,
      decode: { data, _ in try decoder.decode(T.self, from: data) }
    )
  }

  /// Invokes a function.
  /// - Parameters:
  ///   - functionName: the name of the function to invoke.
  public func invoke(
    functionName: String,
    invokeOptions: FunctionInvokeOptions = .init()
  ) async throws {
    try await invoke(
      functionName: functionName,
      invokeOptions: invokeOptions,
      decode: { _, _ in () }
    )
  }

  private func rawInvoke(
    functionName: String,
    invokeOptions: FunctionInvokeOptions
  ) async throws -> (Data, HTTPURLResponse) {
    let body = invokeOptions.body
    let invokeHeaders = invokeOptions.headers

    var request = URLRequest(url: url.appendingPathComponent(functionName))
    request.httpMethod = "POST"
    request.httpBody = body
    request.allHTTPHeaderFields = invokeHeaders.merging(headers) { invokeHeader, _ in invokeHeader }

    let (data, response) = try await http.execute(request, client: self)
    guard 200 ..< 300 ~= response.statusCode else {
      throw FunctionsError.httpError(code: response.statusCode, data: data)
    }

    let isRelayError = response.value(forHTTPHeaderField: "x-relay-error") == "true"
    if isRelayError {
      throw FunctionsError.relayError
    }

    return (data, response)
  }
}
