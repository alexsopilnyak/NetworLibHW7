//
//  File.swift
//  
//
//  Created by Alexandr Sopilnyak on 10.03.2021.
//
import Foundation



public protocol ParameterEncoder {
   func encode(request: inout URLRequest, with parameters: [String: Any]) throws
}

public final class DefaultParameterEncoder: ParameterEncoder {
  
  public func encode(request: inout URLRequest, with parameters: [String: Any]) throws {
    
    guard let url = request.url else {
      throw NetworkError.missingURL
    }
    
    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
      urlComponents.queryItems = [URLQueryItem]()
      
      parameters.forEach{
        let queryItem = URLQueryItem(name: $0, value: "\($1)".removingPercentEncoding)
        urlComponents.queryItems?.append(queryItem)
      }
      
      request.url = urlComponents.url
      
    }
  }
}


