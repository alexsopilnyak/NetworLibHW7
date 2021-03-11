
import Foundation

public protocol NetworkingService {
  func request<ResourceType: Resource>(with resource: ResourceType, completion: @escaping (ResourceType.Response?, Error?) -> ())
}


public final class ASNetworking: NetworkingService {
  
  private let requestManager: Reqeustable
  private var sessionManager: URLSession
  private let defaultHeader: [String: String]
  
  public init(requestManager: Reqeustable, sessionManager: URLSession, defaultHeader: [String: String]) {
    self.requestManager = requestManager
    self.sessionManager = sessionManager
    self.defaultHeader = defaultHeader
  }
  
  public convenience init () {
    self.init(requestManager: RequestManager(),
              sessionManager: .shared,
              defaultHeader: .headers )
  }
  
  public func request<ResourceType: Resource>(with resource: ResourceType, completion: @escaping (ResourceType.Response?, Error?) -> ()) {
    
    guard let request = try? requestManager.buildRequest(with: resource, and: defaultHeader) else {
      completion(nil, NetworkError.badRequest)
      return
    }
    
    sessionManager.dataTask(with: request) {[weak self] data, response, error in
      
      if let error = error {
        DispatchQueue.main.async {
          completion(nil, error)
        }
      }
      
      guard let response = response as? HTTPURLResponse else {
        return
      }
      
      let result = self?.handle(response, data: data)
      
      switch result {
      
      case .success(let data):
        do {
          let decodedData = try JSONDecoder().decode(ResourceType.Response.self, from: data)
          DispatchQueue.main.async {
            completion(decodedData, nil)
          }
        } catch {
          DispatchQueue.main.async {
            completion(nil, NetworkError.decodingError)
          }
        }
        
      case .failure(let error):
        DispatchQueue.main.async {
          completion(nil, error)
        }
        
      case .none:
        DispatchQueue.main.async {
          completion(nil, NetworkError.badRequest)
        }
      }
      
    }.resume()
  }
}

fileprivate extension ASNetworking {
  func handle(_ response: HTTPURLResponse, data: Data?) -> Result<Data, NetworkError>{
    
    switch response.statusCode {
    case 200...299:
      guard let data = data else {
        return .failure(.emptyData)
      }
      return .success(data)
    default: return .failure(.someError)
    }
  }
}

public extension Dictionary where Key == String, Value == String {
  static var headers: [String: String] {
    return ["Accept": "application/json",
            "Content-type": "application/json"]
  }
}
