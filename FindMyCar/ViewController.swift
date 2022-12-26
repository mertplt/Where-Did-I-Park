//
//  ViewController.swift
//  FindMyCar
//
//  Created by mert polat on 19.10.2022.
//

import UIKit
import VisionKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ResulttextView.layer.cornerRadius = 10
        entryTextView.layer.cornerRadius = 10
        
        let Text = defaults.object(forKey: "Text")
        ResulttextView.text = Text as? String
        
        let entryText = UserDefaults.standard.object(forKey: "entry")
        entryTextView.text = entryText as? String
         
    }
    
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    @IBOutlet weak var photo: UIImageView!
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        
        configurePicture()
        UserDefaults.standard.set(entryTextView.text, forKey: "entry")
        
    }

    @IBOutlet weak var entryTextView: UITextView!
    
    @IBOutlet weak var ResulttextView: UITextView!
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        UserDefaults.standard.set(entryTextView.text, forKey: "entry")
        
        defaults.set(ResulttextView.text, forKey: "Text")
        
    }
    
    
    @IBAction func resetButtonClicked(_ sender: UIBarButtonItem) {
        
        entryTextView.text = ""
        ResulttextView.text = ""
        
        UserDefaults.standard.removeObject(forKey: "entry")
        UserDefaults.standard.removeObject(forKey: "Text")
     
        
    }
    
    @IBAction func selectPhotoFromGalleryPressed(_ sender: UIButton) {
        
        UserDefaults.standard.set(entryTextView.text, forKey: "entry")
        
        setupGallery()
    }
    
    let defaults = UserDefaults.standard

    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    
    private func setupGallery(){
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = true
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker,animated: true,completion: nil)
        }
    }
    
    private func setupVisionTextRexognizeImage(image: UIImage?){
        
        var textString = ""
        request = VNRecognizeTextRequest(completionHandler: { request, error in
            
            guard let observations  = request.results as?[VNRecognizedTextObservation] else {
                fatalError("Recieved Invalid Observation")
            }
            
            for observation in observations{
             
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("No Candidate")
                    continue}
                
                textString += "\n\(topCandidate.string)"
                DispatchQueue.main.async { [self] in
                    ResulttextView.text = "Block: \(textString)"
                    defaults.set(ResulttextView.text, forKey: "Text")
                    print(textString)
                    
                    
                    
                }
            }
        })
        request.customWords = ["cutOm"]
        request.minimumTextHeight = 0.0315
        request.recognitionLevel = .accurate
        request.recognitionLanguages  = ["en_US"]
        request.usesLanguageCorrection = false
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image?.cgImage else{fatalError("Missing image to scan")}
            let handle = VNImageRequestHandler(cgImage: img,options: [:])
            try? handle.perform(requests)
        }
    }
    private func configurePicture(){
        
        let scanningDocumentVC = VNDocumentCameraViewController()
        scanningDocumentVC.delegate = self
        self.present(scanningDocumentVC, animated: true,completion: nil)
    }
}

extension ViewController: VNDocumentCameraViewControllerDelegate{
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        for pageNumber in 0..<scan.pageCount {
            
            let image = scan.imageOfPage(at: pageNumber)
            
            self.photo.image = image
            
            setupVisionTextRexognizeImage(image: image)

        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true,completion:nil)
        
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        self.photo.image = image
        
        setupVisionTextRexognizeImage(image: image)

    }
}
