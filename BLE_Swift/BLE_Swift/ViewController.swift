//
//  ViewController.swift
//  BLE_Swift
//
//  Created by 魏峥 on 2017/8/24.
//  Copyright © 2017年 魏峥. All rights reserved.
//

import UIKit
import CoreBluetooth

//系统蓝牙管理工具
var manager : CBCentralManager!
//保存收到的蓝牙设备
var deviceList:NSMutableArray! = NSMutableArray()
var devicelDic : NSMutableDictionary!


//连接的外围设备
var connectedPeripheral : CBPeripheral!

//保存的设备特性()
var readCharacteristic : CBCharacteristic!
var writeCharacteristic : CBCharacteristic!

let BLE = BLEDataMode()

//服务和特征的UUID
let kServiceUUID = [CBUUID(string:"0000fff0-0000-1000-8000-00805f9b34fb")]
//蓝牙设备提供的notify特征/读取
let kReadCharacteristicUUID = [CBUUID(string:"0000fff1-0000-1000-8000-00805f9b34fb")]
//写入特征
let kWriteCharacteristicUUID = [CBUUID(string:"0000fff2-0000-1000-8000-00805f9b34fb")]

var isRealTime = Int()// 判断是否开启实时数据 1是0否
var receiveCount = 0
let BUFFR_LENGTH = 9000
var receiveDataTemp  = [UInt8]()
var isUpVersion = Bool()

class ViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        InitBLE()
      print("输出乘法表")
        for i in 1 ..< 10 {
            for j in 1 ..< 1 + i {
                print("\(i)*\(j) = " + String (format: "%-2d",i*j),terminator:"\t")
            }
            print("")
        }
    }
    func InitBLE()  {
        print("我来啦")
        manager = CBCentralManager.init(delegate:self, queue: nil)
    }
 

}

extension ViewController:CBCentralManagerDelegate,CBPeripheralDelegate
{
public func centralManagerDidUpdateState(_ central: CBCentralManager)
{
    switch central.state {
    case .poweredOn:
        manager.scanForPeripherals(withServices: nil, options: nil)
    case.poweredOff:
        print("蓝牙已经关闭")
    case.unauthorized:
        print("无权使用")
    default:
        print("未知原因")
    }
}
    
    // MARK: - 发现设备Delegate
    //查到外设后，停止扫描，连接设备
    //广播、扫描的响应数据保存在advertisementData 中，可以通过CBAdvertisementData 来访问它。
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /*
        if (peripheral.name?.hasPrefix("YEPE"))! {
            devicelDic.setValue(peripheral, forKey: peripheral.name!)
            central.connect(peripheral, options: nil)
        }
         */
        if (!deviceList.contains(peripheral)) {
            //把搜索到的外围设备添加到数组
            deviceList!.add(peripheral)
            print("名字：\(String(describing: peripheral.name))")
            print("数组：\(deviceList!)")
            // 添加完后，就开始连接外设
            // central.connect(peripheral, options: nil) // 会根据条件触发，连接成功，失败，断开连接的代理方法
            // 如果你扫描到多个外设，要连接特定的外设，可以用以下方法
                    if peripheral.name == "YEPE" {
                        //停止扫描外设
                        manager.stopScan()
                        print("停止扫描啦")
                        // 连接设备
                        central.connect(peripheral, options: nil)
                        print("连接成功啦！！！")
                    
                    }
        }
 
    }
    
    //连接外设成功，开始发现服务
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        print("连接外设成功，开始发现服务")
        connectedPeripheral = peripheral
        connectedPeripheral.delegate = self
        // 开始扫描外设的服务
        // 参数设了nil，是扫描所有服务，如果你知道你想要的服务的UUID，那么也可以填写指定的UUID
        connectedPeripheral.discoverServices(kServiceUUID)
        //这里会回调代理peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)  这里方法里有这个外设的服务信息

    }
    //连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("连接外设失败===\(String(describing: error))")
    }
    // MARK: - CBPeripheralDelegate - 如果发现服务，则搜索特征 -
    //外设的服务信息
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        if error != nil {
            print("查找 characteristics 时  \(String(describing: peripheral.name)) 报错 \(String(describing: error?.localizedDescription))")
            return
        }
        for service in peripheral.services!
        {
            print("服务的UUID:\(service.uuid)")
            if (service.uuid == CBUUID (string: "0000fff0-0000-1000-8000-00805f9b34fb"))
            {
                // 发现特征，参数填哪个服务的特征，这个方法会回调特征信息的方法
                // 调特征信息的方法:func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
                peripheral.discoverCharacteristics(nil, for: service as CBService)
            }
        }
        
    }
    // MARK:  - 返回设备特征 -  已搜索到Characteristics()
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("发现特征服务:\(service.uuid.data) == 服务uuid:\(service.uuid)")
        if (error != nil) {
            print("发现错误特征:\(String(describing: error?.localizedDescription))")
            return
        }
        for characteristic in service.characteristics! {
            //罗列出所有特性，看哪些是notify方式的，哪些是read方式的，哪些是可写入的。
            print("服务uuid:\(service.uuid)  特征UUID:\(characteristic.uuid)")
            //特征的值被更新，用setNotifyValue:forCharacteristic
            switch characteristic.uuid.description {
            case "FFF1":
                //订阅通知(详情看工程上面)
                //如果以通知的形式读取数据，则直接发到didUpdateValueForCharacteristic方法处理数据。
                readCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                
            case "FFF2":
                writeCharacteristic = characteristic
                power()
                GetHardwareTime()
            //peripheral.readValue(for: characteristic)
            default:
                break
            }
            
            //扫描描述
            // -- 当发现characteristic有descriptor,回调didDiscoverDescriptorsForCharacteristic(一般很少有。我这里没有)
            //peripheral.discoverDescriptors(for: characteristic)
            
        }

    }
    
    // MARK: - 设备向手机发送数据的回调 -
    // 获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if error != nil
        {
            print("发送数据错误的特性是：\(characteristic.uuid)  错误信息:\(String(describing: error?.localizedDescription))  错误数据:\(String(describing: characteristic.value))")
            return
        }
        //解析数据
        let data = Data(characteristic.value!)
        var bufferLength:Int = 0
        bufferLength += data.count
        let bytes = [UInt8](data)
        print("\(bytes)")
        var byteDate = [UInt8](bytes)
        if isRealTime == 0 {
            let  dataLength  = Int(data.count)
            if (receiveCount + dataLength) > BUFFR_LENGTH
            {
                //超过了就从头开始
                receiveCount = 0
                for i in 0 ..< BUFFR_LENGTH
                {
                   receiveDataTemp[i] = 0
                }
            }
            for i in 0 ..< dataLength
            {
                //不断的将数据存到缓冲中
                //receiveDataTemp[receiveCount + i] = byteDate[i]
                receiveDataTemp.insert( byteDate[i], at: receiveCount + i)
            }
            receiveCount += dataLength//接受到的数据长度
            print("收到数据的长度\(receiveDataTemp[2])")
            if (receiveDataTemp[receiveCount-2] == mode.frameEnd_18 && receiveDataTemp[receiveCount-1] == mode.frameEnd_19)
            {
                print("我找到帧尾了")
                //找到帧尾
                var sum = 0
                for i in 2 ..< receiveCount-3
                {
                    //和校验
                    sum += Int(receiveDataTemp[i])
                }
                if (receiveDataTemp[receiveCount-3] == UInt8(sum & 0xFF))
                {
                    //获得电量
                    if receiveDataTemp[2] == mode.cmdDict["getPower"]
                    {
                        let bat_per = receiveDataTemp[5]
                        print("\(bat_per)")
                        // UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"GetYepePower,%d",bat_per].UTF8String);
                    }else if(receiveDataTemp[2] == mode.cmdDict["getFile"])
                    {
                        var name = String()
                        for i in 0 ..< 12
                        {
                            name = String (format: "%s%d", name,receiveDataTemp[i+3]-0)
                        }
                        //UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"GetFileNames,%@",name].UTF8String);
                    }else if(receiveDataTemp[2] == mode.cmdDict["GetFilenameend"])
                    {
                        let count = ((receiveDataTemp[4]&0xFF) << 8) | ((receiveDataTemp[3]&0xFF))
                        // UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"GetFileNamesOver,%@",@""].UTF8String);
                    }else if(receiveDataTemp[2] == mode.cmdDict["OpenReal"])
                    {
                        isRealTime = 1;
                    }else if(receiveDataTemp[2] == mode.cmdDict["hardwareTime"])
                    {
                        var time = String()
                        for i in 0 ..< 6 {
                            let temp = receiveDataTemp[i+3]<10 ? String (format: "%d", receiveDataTemp[i+3]) : String (format: "%d", receiveDataTemp[i+3])
                            //time = String (format: "%@%@", time,temp)
                            time = String(time+temp)
                            print("\(time)")
                              //UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"GetYepeTime,20"].UTF8String);
                        }
                    }else if(receiveDataTemp[2] == mode.cmdDict["hardwareVersion"])
                    {
                        let vers = (receiveDataTemp[4]&0xFF) << 8 | ((receiveDataTemp[3]&0xFF))
                        _ = String (format: "%d.%d.%d", vers/100,(vers%100)/10,vers%10)
                        //UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"Yepe,getYepeVersionSuc,%@",versions].UTF8String);
                    }else if(receiveDataTemp[2] == mode.cmdDict["deleteData"])
                    {
                        let num = (receiveDataTemp[5] << 8 * 0xFF) | (receiveDataTemp[4] * 0xFF)
                        //UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"Yepe,DeleteDataAllCallback,%@",@""].UTF8String);
                        
                    }else if(receiveDataTemp[2] == mode.cmdDict["openWifi"])
                    {
                        if receiveDataTemp[3] == mode.cmdDict["setTime"] {
                            // UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"OpenWifi,%@",@""].UTF8String);
                        }else
                        {
                            print("关闭WI-FI电源成功")
                        }
                    }else if(receiveDataTemp[2] == mode.cmdDict["setTime"])
                    {
                        //UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"SetYepeTime,%@",@""].UTF8String);
                    }else if(receiveDataTemp[2] == mode.cmdDict["ControlStar"])
                    {
                        isUpVersion = true
                        //UnitySendMessage("SDKManager", "OnPhoneCall", [NSString stringWithFormat:@"Yepe,UpVersionStartSucCallback,%@",@""].UTF8String);
                    }else if(receiveDataTemp[2] == mode.cmdDict["setName"])
                    {
                        print("设置蓝牙名称成功")
                    }else if(receiveDataTemp[2] == mode.cmdDict["setModel"])
                    {
                        print("设置模式成功")
                    }else if(receiveDataTemp[2] == mode.cmdDict["setRadio"])
                    {
                        print("设置广播频率成功")
                    }else if(receiveDataTemp[2] == mode.cmdDict["setWiftCode"])
                    {
                        print("设置wifi名和密码成功")
                    }else if(receiveDataTemp[2] == mode.cmdDict["setRouter"])
                    {
                        print("设置wifi连接路由器名和密码成功")
                    }else if(receiveDataTemp[2] == mode.cmdDict["setIpport"])
                    {
                        print("设置wifi连接的TCP 的ip和端口号成功")
                    }
                    receiveCount = 0
                }else
                {
                    receiveCount = 0
                }

                }
            else if isRealTime == 1
            {
                BLE.AnalyticalData(data:data)
            }
        }
        
        }
        /*
         写数据，第一个参数传data类型的数据，第二个参数传写入数据的特征，第三个参数是枚举类型分别是CBCharacteristicWriteWithResponse和                                                  CBCharacteristicWriteWithoutResponse；
         peripheral.writeValue(<#T##data: Data##Data#>, for: <#T##CBCharacteristic#>, type: <#T##CBCharacteristicWriteType#>)
         */
    }
    
    //写数据
    
    // 对于以上的枚举类型的第一个CBCharacteristicWriteWithResponse，每往硬件写入一次数据就会调用一下代理方法
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil
        {
            print("发送数据失败！error信息:\(String(describing: error))")
        }else{
            print("发送数据成功！\(characteristic)")
        }
        
    }
    
    //订阅通知的回调
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        if error != nil
        {
            print("更改通知状态错误：\(String(describing: error?.localizedDescription))")
        }
        print("收到的特性数据：\(String(describing: characteristic.value))")
        
    }
    
    func power()
    {
        sendCommend(data: BLE.getPower())
    }
    func GetHardwareTime()
    {
        sendCommend(data: BLE.GetHardwareTime())
    }
    func setName()
    {
        sendCommend(data: BLE.SetName(name:"YEPE"))
    }
    // MARK: - 向盒子发送指令 -
    func sendCommend(data:[UInt8]) {
        let datas = Data.init(bytes: data)
        print("data :\(data)")
        if writeCharacteristic != nil {
              connectedPeripheral.writeValue(datas, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }else
        {
            print("你TM为什么是nil")
        }
      
       
    }






