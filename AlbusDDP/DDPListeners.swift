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
    
    open static func methodListener(named methodName: String) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: true, onSuccess: nil, onError: nil, onFinish: nil)
    }
    
    open static func methodListener(named methodName: String, onFinish: (() -> Void)?) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: true, onSuccess: nil, onError: nil, onFinish: onFinish)
    }
    
    open static func methodListener(named methodName: String, onSuccess: ((Any?) -> Void)?, onError: ((Error) -> Void)?) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: true, onSuccess: onSuccess, onError: onError, onFinish: nil)
    }
    
    open static func methodListener(named methodName: String, onSuccess: ((Any?) -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: true, onSuccess: onSuccess, onError: onError, onFinish: onFinish)
    }
    
    open static func methodListener(named methodName: String, onMainThread: Bool) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: onMainThread, onSuccess: nil, onError: nil, onFinish: nil)
    }
    
    open static func methodListener(named methodName: String, onMainThread: Bool, onFinish: (() -> Void)?) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: onMainThread, onSuccess: nil, onError: nil, onFinish: onFinish)
    }
    
    open static func methodListener(named methodName: String, onMainThread: Bool, onSuccess: ((Any?) -> Void)?, onError: ((Error) -> Void)?) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: onMainThread, onSuccess: onSuccess, onError: onError, onFinish: nil)
    }
    
    open static func methodListener(named methodName: String, onMainThread: Bool, onSuccess: ((Any?) -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: onMainThread, onSuccess: onSuccess, onError: onError, onFinish: onFinish)
    }
    
    fileprivate static func resultListener(named methodName: String, onMainThread: Bool, onSuccess: ((Any?) -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METMethodCompletionHandler {
        DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName)
        return { (result: Any?, error: Error?) in
            if let error = error {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName, DDPLog.kLogResultError, error.localizedDescription)
                if let onError = onError {
                    if onMainThread {
                        DispatchQueue.main.async(execute: {
                            onError(error)
                        })
                    } else {
                        onError(error)
                    }
                }
            } else {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName, DDPLog.kLogResultSuccess, "\(result)")
                if let onSuccess = onSuccess {
                    if onMainThread {
                        DispatchQueue.main.async(execute: {
                            onSuccess(result)
                        })
                    } else {
                        onSuccess(result)
                    }
                }
            }
            if  let onFinish = onFinish {
                if onMainThread {
                    DispatchQueue.main.async(execute: {
                        onFinish()
                    })
                } else {
                    onFinish()
                }
            }
        }
    }
    
    open static func subscriptionListener(named subscriptionName: String, onSuccess: (() -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METSubscriptionCompletionHandler {
        return DDPListeners.errorListener(named: subscriptionName,
                                          withHeader: DDPLog.kLogHeaderSubscription,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    open static func loginListener(onSuccess: (() -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METLogInCompletionHandler {
        return DDPListeners.errorListener(named: "###",
                                          withHeader: DDPLog.kLogHeaderLogin,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    open static func logoutListener(onSuccess: (() -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METLogOutCompletionHandler {
        return DDPListeners.errorListener(named: "###",
                                          withHeader: DDPLog.kLogHeaderLogout,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    fileprivate static func errorListener(named name: String, withHeader header: String, onSuccess: (() -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> (Error?) -> Void {
        DDPLog.p(DDPLog.kLogTag, header: header, params: name)
        return { (error: Error?) in
            if let error = error {
                DDPLog.p(DDPLog.kLogTag, header: header, params: name, DDPLog.kLogResultError, error.localizedDescription)
                if let onError = onError {
                    onError(error)
                }
            } else {
                DDPLog.p(DDPLog.kLogTag, header: header, params: name, DDPLog.kLogResultSuccess)
                if let onSuccess = onSuccess {
                    onSuccess()
                }
            }
            if  let onFinish = onFinish {
                onFinish()
            }
        }
    }
    
}
