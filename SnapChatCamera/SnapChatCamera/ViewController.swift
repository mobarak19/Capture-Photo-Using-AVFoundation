//
//  ViewController.swift
//  SnapChatCamera
//
//  Created by Mobarak on 5/23/22.
//
import AVFoundation
import UIKit

class ViewController: UIViewController {

    //sesson
    var session:AVCaptureSession?
    
    // photo output
    var output = AVCapturePhotoOutput()
    //preview layer
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    // shutter btn
    
    var shutterButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        btn.layer.cornerRadius = 50
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 10
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        checkCameraPermission()
        shutterButton.addTarget(self, action: #selector(didTappedBtn), for: .touchUpInside)
    }
    
    @objc func didTappedBtn(){
        

        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
    }

    func checkCameraPermission()  {
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .notDetermined:
            // request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {return}
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
        
    }
    
    func setUpCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.startRunning()
                self.session = session
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }

}


extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {return}
        session?.stopRunning()
        let image = UIImage(data: data)
        let imgV = UIImageView(image: image)
        imgV.contentMode = .scaleAspectFill
        imgV.frame = view.bounds
        view.addSubview(imgV)
    }
}
