//
//  Constants.swift
//  ToDoCat
//
//  Created by 서준일 on 3/14/25.
//
import UIKit

struct Constants {
    static var engTitle: String = "ToDoCat"
    static var korTitle: String = "매일할고양"
    
    static func getCatImageUrl(says: String?) -> String {
        guard let says = says else {
            return "https://cataas.com/cat?width=400&height=400"
        }
        return "https://cataas.com/cat/says/\(says)?width=400&height=400"
    }
    
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    static func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    static func getDeviceModelName() -> String {
        let device = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)
        
        if device.responds(to: selector) { // [옵셔널 체크 실시]
            let modelName = String(describing: device.perform(selector, with: "marketing-name").takeRetainedValue())
            return modelName
        }
        return "알 수 없음"
    }
}
