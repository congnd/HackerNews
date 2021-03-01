import Foundation
import Api

struct TargetStub: Target {
  struct Response: Decodable {
    let userName: String
    let date: Date
  }
  typealias DataType = Response

  let id = UUID()
  let scheme: String
  let host: String
  let path: String
  let params: [String: String]
  let headers: [String: String]
  let authorization: String?
  let data: [String: String]
  let method: Api.Method

  init(
    path: String = "",
    params: [String: String] = [:],
    headers: [String: String] = [:],
    authorization: String? = nil,
    data: [String: String] = [:],
    method: Api.Method = .get
  ) {
    self.scheme = "https"
    self.host = "example.com"
    self.path = path
    self.params = params
    self.headers = headers
    self.authorization = authorization
    self.data = data
    self.method = method
  }
}
