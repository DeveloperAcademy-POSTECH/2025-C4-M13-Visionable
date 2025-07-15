//
//  VideoCaptureService.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/9/25.
//

@preconcurrency import AVFoundation

actor VideoCaptureService {
    private var session: AVCaptureSession?
    private let queue = DispatchQueue(label: "sampleBufferQueue")

    func configureSession(
        device: AVCaptureDevice,
        delegate:
            AVCaptureVideoDataOutputSampleBufferDelegate
    ) {
        let session = AVCaptureSession()
        self.session = session

        guard let videoInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
            
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .standard
            }
        }
        videoOutput.setSampleBufferDelegate(delegate, queue: queue)

        session.startRunning()
    }

    func stopSession() {
        session?.stopRunning()
        session = nil
    }
}
