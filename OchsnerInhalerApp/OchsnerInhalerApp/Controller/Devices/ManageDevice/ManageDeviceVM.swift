//
//  ManageDeviceVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 15/02/22.
//

import Foundation

class ManageDeviceVM {
    var arrDevice = [DeviceModel]()
    var arrRescue = [DeviceModel]()
    var arrMantainance = [DeviceModel]()
    func apicallForGetDeviceList(completionHandler: @escaping ((APIResult) -> Void)) {
        APIManager.shared.performRequest(route: APIRouter.device.path, parameters: [String: Any](), method: .get, isAuth: true, showLoader: false) {[weak self] error, response in
            guard let `self` = self else { return }
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [[String: Any]] {
                    self.arrDevice.removeAll()
                    for obj in res {                        
                        self.arrDevice.append(DeviceModel(jSon: obj))
                        let device = DeviceModel(jSon: obj)
                        if let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {BLEHelper.shared.newDeviceId == $0.discoveredPeripheral?.identifier.uuidString})  {
                            completionHandler(.success(true))
                            device.version = peripheral.version.trimmingCharacters(in: .controlCharacters)
                        }
                        DatabaseManager.share.saveDevice(object: device)
                    }
                    self.arrRescue = self.arrDevice.filter({$0.medTypeID == 1})
                    self.arrMantainance = self.arrDevice.filter({$0.medTypeID == 2})
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
    func apicallForRemoveDevice(index: Int, completionHandler: @escaping ((APIResult) -> Void)) {
        let param = ["internalId": arrDevice[index].internalID]
        APIManager.shared.performRequest(route: APIRouter.device.path, parameters: param, method: .delete, isAuth: true) {[weak self] error, response in
            guard let `self` = self else { return }
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                DatabaseManager.share.deleteMacAddress(macAddress: self.arrDevice[index].internalID)
                if let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.addressMAC == self.arrDevice[index].internalID}) {
                    BLEHelper.shared.cleanup(peripheral: (peripheral.discoveredPeripheral!))
                    BLEHelper.shared.connectedPeripheral.removeAll(where: {$0.addressMAC == self.arrDevice[index].internalID})
                }
                
                self.arrDevice.remove(at: index)
                self.arrRescue = self.arrDevice.filter({$0.medTypeID == 1})
                self.arrMantainance = self.arrDevice.filter({$0.medTypeID == 2})
                completionHandler(.success(true))
            }
        }
        
    }
}
