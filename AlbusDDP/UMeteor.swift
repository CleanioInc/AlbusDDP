//
//  UMeteor.swift
//  cleaniogroom
//
//  Created by Guillaume Elloy on 24/05/16.
//  Copyright © 2016 Guillaume Elloy. All rights reserved.
//

import Foundation
import Meteor

private let kWebserviceURLKey = "kWebserviceURLKey"
#if DEBUG
    private let kWebserviceURL = "ws://grooms-service-staging.getcleanio.com/websocket"
#else
    private let kWebserviceURL = "ws://grooms-service.getcleanio.com/websocket"
#endif


class UMeteor {
    
    // MARK: Accessors
    
    fileprivate class func getWebserviceURL() -> URL {
        if let webserviceURLString = self.restoreWebserviceURLString(),
            let webserviceURL = URL(string:webserviceURLString) {
            
            return webserviceURL
        }
        return URL(string:kWebserviceURL)!
    }
    
    
    class func getDDPClient() -> METDDPClient {
        return METDDPClient(serverURL: getWebserviceURL())
    }
    
    
    class func setDDPClient() {
        if GMeteor.isConnected {
            GMeteor.logout(completionHandler: { (opError) in
                GMeteor.disconnect()
                GMeteor = getDDPClient()
                GMeteor.connect()
            })
        } else {
            GMeteor = getDDPClient()
            GMeteor.connect()
        }
    }
    
    
    // MARK: Archivers
    
    class func saveWebserviceURLString(_ opWebserviceURLString: String?) {
        let userDefaults = UserDefaults.standard
        if let webserviceURLString = opWebserviceURLString {
            userDefaults.set(webserviceURLString, forKey: kWebserviceURLKey)
        }
        else {
            userDefaults.removeObject(forKey: kWebserviceURLKey)
        }
        setDDPClient()
    }
    
    class func restoreWebserviceURLString() -> String? {
        return UserDefaults.standard.string(forKey: kWebserviceURLKey)
    }
    
    
    // MARK: Helpers
    
    class func loginWithCredentials(_ credentials: Credentials, closure: UClosure) {
        GMeteor.login(withEmail: credentials.email, password: credentials.password) { (opError) in
            if let error = opError {
                closure.onError(error)
            }
            else {
                checkUserRecursively(closure)
            }
        }
    }
    
    fileprivate class func checkUserRecursively(_ closure: UClosure) {
        if (!initLoginIfUser(closure)) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(500 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) {
                checkUserRecursively(closure)
            }
        }
    }
    
    
    fileprivate class func initLoginIfUser(_ closure: UClosure) -> Bool {
        if let user = UData.getUser() {
            let role = user.profile.role
            if (role != nil
                && (role == "admin" || role == "delivery")) {
                
                UMixpanel.identifyProfileWithId(user.id!, alias: false)
                UMixpanel.updateProfileWithUser(user)
                UMixpanel.registerSuperProperties(nil)
                
                UMeteor.subscribe(UClosure(named: "time"))
                UMeteor.subscribe(UClosure(named: "formatted.orders"))
                UMeteor.subscribe(UClosure(named: "driver.trips"))
                
                closure.onSuccess(nil)
            } else {
                let userInfo = [
                    NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorized", value: "Your account is not authorized to use this app", comment: ""),
                    NSLocalizedFailureReasonErrorKey : NSLocalizedString("Unauthorized", value: "Account unauthorized", comment: "")
                ]
                closure.onError(NSError(domain: "ShiploopHttpResponseErrorDomain", code: 401, userInfo: userInfo))
            }
            return true
        }
        return false
    }
    
    
    class func logout() {
        GMeteor.logout { (opError) in
            if let error = opError {
                ULog.d("DDP", message: "LOGOUT ERROR : \(error)")
            }
            else {
                ULog.d("DDP", message: "LOGOUT SUCCESS")
            }
        }
        
    }
    
    class func callMethod(_ parameters: [Any]?, closure: UClosure) {
        ULog.d("DDP", message: "Call Method \(closure.name)")
        GMeteor.callMethod(withName: closure.name, parameters: parameters) { (opResult, opError) in
            DispatchQueue.main.async(execute: {
                if let error = opError {
                    closure.onError(error)
                }
                else {
                    closure.onSuccess(opResult)
                }
            });
        }
    }
    
    class func subscribe(_ closure: UClosure) {
        subscribe(nil, closure: closure)
    }
    
    class func subscribe(_ parameters: [Any]?, closure: UClosure) {
        GMeteor.addSubscription(withName: closure.name, parameters: parameters) { (opError) in
            if let error = opError {
                closure.onError(error)
            }
            else {
                closure.onSuccess(nil)
            }
        }
    }
    
}
