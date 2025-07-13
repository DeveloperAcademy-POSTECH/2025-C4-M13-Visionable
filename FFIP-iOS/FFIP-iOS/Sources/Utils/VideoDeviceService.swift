//
//  VideoDeviceService.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/9/25.
//

import AVFoundation

actor VideoDeviceService {
    private(set) var videoDevice: AVCaptureDevice?

    func fetchVideoDevice() {
        guard
            let videoDevice = AVCaptureDevice.default(
                .builtInDualWideCamera,
                for: .video,
                position: .back
            )
        else { return }
        self.videoDevice = videoDevice
    }

    func zoom(to factor: CGFloat) -> CGFloat {
        guard let videoDevice else { return 2.0 }
        do {
            try videoDevice.lockForConfiguration()
            defer { videoDevice.unlockForConfiguration() }

            let maxZoomFactor: CGFloat = 30
            videoDevice.videoZoomFactor = max(1.0, min(factor, maxZoomFactor))

            let zoomFactor = videoDevice.videoZoomFactor
            return zoomFactor
        } catch {
            print("Error setting zoom: \(error)")
        }
        return 2.0
    }

    func turnOnTorch() -> Bool {
        guard let videoDevice else { return false }
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.torchMode = .on
            videoDevice.unlockForConfiguration()
            return true
        } catch {
            print("Error setting flash mode: \(error)")
        }
        return false
    }

    func turnOffTorch() -> Bool {
        guard let videoDevice else { return true }
        do {
            try videoDevice.lockForConfiguration()
            defer { videoDevice.unlockForConfiguration() }
            videoDevice.torchMode = .off
            return false
        } catch {
            print("Error setting flash mode: \(error)")
        }
        return true
    }

    func focus(at point: CGPoint) {
        guard let videoDevice else { return }
        do {
            try videoDevice.lockForConfiguration()
            defer { videoDevice.unlockForConfiguration() }
            
            if videoDevice.isFocusPointOfInterestSupported {
                videoDevice.focusPointOfInterest = point
                videoDevice.focusMode = .autoFocus
            }
            if videoDevice.isExposurePointOfInterestSupported {
                videoDevice.exposurePointOfInterest = point
                videoDevice.exposureMode = .autoExpose
            }
        } catch {
            print("Error setting focus: \(error)")
        }
    }
}
