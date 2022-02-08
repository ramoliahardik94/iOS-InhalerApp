/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Transfer service and characteristics UUIDs
*/

import Foundation
import CoreBluetooth

struct TransferService {
    static let otaServiceUUID = CBUUID(string: "0000D0FF-3C17-D293-8E48-14FE2E4DA212")
    static let macCharecteristic = CBUUID(string: "FFD2")
    
    static let inhealerUTCservice = CBUUID(string: "00000EC2-3C17-D293-8E48-14FE2E4DA212")
    static let characteristicNotifyUUID = CBUUID(string: "B004")
    static let characteristicWriteUUID = CBUUID(string: "B002")
    static let addRTSStartByte = "AA015507"
    static let responseSuccessRTC = "AA01550101"
    static let responseFailRTC = "AA01550100"
    static let requestGetBettery = "AA025500"
    static let requestGetNoAccuation = "AA035500"
    static let requestGetAcuationLog = "AA045500"
}
