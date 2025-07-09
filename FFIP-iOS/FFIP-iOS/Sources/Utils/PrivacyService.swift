//
//  PrivacyService.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/9/25.
//

import AVFoundation
import Photos

actor PrivacyService {
    var camera: Bool = false
    var microphone: Bool = false
    var photoLibrary: Bool = false
    
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

    func fetchPhotoLibraryAuthorization() async {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .authorized:
            photoLibrary = true
        case .notDetermined:
            let newStatus = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization { newStatus in
                    continuation.resume(returning: newStatus)
                }
            }
            photoLibrary = (newStatus == .authorized)
        default:
            photoLibrary = false
        }
    }
}
