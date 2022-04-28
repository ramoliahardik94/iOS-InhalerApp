/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Transfer service and characteristics UUIDs
*/

import Foundation
import CoreBluetooth

struct TransferService {
    
    static let otaServiceUUID =  CBUUID(string: "0000d0ff-3c17-d293-8e48-14fe2e4da212")
    static let macCharecteristic = CBUUID(string: "FFD2")
    static let inhealerUTCservice = CBUUID(string: "00000ec2-3c17-d293-8e48-14fe2e4da212")
    static let characteristicNotifyUUID = CBUUID(string: "B004")
    static let characteristicAutoNotify = CBUUID(string: "B006")
    static let characteristicWriteUUID = CBUUID(string: "B002")
    static let addRTSStartByte = "AA015507"
    static let responseSuccessRTC = "aa:01:55:01:01"
    static let responseFailRTC = "aa:01:55:01:00"
    static let requestGetBattery = "AA025500"
    static let requestGetNoActuation = "AA035500"
    static let requestGetAcuationLog = "AA045500"
    static let serviceArray =  [inhealerUTCservice]
    
}
