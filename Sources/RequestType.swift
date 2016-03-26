//
//  RequestType.swift
//  Restofire
//
//  Created by Rahul Katariya on 24/03/16.
//  Copyright © 2016 AarKay. All rights reserved.
//

import Alamofire

public protocol RequestType {

    associatedtype Model
    var path: String { get set }
    
    //Optionals
    var baseURL: String { get }
    var method: Alamofire.Method { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var headers: [String : String]? { get }
    var parameters: AnyObject? { get set }
    var rootKey: String? { get }
    var logging: Bool { get }
    
}

public extension RequestType {
    
    public var baseURL: String {
        get { return Configuration.defaultConfiguration.baseURL }
    }
    
    public var method: Alamofire.Method {
        get { return Configuration.defaultConfiguration.method }
    }
    
    public var encoding: Alamofire.ParameterEncoding {
        get { return Configuration.defaultConfiguration.encoding }
    }
    
    public var headers: [String: String]? {
        get { return Configuration.defaultConfiguration.headers }
    }
    
    public var parameters: AnyObject? {
        get { return nil }
        set {}
    }
    
    public var rootKey: String? {
        get { return Configuration.defaultConfiguration.rootKey }
    }
    
    public var logging: Bool {
        get { return Configuration.defaultConfiguration.logging }
    }
    
    public func executeRequest(completionHandler: Result<Model, NSError> -> Void) {
        let request = alamofireRequest()
        request.responseJSON(rootKey: rootKey) { (response: Response<Model, NSError>) -> Void in
            completionHandler(response.result)
            if self.logging {
                print(response.request.debugDescription)
                print(response.timeline)
                print(response.response)
                if response.result.isSuccess {
                    print(response.result.value!)
                } else {
                    print(response.result.error!)
                }
            }
        }
    }
    
}

extension RequestType {
    
    public func alamofireRequest() -> Alamofire.Request {
        var request: Alamofire.Request!
        
        request = Alamofire.request(method, baseURL + path, parameters: parameters as? [String: AnyObject], encoding: encoding, headers: headers)
        
        if let parameters = parameters as? [AnyObject] where method != .GET {
            let encodedURLRequest = encodeURLRequest(request.request!, parameters: parameters).0
            request = Alamofire.request(encodedURLRequest)
        }
        
        return request
    }
    
    private func encodeURLRequest(URLRequest: URLRequestConvertible, parameters: [AnyObject]?) -> (NSMutableURLRequest, NSError?) {
        let mutableURLRequest = URLRequest.URLRequest
        
        guard let parameters = parameters where !parameters.isEmpty else {
            return (mutableURLRequest, nil)
        }
        
        var encodingError: NSError? = nil
        
        switch encoding {
        case .JSON:
            do {
                let options = NSJSONWritingOptions()
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: options)
                
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            } catch {
                encodingError = error as NSError
            }
        case .PropertyList(let format, let options):
            do {
                let data = try NSPropertyListSerialization.dataWithPropertyList(
                    parameters,
                    format: format,
                    options: options
                )
                mutableURLRequest.setValue("application/x-plist", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            } catch {
                encodingError = error as NSError
            }
        default:
            break
        }
        
        return (mutableURLRequest, encodingError)
    }
    
}
