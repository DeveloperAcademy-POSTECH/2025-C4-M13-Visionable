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
            
            let maxZoomFactor: CGFloat = 30
            videoDevice.videoZoomFactor = max(1.0, min(factor, maxZoomFactor))
            videoDevice.unlockForConfiguration()

            let zoomFactor = videoDevice.videoZoomFactor
            return zoomFactor
        } catch {
            print("Error setting zoom: \(error)")
        }
        return 2.0
    }
}
