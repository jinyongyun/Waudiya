//
//  WriteCellViewController.swift
//  waudiya
//
//  Created by mac on 2022/08/06.
//


import UIKit
import MapKit

protocol WriteCellViewDelegate: AnyObject {
    func didSelectRegister(promise: Promise)
}


class WriteCellViewController: UIViewController {
    

    @IBOutlet weak var titlename: UITextField!
    
    @IBOutlet weak var detailcontent: UITextView!
    
    @IBOutlet weak var datetime: UITextField!
    
    @IBOutlet weak var locationtextfield: UITextField!
    
    @IBOutlet weak var storeButton: UIButton!
    
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    private var locationwhere: MKMapItem?
    weak var delegate: WriteCellViewDelegate?
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuredetailView()
        self.configureDatePicker()
        self.configureInputField()
        self.storeButton.isEnabled = false
    }
    
    @IBAction func locationRegisterButton(_ sender: UIButton) {
        guard let LocationSearchViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchViewController") as? LocationSearchViewController else {return}
       LocationSearchViewController.delegate = self
        present(LocationSearchViewController, animated: true, completion: nil)
        
    }
    
    
    private func configuredetailView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.detailcontent.layer.borderColor = borderColor.cgColor
        self.detailcontent.layer.borderWidth = 0.5
        self.detailcontent.layer.cornerRadius = 5.0
    }
    
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .inline
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko-KR")
        self.datetime.inputView = self.datePicker
    }
    
    private func configureInputField() {
        self.detailcontent.delegate = self
        self.titlename.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.datetime.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
        self.locationtextfield.addTarget(self, action: #selector(locationTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func tapStoreButton(_ sender: UIButton) {
        guard let title = self.titlename.text else { return }
        guard let detailcontent = self.detailcontent.text else { return }
        guard let date = self.diaryDate else { return }
        guard let location = self.locationwhere else { return }
        let promise = Promise(title: title, detailcontent: detailcontent, datetime: date, location: location, isStar: false)
        self.delegate?.didSelectRegister(promise: promise)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy 년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.datetime.text = formmater.string(from: datePicker.date)
        self.datetime.sendActions(for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField){
        self.validateInputField()
    }
    
    @objc private func locationTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    private func validateInputField(){
        self.storeButton.isEnabled = !(self.titlename.text?.isEmpty ?? true) && !(self.datetime.text?.isEmpty ?? true) && !(self.locationtextfield.text?.isEmpty ?? true) && !self.detailcontent.text.isEmpty
    }
}


extension WriteCellViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        self.validateInputField()
        
        
    }
    
    
}

extension WriteCellViewController: LocationSearchViewControllerDelegate {
    func sendData(location: MKMapItem) {
        locationwhere = location
        locationtextfield.text = location.name
    }
    
    
}
