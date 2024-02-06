//
//  ConvertCurrencyViewController.swift
//  CurrencyConverter
//
//  Created by Usman Abid on 2024-2-06.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class ConvertCurrencyViewController: BaseViewController {
    
    
    @IBOutlet weak var fromTextField: PickerTextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toTextField: PickerTextField!
    
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var convertedCurrencyTextField: UITextField!
    @IBOutlet weak var inputCurrencyTextField: UITextField!
    
    
    var currencyConverterViewModel = ConvertCurrencyViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Currency Converter"
        self.detailsButton.setTitle(NSLocalizedString("DETAILS", comment: "Details"), for: .normal)
        self.detailsButton.isEnabled = false
        self.titleLabel.text = NSLocalizedString("CURRENCY_CONVERTER_TITLE", comment: "Currency Converter title")
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        self.titleLabel.adjustsFontForContentSizeCategory = true
        self.setupViewModelBindings()
        self.currencyConverterViewModel.getValidCurrencySymbols()
        
        self.inputCurrencyTextField.inputAccessoryView = toolBar()

        fromTextField.tintColor = .white

    }
    
    func toolBar() -> UIToolbar{
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("DONE_BUTTON_TITLE", comment: "Done"), style: .done, target: self, action: #selector(doneButtonPressed))
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("CANCEL_BUTTON_TITLE", comment: "Cancel"), style: .plain, target: self, action: #selector(cancelButtonPressed))
        doneButton.tintColor = .white
        cancelButton.tintColor = .white
        toolBar.setItems([cancelButton, space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }
    
    @objc func doneButtonPressed(){
        self.inputCurrencyTextField.endEditing(true)
    }

    @objc func cancelButtonPressed(){
        self.inputCurrencyTextField.endEditing(true)
    }
    
    func setupViewModelBindings() {
        
        currencyConverterViewModel.loading
            .bind(to: self.rx.isAnimating).disposed(by: disposeBag)
        currencyConverterViewModel.currencySymbols
        .observe(on: MainScheduler.instance)
        .bind(to: fromTextField.pickerItems)
        .disposed(by: disposeBag)

        currencyConverterViewModel.currencySymbols.observe(on: MainScheduler.instance)
            .bind(to: toTextField.pickerItems)
            .disposed(by: disposeBag)
        
        currencyConverterViewModel.convertedValue.observe(on: MainScheduler.instance)
            .bind(to: convertedCurrencyTextField.rx.text)
            .disposed(by: disposeBag)
        
        currencyConverterViewModel.convertedValue.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [ weak self ] value in
                guard let self = self else { return }
                self.detailsButton.isEnabled = true
            })
            .disposed(by: disposeBag)
        
        currencyConverterViewModel.currencySymbols.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
            self.callCurrencyConversionAPI()
                
            }).disposed(by: disposeBag)
        inputCurrencyTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext:{ [weak self] in
                guard let self = self else { return }
                self.callCurrencyConversionAPI()
            }).disposed(by: disposeBag)
        
        currencyConverterViewModel.error.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self ] error in
                guard let self = self else { return }
                self.parseNetworkError(error: error)
                
            }).disposed(by: disposeBag)
        
        fromTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.callCurrencyConversionAPI()
            }).disposed(by: disposeBag)
        
        toTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.callCurrencyConversionAPI()
            }).disposed(by: disposeBag)
        
        let _ = swapButton.rx.tap.bind {
            let temp = self.fromTextField.text
            self.fromTextField.text = self.toTextField.text
            self.toTextField.text = temp
            
            self.inputCurrencyTextField.text = "1"
            self.callCurrencyConversionAPI()
        }
        
        let _ = detailsButton.rx.tap.bind {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

            // Instantiate View Controller
            let viewController = storyboard.instantiateViewController(withIdentifier: "CurrencyDetailsViewController") as! CurrencyDetailsViewController
            viewController.fromCurrencyCode = self.fromTextField.text!
            viewController.fromCurrencyValue = self.inputCurrencyTextField.text!
            viewController.toCurrencyCode = self.toTextField.text!
            viewController.toCurrencyValue = self.convertedCurrencyTextField.text!

            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        
    }
    
    func callCurrencyConversionAPI() {
        currencyConverterViewModel.getConvertedCurrency(fromSymbol: fromTextField.text!, toSymbol: toTextField.text!, valueToConvert: inputCurrencyTextField.text!)
    }


}
