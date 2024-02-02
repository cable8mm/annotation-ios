/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The application delegate.
*/

import Alamofire
import SwiftyJSON
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var isShowedIntroduce: Bool = false

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    //        {"code":0,"name":"Response Success","message":"Response Success","url":"\/os_picture_types.json","data":[{"OsPictureType":{"id":1,"name":"Chest X-ray","code":"CXR","is_polygon_type":true,"is_check_type":false,"is_active":true}},{"OsPictureType":{"id":2,"name":"Fundus Optics","code":"FOP","is_polygon_type":false,"is_check_type":true,"is_active":true}},{"OsPictureType":{"id":3,"name":"2D pathology(breast cancer)","code":"2DP","is_polygon_type":true,"is_check_type":false,"is_active":true}}]}

    AF.request(K.API_SERVER_PREFIX + "os_picture_types.json").responseJSON { response in
      switch response.result {
      case let .success(value):
        // decode
        //                guard let data = UserDefaults.standard.value(forKey: "UDRawPictureTypes") as? Data else { return }
        //                let json = JSON(data)

        let osPictureTypes = JSON(value)["data"]
        guard let rawPictureTypes = try? osPictureTypes.rawData() else { return }
        UserDefaults.standard.set(rawPictureTypes, forKey: "UDRawPictureTypes")

        for (_, osPictureType) in osPictureTypes {
          //                    {
          //                        "OsPictureType" : {
          //                            "is_active" : true,
          //                            "is_polygon_type" : true,
          //                            "name" : "Chest X-ray",
          //                            "id" : 1,
          //                            "code" : "CXR",
          //                            "is_check_type" : false
          //                        }
          //                    }
          print(osPictureType)
        }

        print(value)
        break
      case let .failure(error):
        print(error)
        break
      }
    }

    print(K.API_SERVER_PREFIX + "os_picture_labels.json")

    AF.request(K.API_SERVER_PREFIX + "os_picture_labels.json?os_picture_type_id=1").responseJSON {
      response in
      switch response.result {
      case let .success(value):
        // [{"OsPictureLabel":{"id":83,"os_picture_type_id":"2","name":"ROP||Total retinal detachment","is_polygon":true,"created":"2019-05-16 03:16:37"}},
        let osPictureLabels = JSON(value)["data"]
        guard let rawPictureLabels = try? osPictureLabels.rawData() else { return }
        UserDefaults.standard.set(rawPictureLabels, forKey: "UDRawPictureLabels1")
        break
      case let .failure(error):
        print(error)
        break
      }
    }

    AF.request(K.API_SERVER_PREFIX + "os_picture_labels.json?os_picture_type_id=2").responseJSON {
      response in
      switch response.result {
      case let .success(value):
        // [{"OsPictureLabel":{"id":83,"os_picture_type_id":"2","name":"ROP||Total retinal detachment","is_polygon":true,"created":"2019-05-16 03:16:37"}},
        let osPictureLabels = JSON(value)["data"]
        guard let rawPictureLabels = try? osPictureLabels.rawData() else { return }
        UserDefaults.standard.set(rawPictureLabels, forKey: "UDRawPictureLabels2")
        break
      case let .failure(error):
        print(error)
        break
      }
    }

    // 기기 등록
    guard let deviceId = UIDevice.current.identifierForVendor else {
      return true
    }
    let parameters = ["uuid": deviceId.uuidString]
    AF.request(K.API_SERVER_PREFIX + "os_app_users/add.json", method: .post, parameters: parameters)
      .responseJSON { response in
      }

    return true
  }
}
