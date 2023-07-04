import Foundation

public final class FunctionsClient {
  public typealias FetchHandler = (URLRequest) async throws -> (Data, URLResponse)

  let url: URL
  var headers: [String: String]

  private let fetch: FetchHandler

  public init(
    url: URL,
    headers: [String: String] = [:],
    fetch: @escaping FetchHandler = URLSession.shared.data(for:)
  ) {
    self.url = url
    self.headers = headers
    self.headers["X-Client-Info"] = "functions-swift/\(version)"
    self.fetch = fetch
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
    let url = self.url.appendingPathComponent(functionName)

    var urlRequest = URLRequest(url: url)
    urlRequest.allHTTPHeaderFields = invokeOptions.headers.merging(headers) { first, _ in first }
    urlRequest.httpMethod = invokeOptions.method?.rawValue ?? "POST
    urlRequest.httpBody = invokeOptions.body

    let (data, response) = try await fetch(urlRequest)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard 200..<300 ~= httpResponse.statusCode else {
      throw FunctionsError.httpError(code: httpResponse.statusCode, data: data)
    }

    let isRelayError = httpResponse.value(forHTTPHeaderField: "x-relay-error") == "true"
    if isRelayError {
      throw FunctionsError.relayError
    }

    return (data, httpResponse)
  }
}
