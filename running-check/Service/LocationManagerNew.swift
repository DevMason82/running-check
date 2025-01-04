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
    private var debounceTimer: Timer?
    private var isFetching = false  // 요청 중복 방지 플래그

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkAndRequestLocationPermission()
    }

    func checkAndRequestLocationPermission() {
        let status = manager.authorizationStatus
        self.locationStatus = status

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
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            print("Updated Location: \(self.latitude), \(self.longitude)")
            
            // 디바운스 타이머 설정 (2초 내 중복 요청 방지)
            self.debounceTimer?.invalidate()  // 기존 타이머 취소
            self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.fetchAddress(from: location)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "위치를 가져오는 데 실패했습니다: \(error.localizedDescription)"
            print("Location error: \(error.localizedDescription)")
        }
    }

    private func fetchAddress(from location: CLLocation) {
        guard !isFetching else { return }  // 중복 요청 방지
        isFetching = true  // 요청 시작
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            self.isFetching = false  // 요청 완료
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "주소를 가져오지 못했습니다: \(error.localizedDescription)"
                }
                return
            }

            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.thoroughfare = placemark.thoroughfare
                    self.subThoroughfare = placemark.subThoroughfare
                    self.locality = placemark.locality
                    self.administrativeArea = placemark.administrativeArea
                    self.country = placemark.country
                    print("Address Fetched: \(self.fullAddress)")
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "주소 정보를 찾을 수 없습니다."
                }
            }
        }
    }

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
