//
//  LocationManager.swift
//  running-check
//
//  Created by mason on 11/19/24.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    @Published var thoroughfare: String? = nil         // 도로명
    @Published var subThoroughfare: String? = nil      // 도로 번호
    @Published var locality: String? = nil            // 시/군/구
    @Published var administrativeArea: String? = nil  // 도/광역시
    @Published var country: String? = nil             // 국가
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var errorMessage: String?
    
    private let manager = CLLocationManager()
    
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkAndRequestLocationPermission()
    }
    
    func checkAndRequestLocationPermission() {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "위치 서비스가 제한되어 있습니다. 설정에서 확인해주세요."
            }
        case .denied:
            DispatchQueue.main.async {
                self.errorMessage = "위치 서비스가 거부되었습니다. 설정 앱에서 권한을 변경해주세요."
            }
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        @unknown default:
            DispatchQueue.main.async {
                self.errorMessage = "알 수 없는 위치 권한 상태입니다."
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else { return }
            DispatchQueue.main.async {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.fetchAddress(from: location)
            }
        }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else {
//            DispatchQueue.main.async {
//                self.errorMessage = "위치 정보를 가져올 수 없습니다. 다시 시도해주세요."
//            }
//            return
//        }
//        
//        DispatchQueue.main.async {
//            self.latitude = location.coordinate.latitude
//            self.longitude = location.coordinate.longitude
//            self.fetchAddress(from: location)
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            switch (error as NSError).code {
            case CLError.denied.rawValue:
                self.errorMessage = "위치 서비스가 거부되었습니다. 설정 앱에서 권한을 변경해주세요."
            case CLError.locationUnknown.rawValue:
                self.errorMessage = "위치를 가져올 수 없습니다. 네트워크 상태를 확인해주세요."
            default:
                self.errorMessage = "위치 서비스를 가져오는 중 오류가 발생했습니다: \(error.localizedDescription)"
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationStatus = manager.authorizationStatus
            self.checkAndRequestLocationPermission()
        }
    }
    
    // 주소를 가져오는 메서드
    private func fetchAddress(from location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "주소를 가져오지 못했습니다: \(error.localizedDescription)"
                }
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    // 각 주소 요소를 별도로 저장
                    self.thoroughfare = placemark.thoroughfare             // 도로명
                    self.subThoroughfare = placemark.subThoroughfare       // 도로 번호
                    self.locality = placemark.locality                     // 시/군/구
                    self.administrativeArea = placemark.administrativeArea // 도/광역시
                    self.country = placemark.country                       // 국가
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "주소 정보를 찾을 수 없습니다."
                }
            }
        }
    }
}
