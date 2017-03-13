//
//  DDPListeners.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 13/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation
import Meteor

open class DDPListeners {
    
    open static func methodListener(named methodName: String, onSuccess: ((Any) -> Void)?, onError: ((Error) -> Void)?, onFinish: ((Void) -> Void)?) -> METMethodCompletionHandler {
        DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName)
        return { (result: Any?, error: Error?) in
            if  let error = error,
                let onError = onError {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName, DDPLog.kLogResultError, error.localizedDescription)
                onError(error)
            }
            if  let result = result,
                let onSuccess = onSuccess {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName, DDPLog.kLogResultSuccess, "\(result)")
                onSuccess(result)
            }
            if  let onFinish = onFinish {
                onFinish()
            }
        }
    }
    
    open static func subscriptionListener(named subscriptionName: String, onSuccess: ((Void) -> Void)?, onError: ((Error) -> Void)?, onFinish: ((Void) -> Void)?) -> METSubscriptionCompletionHandler {
        return DDPListeners.errorListener(named: subscriptionName,
                                          withHeader: DDPLog.kLogHeaderSubscription,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    open static func loginListener(onSuccess: ((Void) -> Void)?, onError: ((Error) -> Void)?, onFinish: ((Void) -> Void)?) -> METLogInCompletionHandler {
        return DDPListeners.errorListener(named: "###",
                                          withHeader: DDPLog.kLogHeaderLogin,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    open static func logoutListener(onSuccess: ((Void) -> Void)?, onError: ((Error) -> Void)?, onFinish: ((Void) -> Void)?) -> METLogOutCompletionHandler {
        return DDPListeners.errorListener(named: "###",
                                          withHeader: DDPLog.kLogHeaderLogout,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    fileprivate static func errorListener(named name: String, withHeader header: String, onSuccess: ((Void) -> Void)?, onError: ((Error) -> Void)?, onFinish: ((Void) -> Void)?) -> (Error?) -> Void {
        DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderLogin, params: name)
        return { (error: Error?) in
            if  let error = error,
                let onError = onError {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderLogin, params: name, DDPLog.kLogResultError, error.localizedDescription)
                onError(error)
            }
            if  let onSuccess = onSuccess {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderLogin, params: name, DDPLog.kLogResultSuccess)
                onSuccess()
            }
            if  let onFinish = onFinish {
                onFinish()
            }
        }
    }
    
}
