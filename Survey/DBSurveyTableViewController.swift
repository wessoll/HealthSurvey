//
//  DBSurveyTableViewController.swift
//  Survey
//
//  Created by Wesley Scheper on 05/12/15.
//  Copyright © 2015 Wesley Scheper. All rights reserved.
//

import UIKit
import ResearchKit

class DBSurveyTableViewController: UITableViewController, ORKTaskViewControllerDelegate {

    let DBSurveyTableViewControllerCellMorningSurvey = 0
    let DBSurveyTableViewControllerCellEveningSurvey = 1
    
    let DBSurveyTypeIdentifier = "type"
    let DBSurveyDateAndTimeIdentifier = "created"
    let DBSurveyWeightIdentifier = "weight"
    let DBSurveyBodyWeightIdentifier = "body_weight_kg"
    let DBSurveyBodyFatIdentifier = "body_fat_percent"
    let DBSurveyMoodIdentifier = "mood"
    let DBSurveyHeartIdentifier = "heart"
    let DBSurveyHeartRateIdentifier = "heart_rate_bpm"
    let DBSurveyBloodPressureSystolicIdentifier = "blood_pressure_systolic_mmhg"
    let DBSurveyBloodPressureDiastrolicIdentifier = "blood_pressure_diastolic_mmhg"
    let DBSurveyAlcoholIdentifier = "alcohol"
    let DBSurveyAlcoholConsumptionIdentifier = "alcohol_consumption"
    let DBSurveyActivityIdentifier = "activity"
    let DBSurveyStepCountIdentifier = "step_count"
    let DBSurveyWorkoutIdentifier = "workout"
    let DBSurveySleepIdentifier = "sleep"
    let DBSurveySleepStartIdentifier = "sleep_start"
    let DBSurveySleepEndIdentifier = "sleep_end"
    let DBSurveySleepHoursIdentifier = "sleep_hours"
    let DBSurveySleepScoreIdentifier = "sleep_score"
    let DBSurveyStressIdentifier = "stress"
    let DBSurveyWaitIdentifier = "wait"
    let DBSurveyFrontBodyImageIdentifier = "front_body_image"
    let DBSurveySideBodyImageIdentifier = "side_body_image"
    let DBSurveyBackBodyImageIdentifier = "back_body_image"
    let DBSurveyAppVersion = "app_version"
    
    let DBSurveyAPIURL = "http://10.2.1.1:5984/health_data/"
    
    var selectedSurvey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var steps: Array<ORKStep> = Array()
        
        if indexPath.row == DBSurveyTableViewControllerCellMorningSurvey {
            selectedSurvey = "morning"
            steps = [moodStep(), stressStep(), sleepStep(), bodyWeightAndFatPercentageStep()]
        } else if indexPath.row == DBSurveyTableViewControllerCellEveningSurvey {
            selectedSurvey = "morning"
            steps = [moodStep(), stressStep(), alcoholConsumptionStep(), activityStep(), bloodPressureAndHeartRateStep()]
        }
        
        let task = ORKOrderedTask(identifier: "task", steps: steps)
        
        let taskViewController = ORKTaskViewController(task: task, taskRunUUID: nil)
        taskViewController.delegate = self
        taskViewController.outputDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        presentViewController(taskViewController, animated: true, completion: nil)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // MARK: ORTaskViewController Delegate
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason,
        error: NSError?) {
            
            if reason == .Completed {
                var results = resultsFromTaskViewController(taskViewController.result)
                results[DBSurveyDateAndTimeIdentifier] = NSDate().dateString()
                results[DBSurveyTypeIdentifier] = self.selectedSurvey
                results[DBSurveyAppVersion] = "1.1"
                
                // @TODO include hash from the collected values, so we can ensure the data has not been edited
                
                print(results)
                
                // Send results
                let requestURL = NSURL(string: DBSurveyAPIURL + NSUUID().UUIDString)!
                
                let request = NSMutableURLRequest(URL: requestURL)
                request.HTTPMethod = "PUT"
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(results, options: NSJSONWritingOptions.PrettyPrinted)
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alert = UIAlertController(title: (error != nil ? "Failed" : "Success"), message: (error != nil ? "Could not transmit survey" : "Survey successfully transmitted"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                })
                task.resume()
            }
            
            // Then, dismiss the task view controller.
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    // Creates an Dictionary with the results of the survey
    // @TODO: refactor this to a more abstract approach
    func resultsFromTaskViewController(taskResult: ORKTaskResult) -> Dictionary<String, String>{
        var results: Dictionary<String, String> = Dictionary<String, String>()
        
        for result in taskResult.results! {
            if result.identifier == DBSurveyMoodIdentifier {
                let stepResult = result as! ORKStepResult
                let choiceQuestionResult = stepResult.results?.first as! ORKChoiceQuestionResult
                
                results[DBSurveyMoodIdentifier] = choiceQuestionResult.choiceAnswers?.first as? String
            } else if result.identifier == DBSurveyStressIdentifier {
                let stepResult = result as! ORKStepResult
                let choiceQuestionResult = stepResult.results?.first as! ORKChoiceQuestionResult
                
                results[DBSurveyStressIdentifier] = choiceQuestionResult.choiceAnswers?.first as? String
            } else if result.identifier == DBSurveyWeightIdentifier {
                let stepResult = result as! ORKStepResult
                
                for stepSubResult in stepResult.results! {
                    if stepSubResult.identifier == DBSurveyBodyWeightIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveyBodyWeightIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    } else if stepSubResult.identifier == DBSurveyBodyFatIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveyBodyFatIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    }
                }
            } else if result.identifier == DBSurveyAlcoholIdentifier {
                let stepResult = result as! ORKStepResult
                let booleanQuestionResult = stepResult.results?.first as! ORKBooleanQuestionResult
                
                results[DBSurveyAlcoholConsumptionIdentifier] = booleanQuestionResult.answer != nil ? String(booleanQuestionResult.answer!) : nil
            } else if result.identifier == DBSurveyHeartIdentifier {
                let stepResult = result as! ORKStepResult
                
                for stepSubResult in stepResult.results! {
                    if stepSubResult.identifier == DBSurveyHeartRateIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveyHeartRateIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    } else if stepSubResult.identifier == DBSurveyBloodPressureSystolicIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveyBloodPressureSystolicIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    } else if stepSubResult.identifier == DBSurveyBloodPressureDiastrolicIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveyBloodPressureDiastrolicIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil                    }
                }
            } else if result.identifier == DBSurveyActivityIdentifier {
                let stepResult = result as! ORKStepResult
                
                for stepSubResult in stepResult.results! {
                    if stepSubResult.identifier == DBSurveyStepCountIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveyStepCountIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    } else if stepSubResult.identifier == DBSurveyWorkoutIdentifier {
                        let booleanQuestionResult = stepSubResult as! ORKBooleanQuestionResult
                        
                        results[DBSurveyWorkoutIdentifier] = booleanQuestionResult.answer != nil ? String(booleanQuestionResult.answer!) : nil
                    }
                }
            } else if result.identifier == DBSurveySleepIdentifier {
                let stepResult = result as! ORKStepResult
                
                for stepSubResult in stepResult.results! {
                    if stepSubResult.identifier == DBSurveySleepStartIdentifier {
                        let timeOfDayQuestionResult = stepSubResult as! ORKTimeOfDayQuestionResult
                        let dateTimeComponents = timeOfDayQuestionResult.answer as? NSDateComponents
                        
                        results[DBSurveySleepStartIdentifier] = dateTimeComponents != nil ? dateTimeComponents!.simpleDateString() : nil
                    } else if stepSubResult.identifier == DBSurveySleepEndIdentifier {
                        let timeOfDayQuestionResult = stepSubResult as! ORKTimeOfDayQuestionResult
                        let dateTimeComponents = timeOfDayQuestionResult.answer as? NSDateComponents
                        
                        results[DBSurveySleepEndIdentifier] = dateTimeComponents != nil ? dateTimeComponents!.simpleDateString() : nil
                    } else if stepSubResult.identifier == DBSurveySleepHoursIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveySleepHoursIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    } else if stepSubResult.identifier == DBSurveySleepScoreIdentifier {
                        let numericQuestionResult = stepSubResult as! ORKNumericQuestionResult
                        
                        results[DBSurveySleepScoreIdentifier] = numericQuestionResult.answer != nil ? String(numericQuestionResult.answer!) : nil
                    }
                }
            }
        }
        return results
    }
    
    // MARK: Reusable components
    
    // Mood question
    func moodStep() -> ORKQuestionStep {
        let imageChoiceAwesome = ORKImageChoice(normalImage: UIImage(named: "grinning-face"), selectedImage: UIImage(named: "grinning-face"), text: "Awesome", value: "awesome")
        let imageChoiceOk = ORKImageChoice(normalImage: UIImage(named: "grimacing-face"), selectedImage: UIImage(named: "grimacing-face"), text: "Ok", value: "ok")
        let imageChoiceBad = ORKImageChoice(normalImage: UIImage(named: "expressionless-face"), selectedImage: UIImage(named: "expressionless-face"), text: "Bad", value: "bad")
        let imageChoiceTerrible = ORKImageChoice(normalImage: UIImage(named: "helpless-face"), selectedImage: UIImage(named: "helpless-face"), text: "Terrible", value: "terrible")
        
        let moodImages = ORKImageChoiceAnswerFormat(imageChoices: [imageChoiceAwesome, imageChoiceOk, imageChoiceBad, imageChoiceTerrible])
        let moodStep = ORKQuestionStep(identifier: DBSurveyMoodIdentifier, title: "How do you feel?", answer: moodImages)

        return moodStep
    }
    
    // Stress question
    func stressStep() -> ORKQuestionStep {
        let imageChoiceNoStress = ORKImageChoice(normalImage: UIImage(named: "grinning-face"), selectedImage: UIImage(named: "grinning-face"), text: "No stress", value: "no_stress")
        let imageChoiceLittleStressed = ORKImageChoice(normalImage: UIImage(named: "grimacing-face"), selectedImage: UIImage(named: "grimacing-face"), text: "A little stressed", value: "little_stress")
        let imageChoiceStressed = ORKImageChoice(normalImage: UIImage(named: "expressionless-face"), selectedImage: UIImage(named: "expressionless-face"), text: "Stressed", value: "stressed")
        let imageChoiceReallyStressed = ORKImageChoice(normalImage: UIImage(named: "helpless-face"), selectedImage: UIImage(named: "helpless-face"), text: "Really stressed", value: "really_stressed")
        
        let stressImages = ORKImageChoiceAnswerFormat(imageChoices: [imageChoiceNoStress, imageChoiceLittleStressed, imageChoiceStressed, imageChoiceReallyStressed])
        let stressStep = ORKQuestionStep(identifier: DBSurveyStressIdentifier, title: "How stressed do you feel?", answer: stressImages)
        
        return stressStep
    }
    
    // Returns a form with questions for body weight and body fat percentage steps.
    func bodyWeightAndFatPercentageStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: DBSurveyWeightIdentifier, title: "Weight and Fat Percentage", text: "")
        
        let bodyWeight = ORKFormItem(identifier: DBSurveyBodyWeightIdentifier, text: "Weight", answerFormat: ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!, unit: HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Kilo), style: ORKNumericAnswerStyle.Decimal))
        let bodyFat = ORKFormItem(identifier: DBSurveyBodyFatIdentifier, text: "Body Fat Percentage", answerFormat: ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage)!, unit: HKUnit.percentUnit(), style: ORKNumericAnswerStyle.Decimal))
        
        var stepItems: Array<ORKFormItem> = Array()
        stepItems.append(bodyWeight)
        stepItems.append(bodyFat)
        
        step.formItems = stepItems
        
        return step
    }
    
    // Returns a form with questions for blood pressure and heart rate
    func bloodPressureAndHeartRateStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: DBSurveyHeartIdentifier, title: "Blood Pressure and Heart Rate", text: "")
        
        let heartRate = ORKFormItem(identifier: DBSurveyHeartRateIdentifier, text: "Heart Rate", answerFormat: ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!, unit: HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit()), style: ORKNumericAnswerStyle.Integer))
        
        let bloodPressureSection = ORKFormItem(sectionTitle: "Blood Pressure")
        let bloodPressureSystolic = ORKFormItem(identifier: DBSurveyBloodPressureSystolicIdentifier, text: "Systolic", answerFormat: ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!, unit: HKUnit.millimeterOfMercuryUnit(), style: ORKNumericAnswerStyle.Integer))
        let bloodPressureDiastolic = ORKFormItem(identifier: DBSurveyBloodPressureDiastrolicIdentifier, text: "Diastolic", answerFormat: ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!, unit: HKUnit.millimeterOfMercuryUnit(), style: ORKNumericAnswerStyle.Integer))
        
        step.formItems = [heartRate, bloodPressureSection, bloodPressureSystolic, bloodPressureDiastolic]
        
        return step
    }
    
    // Boolean question about alcohol consumption
    func alcoholConsumptionStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: DBSurveyAlcoholIdentifier, title: "Did you drink alcohol today?", text: "")
        
        let alcoholConsumption = ORKFormItem(identifier: DBSurveyAlcoholConsumptionIdentifier, text: "", answerFormat: ORKBooleanAnswerFormat())
        
        step.formItems = [alcoholConsumption]
        
        return step
    }
    
    // Questions about how many steps were taken and whether a workout was done today
    func activityStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: DBSurveyActivityIdentifier, title: "How active have you been today?", text: "")
        
        let stepCount = ORKFormItem(identifier: DBSurveyStepCountIdentifier, text: "Steps", answerFormat: ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.Integer))
        let workout = ORKFormItem(identifier: DBSurveyWorkoutIdentifier, text: "Workout", answerFormat: ORKBooleanAnswerFormat())
        
        step.formItems = [stepCount, workout]
        
        return step
    }
    
    // Questions about when the user went to sleep, woke up, how many hours of sleep, and sleep score
    func sleepStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: DBSurveySleepIdentifier, title: "How was your sleep last night?", text: "")
        
        let sleepStart = ORKFormItem(identifier: DBSurveySleepStartIdentifier, text: "Start", answerFormat: ORKTimeOfDayAnswerFormat())
        let sleepEnd = ORKFormItem(identifier: DBSurveySleepEndIdentifier, text: "End", answerFormat: ORKTimeOfDayAnswerFormat())
        let sleepHours = ORKFormItem(identifier: DBSurveySleepHoursIdentifier, text: "Hours", answerFormat: ORKNumericAnswerFormat(style: .Decimal))
        
        sleepHours
        
        let sleepScore = ORKFormItem(identifier: DBSurveySleepScoreIdentifier, text: "Sleep Score", answerFormat: ORKNumericAnswerFormat(style: .Integer))
        
        step.formItems = [sleepStart, sleepEnd, sleepHours, sleepScore]
        
        return step
    }
    
    // Step for taking a picture of the front body
    func frontBodyImageCaptureStep() -> ORKImageCaptureStep {
        let step = ORKImageCaptureStep(identifier: DBSurveyFrontBodyImageIdentifier)
        step.title = "Front Body"
    
        return step
    }
    
    // Step for taking a picture of the side body
    func sideBodyImageCaptureStep() -> ORKImageCaptureStep {
        let step = ORKImageCaptureStep(identifier: DBSurveySideBodyImageIdentifier)
        step.title = "Side Body"
        
        return step
    }
    
    // Step for taking a picture of the back body
    func backBodyImageCaptureStep() -> ORKImageCaptureStep {
        let step = ORKImageCaptureStep(identifier: DBSurveyBackBodyImageIdentifier)
        step.title = "Back Body"
        
        return step
    }
}
