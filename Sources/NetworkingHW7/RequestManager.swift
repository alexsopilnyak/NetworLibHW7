//
//  File.swift
//  
//
//  Created by Alexandr Sopilnyak on 10.03.2021.
//

import Foundation

public protocol Reqeustable {
  func buildRequest<ResourceType: Resource>(with resourse: ResourceType, and defaultHeader: [String: String]) throws -> URLRequest
}

public final class RequestManager: Reqeustable {
  
  let parameterEncoder: ParameterEncoder
  
  public init(parameterEncoder: ParameterEncoder) {
    self.parameterEncoder = parameterEncoder
  }
  
  public convenience init() {
    self.init(parameterEncoder: DefaultParameterEncoder())
  }
  
  public func buildRequest<ResourceType: Resource>(with resourse: ResourceType, and defaultHeader: [String: String]) throws -> URLRequest {
    guard let url = URL(string: resourse.baseURL) else {
      throw NetworkError.missingURL
    }
    
    let parameters = resourse.requestBody
    
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
    request.httpMethod = resourse.httpMethod.rawValue
    addHeaders(defaultHeader, &request)
    
    do {
      try parameterEncoder.encode(request: &request, with: parameters)
    }
    catch {
      throw NetworkError.encodingError
    }
    
    if !resourse.headerParameters.isEmpty {
      let headers = resourse.headerParameters
      addHeaders(headers, &request)
    }
    
    return request
  }
}

private extension Reqeustable {
  func addHeaders(_ additionalHeaders: [String: String], _ request: inout URLRequest) {
    
    additionalHeaders.forEach{
      request.addValue($1, forHTTPHeaderField: $0)
    }
  }
}


