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
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        self.videoDevice = videoDevice
    }
}
