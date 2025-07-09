//
//  VideoDeviceService.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/9/25.
//

import AVFoundation

actor VideoDeviceService {
    var videoDevice: AVCaptureDevice?
    
    func fetchVideoDevice() {
        videoDevice = AVCaptureDevice.default(for: .video)!
    }
}
