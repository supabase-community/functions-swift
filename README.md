# `functions-swift`

> [!WARNING]  
> This repository is deprecated and it was moved to the [monorepo](https://github.com/supabase-community/supabase-swift).
> Repository will remain live to support old versions of the library, but any new updates **MUST** be done on the monorepo.

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
