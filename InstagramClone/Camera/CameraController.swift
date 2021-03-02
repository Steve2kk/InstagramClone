//
//  CameraController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 27.02.2021.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDissmiss), for: .touchUpInside)
        return button
    }()
    
    let captureOutput = AVCapturePhotoOutput()
   
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnomationDismisser = CustomAnimationDismisser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        transitioningDelegate = self
        setupButtons()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupButtons() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 36, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        //setupInputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            let captureInput =  try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(captureInput) {
                captureSession.addInput(captureInput)
            }
        } catch let err {
            print("Could not setup cameraInput", err)
        }
        //setup outputs
     
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }
        //setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        //start running session
        captureSession.startRunning()
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func handleDissmiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {return}
        let previewImage = UIImage(data: imageData)
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnomationDismisser
    }
    
}
