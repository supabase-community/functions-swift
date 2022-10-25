import Foundation

public protocol FunctionsHTTPClient {
  func execute(
    _ request: URLRequest,
    client: FunctionsClient
  ) async throws -> (Data, HTTPURLResponse)
}

public struct DefaultFunctionsHTTPClient: FunctionsHTTPClient {
  public init() {}

  public func execute(
    _ request: URLRequest,
    client _: FunctionsClient
  ) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    return (data, httpResponse)
  }
}
