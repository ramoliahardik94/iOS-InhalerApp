//
//  DeviceListManager.swift

import Foundation


class DeviceListManager: NSObject {
    static let shared = DeviceListManager()
   
    
   
    
    var deviceList: [DeviceModel] = []
    var deviceDetail: BehaviorRelay<DeviceModel> = BehaviorRelay(value: DeviceModel())
    var favDevice: BehaviorRelay<DeviceModel> = BehaviorRelay(value: DeviceModel())
    var sensorDeviceProperty: SensorEventModel?
    
    override init() {
        super.init()
        filterFavDevices()
    }
    
    //Filter Favourite devices for dashboard data
    private func filterFavDevices() {
        devices.rx_elements().subscribe(onNext: { list in
            self.deviceList = list
        })
        .disposed(by: disposeBag)
    }
        
    func getDeviceList(_ completion: ((APIResult) -> Void)? = nil) {
        deviceList.removeAll()
        devices.removeAll()
        isDeviceListRetrieved.accept(false)
        UIApplication.topViewController()!.view.showProgress()
        deviceListAPI { (_) in
            UIApplication.topViewController()!.view.hideProgress()
            completion?(.success(true))
        }
        sensorDevicePropertyAPI()
    }
    
    func deviceListAPI(_ completion: ((APIResult) -> Void)? = nil) {
        APIManager.shared.performRequest(route: APIRouter.deviceList(id: HubManager.shared.hubData.locationId ?? "").path, parameters: [:], method: .get) { (error, basicModel) in
            
            guard let basicModel = basicModel else {
                self.isDeviceListRetrieved.accept(true)
                completion?(.failure(error!.localizedDescription))
                return
            }

            if basicModel.checkStatusCode(.success) {
                let list = Mapper<DeviceModel>().mapArray(JSONArray: basicModel.dataArray)
                self.devices.elements.removeAll()//Remove data without observalbe events
                self.devices.append(contentsOf: list.filter({ $0.type != .keyfob }))
                self.isDeviceListRetrieved.accept(true)
            } else {
                self.isDeviceListRetrieved.accept(true)
            }
            completion?(.success(true))
        }
    }
    
    func sensorDevicePropertyAPI() {
        APIManager.shared.performRequest(route: APIRouter.senserDeviceProperty.path, parameters: [:], method: .get) { (_, basicModel) in
            if let basicModel = basicModel,
               basicModel.checkStatusCode(.success) {
                self.sensorDeviceProperty = Mapper<SensorEventModel>().map(JSON: basicModel.data)
            }
        }
    }
    
    func updateDevice(_ device: DeviceModel) {
        if let index = self.devices.firstIndex(where: { $0.deviceId == device.deviceId }) {
            self.devices[index] = device
        }
    }
}
