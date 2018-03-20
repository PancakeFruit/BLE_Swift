//
//  BLEData.swift
//  BLE_Swift
//
//  Created by 魏峥 on 2017/9/11.
//  Copyright © 2017年 魏峥. All rights reserved.
//

import UIKit

class BLEData: NSObject {
    //指令号
    var CMD : UInt8?
    let cmdDict = ["OpenReal":UInt8(0x08),"closeReal":UInt8(0x08),"getPower":UInt8(0x04),"setTime":UInt8(0x01),"getFile":UInt8(0x06),"hardwareTime":UInt8(0x03),"deleteData":UInt8(0x07),"hardwareVersion":UInt8(0x05),"versionUp":UInt8(0x53),"deleteHistoryAll":UInt8(0x54),"openWifi":UInt8(0x09),"setName":UInt8(0x02),"openMagnetic":UInt8(0x01),"closeMagnetic":UInt8(0x00),"GetFilenameend":UInt8(0x60),"setModel":UInt8(0x0C),"setRadio":UInt8(0x0D),"setWiftCode":UInt8(0x0E),"setRouter":UInt8(0x0F),"setIpport":UInt8(0x10),"ControlStar":UInt8(0x0A)]
    
    
    //帧头
    var frameHeader_0 = UInt8(0x7F)
    var frameHeader_1 = UInt8(0xF7)
    //帧尾
    var frameEnd_18 = UInt8(0x57)
    var frameEnd_19 = UInt8(0x75)
    
}

