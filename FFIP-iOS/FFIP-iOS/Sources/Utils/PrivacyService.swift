//
//  PrivacyService.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/9/25.
//

import AVFoundation
import Photos

actor PrivacyService {
    private(set) var camera: Bool = false
    private(set) var microphone: Bool = false
    private(set) var photoLibrary: Bool = false
    
    func fetchCameraAuthorization() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            camera = true
        case .notDetermined:
            camera = await AVCaptureDevice.requestAccess(for: .video)
        default:
            camera = false
        }
    }

    func fetchMicrophoneAuthorization() async {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            microphone = true
        case .notDetermined:
            microphone = await AVCaptureDevice.requestAccess(for: .audio)
        default:
            microphone = false
        }
    }
}
