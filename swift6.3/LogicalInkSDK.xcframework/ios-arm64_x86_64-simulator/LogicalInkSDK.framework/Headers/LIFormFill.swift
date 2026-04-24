//
//  LIFormFill.swift
//  logicalInk
//
//  Created by Mohanraj, Venkatesh on 1/29/16.
//  Copyright © 2016 BottomlineTechnolgies. All rights reserved.
//

import Foundation
import UIKit
internal import Reachability

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


/// SmartSetInfo
public class SmartSetInfo: CustomStringConvertible {
    open var name: String = "Unknown"
    open var forms: [FormInfo] = [FormInfo]()
    open var validationErrorCount: Int = 0
    open var validationTotalCount: Int = 0
    
    
    /// Gets a list of remaining validation Errors
    ///
    /// - Returns: an array of ValidationErrorInfo
    public func getValidationErrorsList() -> [ValidationErrorInfo] {
        var validationErrorsList = [ValidationErrorInfo]()
        for formInfo in forms {
            if let tPageInfos = formInfo.pages as? [LIPageInfo]{
                for pageInfo in tPageInfos {
                    validationErrorsList.append(contentsOf: pageInfo.validationErrors)
                }
            }
        }
        return validationErrorsList
    }
    
    /// Gets a list of all validations
    ///
    /// - Returns: an array of ValidationErrorInfo
    public func getvalidationChangesList() -> [ValidationErrorInfo] {
        var validationChangesList = [ValidationErrorInfo]()
        for formInfo in forms {
            if let tPageInfos = formInfo.pages as? [LIPageInfo]{
                for pageInfo in tPageInfos {
                    validationChangesList.append(contentsOf: pageInfo.validationChanges)
                }
            }
        }

        return validationChangesList
    }
    
    /// Prints out the smartset name, number of forms, and number of validation errors
    public  var description: String {
        var descriptionString =  "SmartSet name \(name) FormsCount \(forms.count) ValidationError count \(validationErrorCount) \n"
        for formInfo in forms {
            descriptionString += "\(formInfo)\n"
        }
        return descriptionString
    }
}


/// ValidationErrorInfo
public protocol ValidationErrorInfo: AnyObject, Decodable {
    var name: String? {get}
    var displayText: String {get}
    var pageNumber: Int {get}
    var oldState: String? {get set}
    var newState: String? {get set}
}


/// FormInfo
public protocol FormInfo: AnyObject, CustomStringConvertible {
    var name: String {get}
    var pageCount: Int {get}
    var pages: [PageInfo]? {get}
    var validationErrorCount: Int {get}
    var validationTotalCount: Int {get}
}


/// PageInfo
public protocol PageInfo: AnyObject, CustomStringConvertible {
    var name: String? {get}
    var pageNumber: Int? {get}
    var validationErrors: [LIValidationError] {get set}
    var validationChanges: [LIValidationError] {get set}
    var excludeFromFormFill: Bool? {get set}
    var excludeFromOutput: Bool? {get set}
}


/// ErrorInfo
public class ErrorInfo: NSObject {
    open var domain: String?
    open var code: NSInteger?
    open var userInfo: [String: String]?
}


/// FormFillDelegate
public protocol FormFillDelegate: AnyObject{
    
    /// Called when scrolling occurs, saying which page in which form was scrolled to
    ///
    /// - Parameters:
    ///   - pageOffset: integer
    ///   - inForm: FormInfo protocol with information on the form
    func didScrollTo(_ pageOffset:Int, inForm: FormInfo)
    
    /// Called when Form Fill finishes loading
    ///
    /// - Parameter smartSet: SmartSetInfo protocol with information on the smartset
    func formFillDidLoad(_ smartSet: SmartSetInfo)
    
    /// Called when the validation changes
    ///
    /// - Parameter smartSet: SmartSetInfo protocol with information on the smartset
    func onValidationChange(_ smartSet: SmartSetInfo)
    
    /// Called when an error occurs
    ///
    /// - Parameter errorInfo: ErrorInfo protocol with information on the error
    func onError(_ errorInfo: ErrorInfo)
    
    /// Called when all forms are saved
    ///
    /// - Parameter didSaveSuccessfully: a Bool denoting successful saving
    func formsSaved(_ didSaveSuccessfully: Bool)
    
    /// Called when a form is edited
    func formEdited()
}


/// FormPreference
public protocol FormPreference: AnyObject {
    
    /// Gets the URL for the server
    ///
    /// - Returns: String with the server URL
    func getServerUrl() -> String
    
    /// Gets the name of the Smartset
    ///
    /// - Returns: String with the Smartset name
    func getSmartSetName() -> String?
    
    /// Gets the Language
    ///
    /// - Returns: String with name of the language
    func getLanguageName() -> String?
    
    /// Gets the selected forms
    ///
    /// - Returns: An array of form names as Strings
    func getSelectedForms() -> [String]?
}


/// FacilityUserInfo
public protocol FacilityUserInfo: AnyObject {
    
    /// Gets the username for the current user
    ///
    /// - Returns: String with username
    func getUserName() -> String
    
    /// Gets the password for the current user
    ///
    /// - Returns: String with password
    func getPassword() -> String
}


/// PatientUserInfo
public protocol PatientUserInfo {
    
    /// Gets the Patient ID
    ///
    /// - Returns: Int with Patient ID
    func getPatientID() -> Int
    
    /// Gets the Patient Account Number
    ///
    /// - Returns: String with Patient Account Number
    func getPatientAccountNumber() -> String
    
    /// Gets the Patient MRN
    ///
    /// - Returns: String with Patient MRN
    func getPatientMRNNumber() -> String
}

public typealias completionBlock = (_ success: Bool) -> Void


/// LIFormFill Class
public class LIFormFill : NSObject, LIFormContainerDelegate {
    weak public var fillDelegate: FormFillDelegate?
    weak public var formPreference: FormPreference?
    weak public var facilityUser: FacilityUserInfo?
    weak public var formContainer: LIFormContainer?
    public var user: LIUser?
    public var patient: LIPatient?
    public var serverInfo: LIServerInfo?
    public var policy: LIPolicy?
    public var patientID = "" // without data
    public var gesturesEnabled : Bool = true
    public let languageServices: LILanguageServices = LILanguageServices()
    
    /// Initializes a Formfill instance
    ///
    /// - Parameters:
    ///   - tformPreference: FormPreference protocol
    ///   - tfacilityUser: FacilityUserInfo protocol
    ///   - completion: completionBlock
    public func initFor(_ tformPreference: FormPreference, tfacilityUser: FacilityUserInfo, completion: @escaping completionBlock) {
        formPreference = tformPreference
        facilityUser = tfacilityUser
        weak var this = self
        LINetworkManager.serverUrl = tformPreference.getServerUrl()
        LINetworkManager.sharedInstance.getServerInfoForFacility() {
            (result: AnyObject?, success: Bool) in
            
            let serverInfo = result as? LIServerInfo
            this?.policy = serverInfo?.policy
            LISessionInfo.sharedInstance.autoSavePeriodSeconds = this?.policy?.autoSavePeriodSeconds
            
            if this?.policy?.loggingLevel == "debug" {
                fileDestination.outputLevel = .debug
            }
            else {
                fileDestination.outputLevel = .info
            }
            
            logProd.debug("SDK - logginglevel: \(String(describing: this?.policy?.loggingLevel))")
            logProd.debug("SDK - outputLevel: \(fileDestination.outputLevel)")
            
            if (!success) {
                if let errorDict = result as? Dictionary<String, String> {
                    logDev.error("Error occurred while getting server info: \(String(describing: errorDict["Error"]))")
                }
                // todo
                completion(false)
//                return
            }
                
            LINetworkManager.sharedInstance.loginUser(tfacilityUser.getUserName(), password: tfacilityUser.getPassword()) {
                    (result2: AnyObject?, success2: Bool) in
                    
                    if (!success2) {
                        if let errorDict = result as? Dictionary<String, String> {
                            logDev.error("Error occurred while logging in user: \(String(describing: errorDict["Error"]))")
                        }
                        // todo
                        completion(false)
//                        return
                    }
                    this?.user = result2 as? LIUser
                        
                    if this?.user?.defaultLocationID == nil {
                        this?.user?.defaultLocationID = 0
                    }
                
                
                
                    LINetworkManager.sharedInstance.getUserPermissions() {
                        (result: AnyObject?, success: Bool) in
                        
                        if let userPermissions = result as? LIPermissions {
                            this?.user?.permissions = userPermissions
                        }
                        
                        LISessionInfo.sharedInstance.currentUser = this?.user
                        completion(true)
                    }
                }
            }
    }
    
    
    /// Creates a Formfill view and returns it to the caller
    ///
    /// - Parameters:
    ///   - patientUserInfo: Contains patient info, defined by the PatientUserInfo protocol
    ///   - formDelegate: Contains form delegate info, defined by the FormFillDelegate protocol
    ///   - viewSize: Contains the size of the form fill view
    /// - Returns: a UIView created from the parameters
    public func getFormFillViewFor(_ patientUserInfo: PatientUserInfo, formDelegate: FormFillDelegate, viewSize: CGSize, _ revision: Int? = nil, _ status: String? = nil) -> UIView {
        fillDelegate = formDelegate
        let rect = CGRect(origin: CGPoint(x:0, y:0), size: viewSize)
//        let ret = LIFormContainer(frame: rect, formContDelegate: self)
        let formContainer = LIFormContainer(frame: rect, formContDelegate: self)
        formContainer.gesturesEnabled = gesturesEnabled
        weak var this = self
        
        // Error out if server is not set correctly
        print("serverUrl2 - \(LINetworkManager.serverUrl)")
        if LINetworkManager.serverUrl == "" {
            let error = ErrorInfo()
            error.code = 1
            error.domain = "serverError"
            
            var errorDict = Dictionary<String, String>()
            errorDict["type"] = "Server Error"
            errorDict["message"] = "The server URL you entered is incorrect."
            
            error.userInfo = errorDict
            this!.fillDelegate?.onError(error)
            return formContainer
        }
        
        // Error out if user does not login correctly
        if this?.user == nil {
            let error = ErrorInfo()
            error.code = 1
            error.domain = "loginError"
            
            var errorDict = Dictionary<String, String>()
            errorDict["type"] = "Login Error"
            errorDict["message"] = "The username or password you entered is incorrect."
            
            error.userInfo = errorDict
            this!.fillDelegate?.onError(error)
            return formContainer
        }
        LISessionInfo.sharedInstance.currentUser = this?.user
        LINetworkManager.sharedInstance.searchPatientFromAccountNumber(patientUserInfo.getPatientAccountNumber(), location: 0, formStatus: "", filterOperator: "", emailStatus: "") {
            (result4: AnyObject?, success4: Bool) in
            if (!handleIfFailure(result4, success: success4, completionCallback: nil)) {
                return
            }
            let resultArray = try? JSONDecoder().decode([LIPatient].self, from: result4 as! Data)
            
            if resultArray?.count == 0 {
                let error = ErrorInfo()
                error.code = 1
                error.domain = "patientNotFound"
                
                var errorDict = Dictionary<String, String>()
                errorDict["type"] = "Patient Not Found"
                errorDict["message"] = "Please try your search again."
                
                error.userInfo = errorDict
                this!.fillDelegate?.onError(error)
                return
            }
            
            let patientID = patientUserInfo.getPatientID()
            let patientAcct = patientUserInfo.getPatientAccountNumber()
            let patientMRN = patientUserInfo.getPatientMRNNumber()
            
            for patient in resultArray! {
                if patient.id == patientID {
                    this?.patient = patient
                    break
                }
            }
            
            if this?.patient == nil {
                for patient in resultArray! {
                    if patient.accountNumber == patientAcct {
                        if (this?.policy?.evaluateMRNOnLaunch != nil && (this?.policy?.evaluateMRNOnLaunch)!) {
                            if patient.mrn?.caseInsensitiveCompare(patientMRN) == .orderedSame {
                                this?.patient = patient
                                break
                            }
                        }
                        else {
                            this?.patient = patient
                            break
                        }
                    }
                }
                if this?.patient == nil {
                    let error = ErrorInfo()
                    error.code = 1
                    error.domain = "patientNotFound"
                    
                    var errorDict = Dictionary<String, String>()
                    errorDict["type"] = "Patient Not Found"
                    errorDict["message"] = "Please try your search again."
                    
                    error.userInfo = errorDict
                    this!.fillDelegate?.onError(error)
                    return
                }
            }
            
            LISessionInfo.sharedInstance.patient = self.patient
            
            let application = LISessionInfo.sharedInstance.currentUser?.getApplicationByName((this?.formPreference?.getSmartSetName())!)
            if application == nil {
                let error = ErrorInfo()
                error.code = 1
                error.domain = "smartSetNotFound"
                
                var errorDict = Dictionary<String, String>()
                errorDict["type"] = "SmartSet Not Found"
                errorDict["message"] = "Please check permissions and SmartSet name."
                
                error.userInfo = errorDict
                this!.fillDelegate?.onError(error)
                return
            }
            else {
                if LISessionInfo.sharedInstance.currentSmartset == nil {
                    LISessionInfo.sharedInstance.currentSmartset = application
                }
            }

            let smartSetId = String(describing: application!.id!)

            LINetworkManager.sharedInstance.getLanguagesInfo(visitID: "\((this?.patient!.id)!)", smartsetID: smartSetId) {
                (result6: AnyObject?, success6: Bool) in
                if (!handleIfFailure(result6, success: success6, completionCallback: nil)) {
                    return
                }
                this?.languageServices.loadLanguages(result6)
                var language: LILanguageModel? = nil
                if let langName = this?.formPreference?.getLanguageName() {
                    language = this?.languageServices.getLanguageByName(langName)
                } else {
                    language = this?.languageServices.defaultLanguage
                }
                
                weak var this = self
                LINetworkManager.sharedInstance.getFormsInfoForApplication((this?.patient?.id)!, smartSetID: (application?.id)!, languageID: (language?.id)!, orderID: String(), revision: revision != nil ? revision! : nil) {
                    (result8: AnyObject?, success8: Bool) in
                    if (!handleIfFailure(result8, success: success8, completionCallback: nil)) {
                        return
                    }
                    if let selectableForms = result8 as? LISelectableForms {
                        if let formModels = selectableForms.forms {
                            var formList = [[String: AnyObject]]()
                            var selForms = [LIFormModel]()
                            
                            
                            for formModel in formModels {
                                if status != nil {
                                    formModel.formStatus = status
                                }
                            }
                            
                            // autopop overrides standard behavior
                            // if autopop contains selectedForms (encounter level), add only those forms to selForms
                            let selectedForms = this?.formPreference?.getSelectedForms()
                            if selectedForms?[0] != "" {
                                for formModel in formModels {
                                    var formDict = [String: AnyObject]()
                                    if formModel.displayName != nil {
                                        if (selectedForms!.contains(formModel.displayName!)) {
                                            formDict["templateId"] = formModel.templateId as AnyObject
                                            formDict["orderId"] = (Int(formModel.orderId!) > 0 ? formModel.orderId! as AnyObject : NSNull()) as AnyObject
                                            formList.append(formDict)
                                            selForms.append(formModel)
                                        }
                                    }
                                }
                            }
                            else {
                                // standard behavior
                                for formModel in formModels {
                                    var formDict = [String: AnyObject]()
                                    
                                    if status != nil {
                                        formModel.formStatus = status
                                    }
                                    
                                    if formModel.selectionMode != nil && formModel.order != nil {
//                                        print("formModel: \(formModel.name) - \(formModel.selectionMode!) - \(formModel.order!) - \(formModel.isSelectedBool())")
                                    }
                                    if formModel.order == nil && formModel.isSelectedBool() {
                                        // mandatory
                                        if (formModel.selectionMode == "mandatory") || (formModel.selectionMode == "conditionallyMandatory") {
                                            formDict["templateId"] = formModel.templateId as AnyObject
                                            formDict["orderId"] = (Int(formModel.orderId!) > 0 ? formModel.orderId! as AnyObject : NSNull()) as AnyObject
                                            formList.append(formDict)
                                            selForms.append(formModel)
                                        }
                                        // conditonallyVisible
                                        if formModel.selectionMode == "conditionallyVisible" {
                                            formDict["templateId"] = formModel.templateId as AnyObject
                                            formDict["orderId"] = (Int(formModel.orderId!) > 0 ? formModel.orderId! as AnyObject : NSNull()) as AnyObject
                                            formList.append(formDict)
                                            selForms.append(formModel)
                                        }
                                        // conditonal
                                        if formModel.selectionMode == "conditional" {
                                            formDict["templateId"] = formModel.templateId as AnyObject
                                            formDict["orderId"] = (Int(formModel.orderId!) > 0 ? formModel.orderId! as AnyObject : NSNull()) as AnyObject
                                            formList.append(formDict)
                                            selForms.append(formModel)
                                        }
                                        // selected
                                        if formModel.selectionMode == "selected" {
                                            formDict["templateId"] = formModel.templateId as AnyObject
                                            formDict["orderId"] = (Int(formModel.orderId!) > 0 ? formModel.orderId! as AnyObject : NSNull()) as AnyObject
                                            formList.append(formDict)
                                            selForms.append(formModel)
                                        }
                                    }
                                }
                            }
                            if selForms.count == 0 {
                                let error = ErrorInfo()
                                error.code = 1
                                error.domain = "noFormsSelected"
                                
                                var errorDict = Dictionary<String, String>()
                                errorDict["type"] = "No Forms Selected"
                                errorDict["message"] = "Please make forms selected and available."
                                
                                error.userInfo = errorDict
                                this!.fillDelegate?.onError(error)
                                return
                            }
                            var applicationName = "Unknown"
                            if let inAppName = application?.name {
                                applicationName = inAppName
                            }
                            logDev.info("calling updateFormModels")
                            logProd.info("calling updateFormModels")
                            
                            // Need to sort based on Admin sortOrder setting before loading Form Fill
                            selForms = selForms.sorted(by: { $0.sortOrder! < $1.sortOrder!})
                            
                            formContainer.updateFormModels(selForms, smartsetName: applicationName, revision: revision)
                            
                            LINetworkManager.sharedInstance.packetCreate((this?.patient!.id)!, smartsetID: application!.id!, forms: formList as AnyObject, state: "Filling") {
                                    (result7: AnyObject?, success7: Bool) in
                                    if (!handleIfFailure(result7, success: success7, completionCallback: nil)) {
                                        return
                                    }
                                
                                    logDev.info("result: \(String(describing: result7))")
                                    logDev.info("success: \(success7)")
                                    logProd.info("success: \(success7)")
                                    logProd.info("result: \(String(describing: result7))")
                                
                                    formContainer.packetId = result7?["id"] as! Int
                            }
                        }
                    }
                }
            }
        }
        self.formContainer = formContainer
        return formContainer
    }

    
    /// Called when scrolling occurs
    ///
    /// - Parameters:
    ///   - pageIndex: integer
    ///   - inForm: FormInfo protocol with information on the form
    public func scrollTo(_ pageIndex: Int, inForm: FormInfo) {
        //@todo
        if let formModel = inForm as? LIFormModel{
            formContainer?.pauseAVPlayers()
            formContainer?.scrollTo(formModel, inFormPageIndex: pageIndex)
        }
    }
    
    /// Called when scrolling occurs
    ///
    /// - Parameters:
    ///   - pageIndex: integer
    ///   - inForm: FormInfo protocol with information on the form
    ///   - fieldName : selected field item name
    public func scrollTo(_ pageIndex: Int, inForm: FormInfo, error: LIValidationError?) {
        //@todo
        if let formModel = inForm as? LIFormModel{
            formContainer?.pauseAVPlayers()
            formContainer?.scrollTo(formModel, inFormPageIndex: pageIndex, error: error)
        }
    }
    
    /// Scrolls to the next page and sends a notification
    public func scrollToNextPage() {
        formContainer?.scrollToNextPage()
    }
    
    
    /// Scrolls to the previous page and sends a notification
    public func scrollToPreviousPage() {
        formContainer?.scrollToPreviousPage()
    }
    
    
    /// Saves the form and sends a notification
    public func saveForm() {
//        formContainer?.save()
        formContainer?.saveSynchronously(index: 1)
    }
    
    
    /// Uploads all logs and sends a notification
    ///
    /// - Parameter completion: completionBlock
    public func uploadLogs(_ completion: @escaping completionBlock) {
        uploadLogFiles(Array()) {
            (result: AnyObject?, success: Bool) in
            completion(success)
        }
    }
    
    
    /// Cancels any current activity and sends a notification
    public func cancel() {
//todo
    }
    
    
    /// Checks whether there is an internet connection
    ///
    /// - Parameter server: String with server URL
    /// - Returns: Bool saying whether connection is successful
    public func isConnected(_ server: String?) -> Bool {
        if server != nil {
            do {
                let reachability = try Reachability(hostname: server!)
                if reachability.connection != .unavailable {
                    return true
                }
            }
            catch {}
        }
        
        let error = ErrorInfo()
        error.code = 1
        error.domain = "networkUnreachable"
        fillDelegate?.onError(error)
        
        return false
    }
   
    
    /// Moves the view to the validation error selected
    ///
    /// - Parameter validationError: The ValidationErrorInfo protocol
    public func gotoValidationError(_ validationError: ValidationErrorInfo) {
//todo        formContainer.scr
    }
    
    // LIFormContainerDelegate
    
    
    /// Called when scrolling occurs
    ///
    /// - Parameters:
    ///   - containerPageIndex: integer
    ///   - totalPages: integer representing the total number of pages
    ///   - formPageIndex: integer representing the page index
    ///   - formModel: LIFormModel model
    open func didScrollTo(pageIndex containerPageIndex: Int, totalPages: Int, formPageIndex: Int, formModel: LIFormModel) {
        logDev.info("Did scroll to \(containerPageIndex) / \(totalPages) Form index \(formPageIndex)  form name = \(formModel.name)")
        formContainer?.pauseAVPlayers()
        fillDelegate?.didScrollTo(formPageIndex, inForm: formModel)
    }
    
    
    /// Called when the forms have loaded
    open func formsDidLoad() {
        if let tFormContainer = formContainer {
            fillDelegate?.formFillDidLoad(tFormContainer.getSmartSetInfo())
        }
    }
    
    
    /// Called when there is a form load error
    ///
    /// - Parameter error: An error object
    public func formLoadError(_ error: AnyObject?) {
        
    }
    
    /// Called when the validation changes
    ///
    /// - Parameter smartSetInfo: SmartSetInfo protocol
    open func onValidationChange(_ smartSetInfo: SmartSetInfo) {
        fillDelegate?.onValidationChange(smartSetInfo)
    }
    
    
    /// Called when a form is saved and sends a notification
    open func onFormSaved(_ didSaveSuccessfully: Bool) {
        fillDelegate?.formsSaved(true)
    }
    
    
    /// Called when a form save failed and sends a notification
    open func onFormSaveFailed() {
        fillDelegate?.formsSaved(false)
    }
    
    
    /// Called when a form is edited and sends a notification
    open func onFormEdited() {
        fillDelegate?.formEdited()
    }
}
