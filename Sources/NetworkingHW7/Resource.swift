//
//  File.swift
//  
//
//  Created by Alexandr Sopilnyak on 10.03.2021.
//

import Foundation


public protocol Resource {
  
  associatedtype Response: Codable
  
  var baseURL: String { get }
  var httpMethod: HTTPMethod { get }
  var requestBody: [String: Any] { get }
  var headerParameters: [String: String] { get }
}

public struct BaseResource<ResponseType: Codable>: Resource {
  
  public typealias Response = ResponseType

  public var baseURL: String
  public var httpMethod: HTTPMethod
  public var requestBody: [String : Any]
  public var headerParameters: [String : String]
  
  public init(baseURL: String,
              httpMethod: HTTPMethod,
              requestBody: [String: Any] = [:],
              headerParameters: [String: String] = [:]) {
    
    self.baseURL = baseURL
    self.httpMethod = httpMethod
    self.requestBody = requestBody
    self.headerParameters = headerParameters
    
  }
}

