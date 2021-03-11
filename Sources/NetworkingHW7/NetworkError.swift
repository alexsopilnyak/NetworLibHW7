//
//  File.swift
//  
//
//  Created by Alexandr Sopilnyak on 11.03.2021.
//

import Foundation

public enum NetworkError: Error {
  case someError
  case missingURL
  case encodingError
  case invalidHeaders
  case badRequest
  case emptyData
  case decodingError
}
