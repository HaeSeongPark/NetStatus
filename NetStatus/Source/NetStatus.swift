//
//  NetStatus.swift
//  NetStatusDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//  https://www.appcoda.com/network-framework/?fbclid=IwAR25_QtBmNFei7tOoqHfX4PmQlsPShLidQQuKNgeeAU3vGEhIQL4Z29Vgug
//  TODO: https://www.appcoda.com/creating-pod-cocoapods/
//  TODO: http://blog.naver.com/PostView.nhn?blogId=itperson&logNo=220901635926&parentCategoryNo=&categoryNo=103&viewDate=&isShowPopularPosts=true&from=search 읽기

import Foundation
import Network

public class NetStatus {
    
    static public let shared = NetStatus()
    
    var monitor: NWPathMonitor?
    
    public var isMonitoring = false;
    
    public var didStartMonitoringHandler: (()->Void)?
    public var didStopMonitoringHandler: (()->Void)?
    public var netStatusChangeHandler: (()->Void)?
    
    public var isConntected:Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    public var interfaceType:NWInterface.InterfaceType? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.filter {
            monitor.currentPath.usesInterfaceType($0.type)}.first?.type
    }
    
    public var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map{ $0.type }
    }
    
    public var isExpensive:Bool {
        return monitor?.currentPath.isExpensive ?? false
    }
    
    private init() {}
    
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetStatus_Monitor")
        monitor?.start(queue: queue)
        
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
        
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    public func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
    
    deinit {
        stopMonitoring()
    }
}

