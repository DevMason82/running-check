//
//  LocationManagerNew.swift
//  running-check
//
//  Created by mason on 11/25/24.
//

import CoreLocation
import Foundation

class LocationManagerNew: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var locationStatus: CLAuthorizationStatus? = nil
    @Published var errorMessage: String? = nil

    @Published var thoroughfare: String? = nil         // 도로명
    @Published var subThoroughfare: String? = nil      // 도로 번호
    @Published var locality: String? = nil            // 시/군/구
    @Published var administrativeArea: String? = nil  // 도/광역시
    @Published var country: String? = nil             // 국가

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // 위치 정확도 설정
        checkAndRequestLocationPermission()
    }

    func checkAndRequestLocationPermission() {
        let status = manager.authorizationStatus
        self.locationStatus = status // 현재 권한 상태 저장

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.errorMessage = "위치 서비스가 제한되었거나 비활성화되었습니다. 설정에서 권한을 활성화해주세요."
            }
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        @unknown default:
            DispatchQueue.main.async {
                self.errorMessage = "알 수 없는 권한 상태입니다."
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationStatus = status
            self.checkAndRequestLocationPermission()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } // 최신 위치 가져오기
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            print("Updated Location: \(self.latitude), \(self.longitude)")

            // 위치 업데이트 후 주소 가져오기
            self.fetchAddress(from: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "위치를 가져오는 데 실패했습니다: \(error.localizedDescription)"
            print("Location error: \(error.localizedDescription)")
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
                    print("Address Fetched: \(self.fullAddress)")
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "주소 정보를 찾을 수 없습니다."
                }
            }
        }
    }

    // 전체 주소를 문자열로 반환
    var fullAddress: String {
        [
            thoroughfare,
            subThoroughfare,
            locality,
            administrativeArea,
            country
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}
