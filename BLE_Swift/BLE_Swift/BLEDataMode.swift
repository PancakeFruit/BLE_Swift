//
//  BLEDataMode.swift
//  BLE_Swift
//
//  Created by 魏峥 on 2017/8/25.
//  Copyright © 2017年 魏峥. All rights reserved.
//

import UIKit

let mode = BLEData()
var receiveTemp = [UInt8]()
public var sendByte = [UInt8](repeating: 0, count: 20)

class BLEDataMode: NSObject {
    
   //MARK: - 手机向硬件发送指令 -
    
    
    //开启实时数据
    func startRealTime() -> [UInt8] {
        //帧头
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        //内容
        mode.CMD     = mode.cmdDict["OpenReal"]
        sendByte[2]  = mode.CMD!//实时传输指令
        sendByte[3]  = UInt8(0x01)//开启
        for i in 4 ..< 17 {
            sendByte[i] = UInt8(0x00)
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int (sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        //帧尾
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //关闭实时数据
    func closeRealTime() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["CloseReal"]
        sendByte[2]  = mode.CMD!//实时传输指令
        sendByte[3]  = UInt8(0x00)//关闭
        for i in 4 ..< 17 {
            sendByte[i] = UInt8(0x00)
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int (sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        //帧尾
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    //向设备写入获取电量的请求
    func getPower()->[UInt8]  {
        //var sendByte = [UInt8](repeating: 0, count: 20)
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["getPower"]
        sendByte[2]  = mode.CMD!//获取设备电池电量指令
        var sum :Int = 0
        for i in 3 ..< 17 {
            sendByte[i] = UInt8(0x00)
        }
        for i in 2 ..< 17 {
            sum += Int (sendByte[i])
        }
        sendByte[17] =  (UInt8(sum & 0xFF))
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //设置时间(1. 先获取某一个数据的时间，2. 把时间传给硬件)
        func setTime()->[UInt8] {
        let now = Date()
        let calendar :Calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year,.month,.day,.hour,.minute,.second])
        let components = calendar.dateComponents(unitFlags, from: now)
        
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["setTime"]
        sendByte[2]  = mode.CMD!//设置设备时间指令
        sendByte[3]  = UInt8(components.year! - 2000)
        sendByte[4]  = UInt8(components.month!)
        sendByte[5]  = UInt8(components.day!)
        sendByte[6]  = UInt8(components.hour!)
        sendByte[7]  = UInt8(components.minute!)
        sendByte[8]  = UInt8(components.second!)
        for i in 9..<17 {
            sendByte[i] = 0
        }
        var sum:Int = 0
        for i in 2..<17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //获取设备上保存的数据(手机给设备说，我要获取你的数据)
    func OnGetFileNames(year:Int,mouth:Int) -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["getFile"]
        sendByte[2]  = mode.CMD!//获取储存文件指令
        sendByte[3]  = UInt8(year)
        sendByte[4]  = UInt8(mouth)
        for i in 5 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //获取设备的时间
    func GetHardwareTime()->[UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["hardwareTime"]
        sendByte[2]  = mode.CMD!//获取设备中的时间指令
        for i in 3 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17]  = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //删除设备中的历史文件
    func DeleteData(tag:String)->[UInt8]  {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["deleteData"]
        sendByte[2]  = mode.CMD!//删除文件指令
        sendByte[3]  = UInt8(0x00)//(0x00)-删除一个文件 （0x01)删除月/年文件 (0x02)删除所有文件
        for i in 0 ..< 12 {
            let charecterAtIndex = tag[tag.index(tag.startIndex, offsetBy: i)]
            let charecterToString = String(charecterAtIndex)
            sendByte[i + 4] = UInt8(charecterToString)!
}
        sendByte[16] = UInt8(0x00)
        var sum :Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //获取固件版本信息
    func GetHardwareVersion() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["hardwareVersion"]
        sendByte[2]  = mode.CMD!//获取固件版本指令
        for i  in 3 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //控制进入空中升级
    func StartVersionUp() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["versionUp"]
        sendByte[2]  = mode.CMD!//空中升级
        for i in 3 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum % 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //删除所有历史数据
    func DeleteHistoryAll() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["deleteHistoryAll"]
        sendByte[2]  = mode.CMD!//删除历史数据
        for i in 3 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //打开Wi-Fi电源
    func OpenWifi() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["openWifi"]
        sendByte[2]  = mode.CMD!//控制Wi-Fi电源
        sendByte[3]  = UInt8(0x01)
        for i in 4 ..< 17 {
            sendByte[i] = UInt8(0x00)
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //设置蓝牙名称
    func SetName(name:String) -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["setName"]
        sendByte[2]  = mode.CMD!//设置设备名称指令
        sendByte[3]  = UInt8(name.characters.count)
        for i in 0 ..< 13 {
            if i < name.characters.count {
                let charecterAtIndex  = name[name.index(name.startIndex, offsetBy: i)]
                let charecterToString = String(charecterAtIndex)
                sendByte[i + 4] = UInt8(charecterToString)!
            }else
            {
                sendByte[i + 4] = UInt8(0x00)
            }
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //开启磁力校准
    func OpenMagneticForceCalibrate() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["openMagnetic"]
        sendByte[2]  = mode.CMD!//控制磁力计校准指令
        sendByte[3]  = UInt8(0x01)//开启
        for i in 4 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    //关闭磁力校准
    func CloseMagneticForceCalibrate() -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["closeMagnetic"]
        sendByte[2]  = mode.CMD!//控制磁力计校准指令
        sendByte[3]  = UInt8(0x00)//关闭
        for i in 4 ..< 17 {
            sendByte[i] = 0
        }
        var sum : Int = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
    
    //设置设备工作工作模式
    func SetModel(model:Int) -> [UInt8] {
        sendByte[0]  = mode.frameHeader_0
        sendByte[1]  = mode.frameHeader_1
        mode.CMD     = mode.cmdDict["setModel"]
        sendByte[2]  = mode.CMD!
        sendByte[3]  = model==0 ? UInt8(0x00) : UInt8(0x01)
        for i in 4 ..< 17 {
            sendByte[i] = 0
        }
        var sum = 0
        for i in 2 ..< 17 {
            sum += Int(sendByte[i])
        }
        sendByte[17] = UInt8(sum & 0xFF)
        sendByte[18] = mode.frameEnd_18
        sendByte[19] = mode.frameEnd_19
        return sendByte
    }
}


extension BLEDataMode
{
    //MARK: - 设备向手机发送消息 -
    //分析实时数据
    func AnalyticalData(data:Data)  {
        let len : Int   = data.count
        let byteData = malloc(len)
        var bytes = [UInt8](data)
        memcpy(byteData,bytes,len)
        for i in 0 ..< data.count
        {
            for j in( 0 ..< data.count - 1).reversed()
            {
                receiveTemp[j] = receiveTemp[j - 1]
            }
            receiveTemp[0] = bytes[i]
            Parsedata(recevier: receiveTemp)
        }
    }
    
    func Parsedata(recevier:[UInt8])  {
        let dataCount : Int = 40
        
        if  (recevier[dataCount - 1] == UInt8(0x7F) && recevier[dataCount - 2] == UInt8(0xF7)){
            var data = [UInt8](repeating: 0, count: 34)
            for i in 0 ..< 34 {
                data[i] = recevier[36 - i]
            }
        }
    }
    
    func Decode_Data(dataTemp:[UInt8]) {
        var data   = Data (bytes: dataTemp, count: 33)
        var xPitch = Int((dataTemp[1]  & 0xFF) << 8)  | Int((dataTemp[0]  & 0xFF))
        var xYaw   = Int((dataTemp[3]  & 0xFF) << 8)  | Int((dataTemp[2]  & 0xFF))
        var xRoll  = Int((dataTemp[5]  & 0xFF) << 8)  | Int((dataTemp[4]  & 0xFF))
        var xHigh  = Int((dataTemp[7]  & 0xFF) << 8)  | Int((dataTemp[6]  & 0xFF))
        var accX   = Int((dataTemp[9]  & 0xFF) << 8)  | Int((dataTemp[8]  & 0xFF))
        var accY   = Int((dataTemp[11] & 0xFF) << 8)  | Int((dataTemp[10] & 0xFF))
        var accZ   = Int((dataTemp[13] & 0xFF) << 8)  | Int((dataTemp[12] & 0xFF))
        var magnX  = Int((dataTemp[15] & 0xFF) << 8)  | Int((dataTemp[14] & 0xFF))
        var magnY  = Int((dataTemp[17] & 0xFF) << 8)  | Int((dataTemp[16] & 0xFF))
        var magnZ  = Int((dataTemp[19] & 0xFF) << 8)  | Int((dataTemp[18] & 0xFF))
        var angle  = Int((dataTemp[21] & 0xFF) << 8)  | Int((dataTemp[20] & 0xFF))
        
        var lat    = Int((dataTemp[25] & 0xFF) << 24) | Int((dataTemp[24] & 0xFF) << 16) |
                      Int((dataTemp[23] & 0xFF) << 8) | Int((dataTemp[22] & 0xFF))
        var lot    = Int((dataTemp[29] & 0xFF) << 24) | Int((dataTemp[28] & 0xFF) << 16) |
                      Int((dataTemp[27] & 0xFF) << 8) | Int((dataTemp[26] & 0xFF))
        var xSpeed = Int((dataTemp[31] & 0xFF) << 8)  | Int((dataTemp[30] & 0xFF))
        var gpsH   = Int((dataTemp[33] & 0xFF) << 8)  | Int((dataTemp[32] & 0xFF))
        
        if (xPitch & 0x8000) == 0x8000{
            xPitch = -(xPitch & 0x7FFF)
        }
        else
        {
            xPitch =  (xPitch & 0x7FFF)
        }
        
        if (xYaw & 0x8000) == 0x8000
        {
            xYaw = -(xYaw & 0x7FFF)
        }
        else
        {
            xYaw =  (xYaw & 0x7FFF)
        }
        
        if (xRoll * 0x8000) == 0x8000
        {
            xRoll = -(xRoll & 0x7FFF)
        }
        else
        {
            xRoll = (xRoll & 0x7FFF)
        }
        
        if (xHigh & 0x8000) == 0x8000
        {
            xHigh = -(xHigh & 0x7fff)
        }
        else
        {
            xHigh = (xHigh & 0x7fff)
        }

        if (accX & 0x8000) == 0x8000
        {
            accX = -(accX & 0x7fff)
        }
        else
        {
            accX = (accX & 0x7fff)
        }
        
        if (accY & 0x8000) == 0x8000
        {
            accY = -(accY & 0x7fff)
        }
        else
        {
            accY = (accY & 0x7fff)
        }
        
        if (accZ & 0x8000) == 0x8000
        {
            accZ = -(accZ & 0x7fff)
        }
        else
        {
            accZ = (accZ & 0x7fff)
        }
        
        if (magnX & 0x8000) == 0x8000
        {
            magnX = -(magnX & 0x7fff)
        }
        else
        {
            magnX = (magnX & 0x7fff)
        }
        
        if (magnY & 0x8000) == 0x8000
        {
            magnY = -(magnY & 0x7fff)
        }
        else
        {
            magnY = (magnY & 0x7fff)
        }
        
        if (magnZ & 0x8000) == 0x8000
        {
            magnZ = -(magnZ & 0x7fff)
        }
        else
        {
            magnZ = (magnZ & 0x7fff)
        }
        
        if (angle & 0x8000) == 0x8000
        {
            angle = -(angle & 0x7fff)
        }
        else
        {
            angle = (angle & 0x7fff)
        }

        var acc = [3]
        acc[0]  = accX
        acc[1]  = accY
        acc[2]  = accZ
        
        var magn = [3]
        magn[0]  = magnX
        magn[1]  = magnY
        magn[2]  = magnZ
        
        let trAngle = Float(xPitch/10)
        var pitch   = Float(xPitch/10)
        var yaw     = Float(xYaw/10)
        var roll    = Float(xRoll/10)
        var height  = GetHeightValue(height: xHigh)
        
        var longitud  = Float(lot/100000)
        var latitude  = Float(lat/100000)
        var speed     = Float(xSpeed/1000)
        var gpsHeight = gpsH
        var dataStr   = String (format: "%f:%f:%f:%d:%f:%d:%d:%d:%d:%f:%f:%d:%d:%d:%f", pitch,roll,yaw,height,speed,gpsHeight,accX,accY,accZ,latitude,longitud,magnX,magnY,magnZ,trAngle)
    }
    
    func GetHeightValue(height:Int) -> Int {
        var tempCount : Int = 5
        var heightTemp = [tempCount]
        var sum = 0
        for i in (0 ..< tempCount - 1).reversed()
        {
            heightTemp[i] = heightTemp[i - 1]
        }
        heightTemp[0] = height
        for j in 0 ..< tempCount {
            sum += heightTemp[j]
        }
        var sumHeight = sum / tempCount
        return sumHeight
    }
    
    func Dataxxx(roll:Float,pitch:Float,x:Float,y:Float,z:Float) ->  Float {
        var xh = x * cos(pitch) + y * sin(roll) * sin(pitch) - z * cos(roll) * sin( pitch)
        var yh = y * cos(roll) + z * sin(roll)
        var value : Float = 0
        if xh < 0 {
            value = 180 - atan(yh / xh) * 180 / Float.pi
        }else if (xh > 0 && yh < 0)
        {
            value = -atan(yh / xh) * 180 / Float.pi
        }else if (xh > 0 && yh > 0)
        {
            value = 360 - atan(yh / xh) * 180 / Float.pi
        }else if (xh == 0 && yh < 0)
        {
            value = 90
        }else if (xh == 0 && yh > 0)
        {
            value = 270
        }
        return value
        
    }
    
}














