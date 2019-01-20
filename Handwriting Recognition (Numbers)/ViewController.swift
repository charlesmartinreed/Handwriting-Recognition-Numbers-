//
//  ViewController.swift
//  Handwriting Recognition (Numbers)
//
//  Created by Charles Martin Reed on 1/19/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var digitLabel: UILabel!
    
    //MARK:- Properties
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVisionForClassification()
    }
    
    //MARK:- Vision request methods
    func setupVisionForClassification() {
        //create a vision model from our coreML model
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else { fatalError("Failed to load Vision ML Model")}
        
        //create a classification request for your model
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
        self.requests = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        //from the observations, we can get a list of possible classifications discovered for our request
        //convert each object and adds it to the classification array, filtered by objects with a confidence level of above 80%, mapped to identifer strings
        
        let classifcations = observations
            .compactMap() { $0 as? VNClassificationObservation}
            .filter() { $0.confidence > 0.8 }
            .map() {$0.identifier}
        
        DispatchQueue.main.async {
            //update the user interface
            self.digitLabel.text = classifcations.first //the most accurate digit
        }
    }

    //MARK:- IBActions

    @IBAction func clearCanvas(_ sender: UIButton) {
        canvasView.clearCanvas()
    }
    
    @IBAction func beginHandwritingRecognition(_ sender: UIButton) {
        //begin the recognition process - results are better if we scale the image down and then input it
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        //now that we've got our scaled image, we can pass it to the request handler
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        //try performing that request
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    //MARK:- Image scaling function
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}

