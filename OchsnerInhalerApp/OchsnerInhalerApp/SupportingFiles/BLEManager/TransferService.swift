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
    
}
