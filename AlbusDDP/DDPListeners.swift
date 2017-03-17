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
    
    open static func methodListener(named methodName: String, onSuccess: ((Any?) -> Void)? = nil, onError: ((Error) -> Void)? = nil, onFinish: (() -> Void)? = nil) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: true, onSuccess: onSuccess, onError: onError, onFinish: onFinish)
    }
    
    open static func methodListener(named methodName: String, onMainThread: Bool, onSuccess: ((Any?) -> Void)? = nil, onError: ((Error) -> Void)? = nil, onFinish: (() -> Void)? = nil) -> METMethodCompletionHandler {
        return DDPListeners.resultListener(named: methodName, onMainThread: onMainThread, onSuccess: onSuccess, onError: onError, onFinish: onFinish)
    }
    
    fileprivate static func resultListener(named methodName: String, onMainThread: Bool, onSuccess: ((Any?) -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> METMethodCompletionHandler {
        DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName)
        return { (result: Any?, error: Error?) in
            if let error = error {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName, DDPLog.kLogResultError, error.localizedDescription)
                if let onError = onError {
                    DDPListeners.execute(onError, withError: error, onMainThread: onMainThread)
                }
            } else {
                DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderMethod, params: methodName, DDPLog.kLogResultSuccess, "\(result)")
                if let onSuccess = onSuccess {
                    DDPListeners.execute(onSuccess, withResult: result, onMainThread: onMainThread)
                }
            }
            if let onFinish = onFinish {
                DDPListeners.execute(onFinish, onMainThread: onMainThread)
            }
        }
    }
    
    open static func subscriptionListener(named subscriptionName: String, onMainThread: Bool = false, onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onFinish: (() -> Void)? = nil) -> METSubscriptionCompletionHandler {
        return DDPListeners.errorListener(named: subscriptionName,
                                          withHeader: DDPLog.kLogHeaderSubscription,
                                          onMainThread: onMainThread,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    open static func loginListener(onMainThread: Bool = false, onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onFinish: (() -> Void)? = nil) -> METLogInCompletionHandler {
        return DDPListeners.errorListener(named: "###",
                                          withHeader: DDPLog.kLogHeaderLogin,
                                          onMainThread: onMainThread,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    open static func logoutListener(onMainThread: Bool = false, onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil, onFinish: (() -> Void)? = nil) -> METLogOutCompletionHandler {
        return DDPListeners.errorListener(named: "###",
                                          withHeader: DDPLog.kLogHeaderLogout,
                                          onMainThread: onMainThread,
                                          onSuccess: onSuccess,
                                          onError: onError,
                                          onFinish: onFinish)
    }
    
    fileprivate static func errorListener(named name: String, withHeader header: String, onMainThread: Bool, onSuccess: (() -> Void)?, onError: ((Error) -> Void)?, onFinish: (() -> Void)?) -> (Error?) -> Void {
        DDPLog.p(DDPLog.kLogTag, header: header, params: name)
        return { (error: Error?) in
            if let error = error {
                DDPLog.p(DDPLog.kLogTag, header: header, params: name, DDPLog.kLogResultError, error.localizedDescription)
                if let onError = onError {
                    DDPListeners.execute(onError, withError: error, onMainThread: onMainThread)
                }
            } else {
                DDPLog.p(DDPLog.kLogTag, header: header, params: name, DDPLog.kLogResultSuccess)
                if let onSuccess = onSuccess {
                    DDPListeners.execute(onSuccess, onMainThread: onMainThread)
                }
            }
            if  let onFinish = onFinish {
                DDPListeners.execute(onFinish, onMainThread: onMainThread)
            }
        }
    }
    
    
    
    fileprivate static func execute(_ closure: @escaping (()->Void), onMainThread: Bool) {
        if onMainThread {
            DispatchQueue.main.async(execute: {
                closure()
            })
        } else {
            closure()
        }
    }
    
    fileprivate static func execute(_ closure: @escaping ((Any?)->Void), withResult result: Any?, onMainThread: Bool) {
        if onMainThread {
            DispatchQueue.main.async(execute: {
                closure(result)
            })
        } else {
            closure(result)
        }
    }
    
    fileprivate static func execute(_ closure: @escaping ((Error)->Void), withError error: Error, onMainThread: Bool) {
        if onMainThread {
            DispatchQueue.main.async(execute: {
                closure(error)
            })
        } else {
            closure(error)
        }
    }
    
}
