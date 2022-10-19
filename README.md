# `functions-swift`

Swift Client library to interact with Supabase Functions.

## Usage

```swift
let client = FunctionsClient(
  url: URL(string: "https://project-id.supabase.com/functions/v1")!,
  headers: [
    "apikey": "project-api-key"
  ]
)

struct Response: Decodable {
  let message: String
}

let response: Response = try await client.invoke(
  functionName: "hello-world",
  invokeOptions: FunctionInvokeOptions(body: ["name": "Functions"])
)

assert(response.message = "Hello Functions")
```
