//
//  ViewController.swift
//  WhatFlower
//
//  Created by Дмитрий Пономаренко on 15.07.22.
//

import UIKit
import CoreML
import Vision
import SDWebImage


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionFlower: UITextView!
    
    let imagePicker = UIImagePickerController()
    var flowerManager = FlowerManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        flowerManager.delegate = self
        descriptionFlower.text = ""
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(flowerImage: ciImage)
        }
        
        imageView.sd_setImage(with: URL(string: flowerManager.flowerImageURL))
        imagePicker.dismiss(animated: true)
        
    }
    
    func detect(flowerImage: CIImage)  {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Can't load MLmodel")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
           guard let result = request.results?.first as? VNClassificationObservation else {
            fatalError("Could not complete classfication")
            }
            self.navigationItem.title = result.identifier.capitalized
            let flower = result.identifier
            self.flowerManager.fetchFlower(flowerName: flower)
            
            
            
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true)
       
    }
    
    
}

extension ViewController: FlowerManagerDelegate {
    func didUpdateFlower(extract: String) {
        DispatchQueue.main.async {
            self.descriptionFlower.text = extract
            self.imageView.sd_setImage(with: URL(string: self.flowerManager.flowerImageURL))
            print(self.flowerManager.flowerImageURL)
        }
    }
    
   

    func didFailWithError(error: Error) {
        print(error)
    }


}
