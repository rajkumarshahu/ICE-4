//
//  ViewController.swift
//  ICE-4
//
//  Created by Raj Kumar Shahu on 2021-03-10.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var takePictureButton: UIButton!
    
    
    var avPlayerViewController: AVPlayerViewController!
    var image: UIImage?
    var movieURL: URL?
    var lastChosenMediaType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            takePictureButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDisplay()
    }
    
    @IBAction func shootPictureOrVideo(_ sender: UIButton) {
        pickMediaFromSource(.camera)
    }
    
    @IBAction func selectExistingPictureOrVideo(_ sender: UIButton) {
        pickMediaFromSource(.photoLibrary)
    }
    
    func pickMediaFromSource(_ sourceType:UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    func updateDisplay() {
        if let mediaType = lastChosenMediaType {
            if mediaType == (kUTTypeImage as NSString) as String {
                imageView.image = image!
                imageView.isHidden = false
                if avPlayerViewController != nil {
                    avPlayerViewController!.view.isHidden = true
                }
            } else if mediaType == (kUTTypeMovie as NSString) as String {
                if avPlayerViewController == nil {
                    avPlayerViewController = AVPlayerViewController()
                    let avPlayerView = avPlayerViewController!.view
                    avPlayerView?.frame = imageView.frame
                    avPlayerView?.clipsToBounds = true
                    view.addSubview(avPlayerView!)
                    setAVPlayerViewLayoutConstraints()
                }
                
                if let url = movieURL {
                    imageView.isHidden = true
                    avPlayerViewController.player = AVPlayer(url: url)
                    avPlayerViewController!.view.isHidden = false
                    avPlayerViewController!.player!.play()
                }
            }
        }
    }
    
    func setAVPlayerViewLayoutConstraints() {
        let avPlayerView = avPlayerViewController!.view
        avPlayerView?.translatesAutoresizingMaskIntoConstraints = false
        let views = ["avPlayerView": avPlayerView!,
                     "takePictureButton": takePictureButton!]
        view.addConstraints(NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|[avPlayerView]|", options: .alignAllLeft,
                                metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[avPlayerView]-0-[takePictureButton]",
                                options: .alignAllLeft, metrics:nil, views:views))
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        lastChosenMediaType = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? String

        if let mediaType = lastChosenMediaType {
            if mediaType == info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? String {
                image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
            } else if mediaType == info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedMovie")] as? String {

                movieURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? URL

            }
        }
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}


