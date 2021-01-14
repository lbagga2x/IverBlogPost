//
//  SettingModel.swift
//  Drug Shortages Canada
//
//  Created by Wes Goodhoofd on 2016-10-25.
//  Copyright © 2016 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

private let _sharedModel = SettingModel()

// rename the prefix depending on the project
let settingKeyPrefix = "BaseProject"
let userObjectKey = settingKeyPrefix+"UserKey"
let deviceObjectKey = settingKeyPrefix+"DeviceKey"
let userTokenObjectKey = settingKeyPrefix+"UserTokenObjectKey"
let deviceTokenKey = settingKeyPrefix+"DeviceTokenKey"

public enum Server {
    case local
    case development
    case stage
    case production
}

class SettingModel: NSObject {
    // API handling
    let devBaseUrl = "http://cms.iversoft.ca/api"
    let prodBaseUrl = "http://cms.iversoft.ca/api"
    
    // saved settings
    var user:User?
    var device:Device?
    var userToken:AuthToken?
    var deviceToken:String?
    
    // Network Reachability
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    var isNetworkReachable: Bool = false
    
    override init() {
        super.init()
        listenForReachability()
        registerSettings()
        loadSettings()
    }
    
    class func sharedModel() -> SettingModel {
        return _sharedModel
    }
    
    // remove the human aspect of setting the server and connect it to the scheme configuration
    func isDebug() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    func isRelease() -> Bool {
        if !isDebug() {
            return true
        } else {
            return false
        }
    }
    
    func baseUrl() -> String {
        if isRelease() {
            return prodBaseUrl
        } else {
            return devBaseUrl
        }
    }
    
    func pushIsProduction() -> Int {
        if isRelease() {
            return 1
        } else {
            return 0
        }
    }
    
    func apiKey() -> String {
        if isRelease() {
            return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhcHBfa2V5IjoiYmFzZTY0OlZvb2g1ZzdSNXBOQ29JT2VcL0J1N3JESVpSOEZiZVdpOHJaeU1LckFlV3d3PSIsImlzcyI6Imh0dHA6XC9cL2xvY2FsaG9zdCIsImlhdCI6MTQ4NzY4ODE4OSwiZXhwIjoxNDg3NzE2OTg5LCJuYmYiOjE0ODc2ODgxODksImp0aSI6IjBlYjgxMTkzNTk1Njk1YTFjZjkwNzUwMjMzNDc3ZTNlIn0.v0OW9CJt8Rq-vBMfIeCPVHSTUUlVsvIqZKN06MSmpK4"
        } else {
            //Using release API Key 
            return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhcHBfa2V5IjoiYmFzZTY0OlZvb2g1ZzdSNXBOQ29JT2VcL0J1N3JESVpSOEZiZVdpOHJaeU1LckFlV3d3PSIsImlzcyI6Imh0dHA6XC9cL2xvY2FsaG9zdCIsImlhdCI6MTQ4NzY4ODE4OSwiZXhwIjoxNDg3NzE2OTg5LCJuYmYiOjE0ODc2ODgxODksImp0aSI6IjBlYjgxMTkzNTk1Njk1YTFjZjkwNzUwMjMzNDc3ZTNlIn0.v0OW9CJt8Rq-vBMfIeCPVHSTUUlVsvIqZKN06MSmpK4"
        }
    }
    
    func accessPassword() -> String? {
        return nil
    }
    
    func registerSettings() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [:
            ]);
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        
        encodeObject(defaults, object: userToken, key: userTokenObjectKey)
        encodeObject(defaults, object:user, key:userObjectKey)
        encodeObject(defaults, object:device, key:deviceObjectKey)
        
        if deviceToken != nil {
            defaults.set(deviceToken!, forKey: deviceTokenKey)
        }
    }
    
    func defaultListParameters() -> [String : Any] {
        let data = ["offset" : 0, "limit" : Constants.resultLimit]
        return data
    }
    
    func encodeObject(_ defaults:UserDefaults, object:NSCoding?, key:String) {
        if let object = object {
            let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
            defaults.set(encodedObject, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        
        if let decodedUser = defaults.object(forKey: userObjectKey) as? Data {
            user = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as? User
        }
        
        if let decodedDevice = defaults.object(forKey: deviceObjectKey) as? Data {
            device = NSKeyedUnarchiver.unarchiveObject(with: decodedDevice) as? Device
        }
        
        if let decodedToken = defaults.object(forKey: userTokenObjectKey) as? Data {
            userToken = NSKeyedUnarchiver.unarchiveObject(with: decodedToken) as? AuthToken
        }
        
        if let storedDeviceToken = defaults.object(forKey: deviceTokenKey) as? String {
            deviceToken = storedDeviceToken
        }
    }
    
    func logUserIn(_ u: User) {
        user = u
        saveSettings()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogIn"), object: nil)
    }
    
    func logUserOut() {
        userToken = nil
        user = nil
        device = nil
        saveSettings()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogOut"), object: nil)
    }
    
    func isLoggedIn() -> Bool {
        return (user != nil && !tokenHasExpired())
    }
    
    func saveDeviceToken(_ token: String) {
        deviceToken = token
        saveSettings()
    }
    
    func setAuthTokenValues(token: String?, expiryDate: Date?) {
        if token != nil && expiryDate != nil {
            userToken = AuthToken(token: token!, expiryDate: expiryDate!)
            saveSettings()
        }
    }
    
    func saveDevice(_ d: Device) {
        device = d
        saveSettings()
    }
    
    func tokenHasExpired() -> Bool {
        if (userToken != nil) {
            return userToken!.hasExpired()
        }
        return true
    }

    // TODO - a refresh token method without password
//    func refreshToken() {
//        Alamofire.request(APIRouter.authenticate())
//            .validate(statusCode: 200..<300)
//            .responseObject { (response: DataResponse<User>) in
//                switch response.result {
//                case .success:
//                    self.saveUserTokenFromHeader(response.response!.allHeaderFields)
//                    print("successfully refreshed token")
//                    break
//                case .failure(let error):
//                    print("error refreshing token -- \(error.localizedDescription)")
//                }
//        }
//    }
    
    func registerDevice(_ token: String) {
        let parameters = deviceData(token)
        Alamofire.request(APIRouter.registerDevice(parameters: parameters))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<Device>) in
                switch response.result {
                case .success:
                    self.saveDevice(response.result.value!)
                    // save token if necessary
                    Constants.debugPrint("successfully registered device ID \(self.device!.deviceId!)")
                    break
                case .failure(let error):
                    if let errorMessage = Constants.findErrorInResponse(response.data) {
                        Constants.debugPrint("error registering device \(String(describing: response.response?.statusCode)) \(errorMessage)")
                    } else {
                        Constants.debugPrint("error registering device \(error.localizedDescription)")
                    }
                }
        }
    }
    
    func loadUserSettings() {
        if !isLoggedIn() {
            return
        }
        
        // refresh the user settings
        Alamofire.request(APIRouter.getProfile(userId: self.user!.userId!))
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<User>) in
                switch response.result {
                case .success:
                    self.logUserIn(response.result.value!)
                    Constants.debugPrint("successfully loading user profile \(self.user!.userId!)")
                    break
                case .failure(let error):
                    if let errorMessage = Constants.findErrorInResponse(response.data) {
                        Constants.debugPrint("error loading user profile \(String(describing: response.response?.statusCode)) \(errorMessage)")
                    } else {
                        Constants.debugPrint("error loading user profile \(error.localizedDescription)")
                    }
                }
        }
    }
    
    func deviceData(_ token: String) -> [String : Any] {
        // extra data useful for debugging
        let deviceName = UIDevice.current.localizedModel
        let osVersion = UIDevice.current.systemVersion
        let appVersion = version()
        
        let data:[String:Any] = ["platform" : "ios", "device_token" : token, "production" : pushIsProduction(), "device_name" : deviceName, "os_version" : osVersion, "app_version" : appVersion]
        return data
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    enum APIRouter : URLRequestConvertible {
        case authenticate(parameters: [String : Any])
        case registerDevice(parameters: [String : Any])
        case registerUser(parameters: [String : Any])
        case blogPosts(parameters: [String : Any])
        case createBlogPosts(parameters: [String : Any])
        case updateProfile(userId: Int, parameters: [String : Any])
        case uploadProfileProperties(userId: Int)
        case getProfile(userId: Int)
        case getBlogPost(blogPostId: Int)
        case logout(device: Device)
        case forgotPassword(email: String)
        // messaging
        case getInboxThreads(parameters: [String : Any])
        case getTrashedThreads(parameters: [String : Any])
        case createThread(parameters: [String : Any])
        case sendMessage(threadId: Int)
        case threadMessages(threadId: Int, parameters: [String : Any])
        case userList(parameters: [String : Any])
        case markThreadRead(threadId: Int)
        case markMessageRead(messageId: Int)
        case deleteThread(threadId: Int)
        case restoreThread(threadId: Int)
        case unreadThreads
        
        var method: HTTPMethod {
            switch self {
            case .authenticate(_), .registerDevice(_), .uploadProfileProperties(_), .updateProfile(_, _), .logout(_), .registerUser(_), .forgotPassword(_), .createThread(_), .sendMessage(_), .markThreadRead(_), .markMessageRead(_), .restoreThread(_), .createBlogPosts(_):
                return .post
            case .deleteThread(_):
                return .delete
            default:
                return .get
            }
        }
        
        var path: String {
            switch self {
            case .authenticate(_):
                return "/authenticate"
            case .registerDevice(_):
                return "/device/register"
            case .logout(_):
                return "/device/logout"
            case .blogPosts(_):
                return "/blog/list"
            case .getBlogPost(let blogPostId):
                return String(format: "/blog/single/%d", blogPostId)
            case .updateProfile(let userId, _), .uploadProfileProperties(let userId):
                return String(format: "/users/edit/%d", userId)
            case .getProfile(let userId):
                return String(format: "/users/single/%d", userId)
            case .registerUser(_):
                return "/users/new"
            case .forgotPassword(_):
                return "/users/resetpassword"
                // messaging
            case .getInboxThreads(_):
                return "/messaging/inbox"
            case .getTrashedThreads(_):
                return "/messaging/trashed"
            case .createThread(_):
                return "/messaging/message/new"
            case .sendMessage(let threadId):
                return String(format: "/messaging/message/reply/%d", threadId)
            case .threadMessages(let threadId, _):
                return String(format: "/messaging/thread/messages/%d", threadId)
            case .userList(_):
                return "/users/list"
            case .markThreadRead(let threadId):
                return String(format: "/messaging/read/thread/%d", threadId)
            case .markMessageRead(let messageId):
                return String(format: "/messaging/read/message/%d", messageId)
            case .deleteThread(let threadId):
                return String(format: "/messaging/delete/%d", threadId)
            case .restoreThread(let threadId):
                return String(format: "/messaging/restore/%d", threadId)
            case .unreadThreads:
                return "/messaging/unread"
            case .createBlogPosts(_):
                return "/blog/new"
            }
        }
        
        func asURLRequest() throws -> URLRequest {
            let settingModel = SettingModel.sharedModel()
            
            let url = URL(string: settingModel.baseUrl())
            
            var urlRequest = URLRequest(url: url!.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            // apply accept
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            
            // apply user token parameter
            switch self {
            case .registerDevice(_), .logout(_), .getBlogPost(_), .updateProfile(_), .getProfile(_), .uploadProfileProperties(_), .getInboxThreads(_), .getTrashedThreads(_), .createThread(_), .sendMessage(_), .threadMessages(_, _), .userList(_), .markMessageRead(_), .markThreadRead(_), .deleteThread(_), .restoreThread(_), .unreadThreads, .createBlogPosts(_):
                if let userTokenString = settingModel.userToken?.token {
                    urlRequest.addValue("Bearer "+userTokenString, forHTTPHeaderField: "Authorization")
                    Constants.debugPrint("using user token: \(userTokenString)")
                }
                break
            default:
                // apply API key header
                urlRequest.addValue("Bearer "+settingModel.apiKey(), forHTTPHeaderField: "Authorization")
                break
            }
            
            // encode parameters
            switch self {
            case .blogPosts(let parameters), .authenticate(let parameters), .registerDevice(let parameters), .updateProfile(_, let parameters), .registerUser(let parameters), .getInboxThreads(let parameters), .getTrashedThreads(let parameters), .createThread(let parameters), .threadMessages(_, let parameters), .userList(let parameters), .createBlogPosts(let parameters):
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
                break
            case .forgotPassword(let email):
                urlRequest = try URLEncoding.default.encode(urlRequest, with: ["email" : email])
                break
            case .logout(let device):
                urlRequest = try URLEncoding.default.encode(urlRequest, with: device.logoutParameters())
                break
            default: ()
            }
        
            Constants.debugPrint(urlRequest.url!)
            return urlRequest
        }
    }
    
    func listenForReachability() {
        self.reachabilityManager?.listener = { status in
            //debugPrint("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                self.isNetworkReachable = false
                break
            case .reachable(_), .unknown:
                self.isNetworkReachable = true
                break
            }
        }
        
        self.reachabilityManager?.startListening()
    }
}
