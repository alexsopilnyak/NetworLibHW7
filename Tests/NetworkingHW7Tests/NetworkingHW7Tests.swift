import XCTest
@testable import NetworkingHW7

final class NetworkingHW7Tests: XCTestCase {
  
  func test_requestBuilding() {
    let mockResource = BaseResource<PostMockModel>(baseURL: "https://jsonplaceholder.typicode.com/comments", httpMethod: .get, requestBody: ["postId": 1], headerParameters: [:])
    let requestManager = RequestManager()
    
    let request = try? requestManager.buildRequest(with: mockResource, and: .headers)
    
    XCTAssertNotNil(request)
    
    guard let unwrappedRequest = request else {
      XCTFail("Bad request")
      return
    }
  
    XCTAssertNotNil(unwrappedRequest.url?.absoluteString)
    XCTAssertEqual(unwrappedRequest.url?.absoluteString, "https://jsonplaceholder.typicode.com/comments?postId=1")
    XCTAssertEqual(unwrappedRequest.allHTTPHeaderFields?["Accept"], "application/json")
    XCTAssertEqual(unwrappedRequest.allHTTPHeaderFields?.count, 2)
    
  }
  

  func test_parsingModelFromWeb(){
    
    let mockResource = BaseResource<PostMockModel>(baseURL: "https://jsonplaceholder.typicode.com/posts/1", httpMethod: .get)
    
    ASNetworking().request(with: mockResource) { (response, error) in
      XCTAssertNil(error)
      XCTAssertEqual(response?.userId, 1)
      XCTAssertEqual(response?.id, 1)
      XCTAssertEqual(response?.title, "sunt aut facere repellat provident occaecati excepturi optio reprehenderit")
    }
    
  }
  
  func test_parsingModelInArrayFromWeb() {
    let mockResource = CustomResourse<[PostMockModel]>(baseURL: "https://jsonplaceholder.typicode.com/posts/", httpMethod: .get, requestBody: [:], headerParameters: .headers)
    
    ASNetworking().request(with: mockResource) { (response, error) in
      XCTAssertNil(error)
      XCTAssertEqual(response?.count, 100)
      XCTAssertEqual(response?.first?.id, 1)
      XCTAssertEqual(response?.last?.id, 100)
      XCTAssertEqual(response?.last?.userId, 10)
    }
  }
  
  func test_postMethod() {
    let mockResource = BaseResource<PostResponse>(baseURL: "https://jsonplaceholder.typicode.com/posts/", httpMethod: .post, requestBody: ["id": 101,
                                                                                                                          "title": "foo",
                                                                                                                          "body": "bar",
                                                                                                                          "userId": 1], headerParameters: [:])
    ASNetworking().request(with: mockResource) { (response, error) in
      XCTAssertNil(error)
      XCTAssertEqual(response?.id, 101)
      
    }
  }
  
  func test_networkingError() {
    let mockResource = BaseResource<[PostMockModel]>(baseURL: "https://jsonplaceholder.typicode.com/postsAAAAAAAAAA/", httpMethod: .get)
    
    ASNetworking().request(with: mockResource) { (response, error) in
      
      XCTAssertThrowsError(error)
    }
  }
  
  private struct CustomResourse<ResponseType: Codable>: Resource {
    typealias Response = ResponseType
    
    var baseURL: String
    var httpMethod: HTTPMethod
    var requestBody: [String: Any]
    var headerParameters: [String: String]
  }
  
  private struct PostMockModel: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
  }
  
  private struct PostResponse: Codable {
    var id: Int
  }
  
}




