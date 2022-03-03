//
//  ReminderManager.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 03/03/22.
//

import Foundation
import EventKit
import EventKitUI

typealias EventsCalendarManagerResponse = (_ result: Result<Bool, CustomError>) -> Void

class ReminderManager: NSObject {
    var eventStore: EKEventStore!
    
    override init() {
        eventStore = EKEventStore()
    }
    
    func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: .reminder) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    // Get Calendar auth status
    
     func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .reminder)
    }
    
    // Check Calendar permissions auth status
    // Try to add an event to the calendar if authorized
       
    func addEventToCalendar(title: String, date: Date, completion : @escaping EventsCalendarManagerResponse) {
           let authStatus = getAuthorizationStatus()
           switch authStatus {
           case .authorized:
               let reminder = generateReminder(title: title, date: date)
               self.addEvent(reminder: reminder, completion: { (result) in
                   switch result {
                   case .success:
                       completion(.success(true))
                   case .failure(let error):
                       completion(.failure(error))
                   }
               })
           case .notDetermined:
               // Auth is not determined
               // We should request access to the calendar
               requestAccess { (accessGranted, error) in
                   if accessGranted {
                       let reminder = self.generateReminder(title: title, date: date)
                       self.addEvent(reminder: reminder, completion: { (result) in
                           switch result {
                           case .success:
                               completion(.success(true))
                           case .failure(let error):
                               completion(.failure(error))
                           }
                       })
                   } else {
                       // Auth denied, we should display a popup
                       completion(.failure(.calendarAccessDeniedOrRestricted))
                   }
               }
           case .denied, .restricted:
               // Auth denied or restricted, we should display a popup
               completion(.failure(.calendarAccessDeniedOrRestricted))
           @unknown default:
               break
           }
       }
    
    private func addEvent(reminder: EKReminder, completion : @escaping EventsCalendarManagerResponse) {
        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            completion(.failure(.eventNotAddedToCalendar))
        }
        completion(.success(true))
    }
    
    func eventAlreadyExists() -> Bool {
        for item in eventStore.sources {
            for itemSub in item.calendars(for: .reminder) where itemSub.title ==  StringAddDevice.titleAddDevice {
               
                    return true
            }
        }
        return false
    }
    
    // for get single intance of calender
    func getEKCalendar() -> EKCalendar {
        for item in eventStore.sources {
            for itemSub in item.calendars(for: .reminder) where itemSub.title ==  StringAddDevice.titleAddDevice {
                return itemSub
            }
        }
        
        return EKCalendar(for: .reminder, eventStore: eventStore)
    }
    
    
     func bestPossibleEKSource() -> EKSource? {
        let `default` = eventStore.defaultCalendarForNewEvents?.source
        let iCloud = eventStore.sources.first(where: { $0.title == "iCloud" }) // this is fragile, user can rename the source
        let local = eventStore.sources.first(where: { $0.sourceType == .local })
        
        return `default` ?? iCloud ?? local
    }
  
    
    // Add for main reminder in list with app name
     func addReminderMainList() {
         let cal = EKCalendar(for: .reminder, eventStore: eventStore)
         cal.title = StringAddDevice.titleAddDevice
         cal.cgColor = UIColor.ButtonColorBlue.cgColor
         // cal.calendarIdentifier = "Ochaner"
         
         guard let source = bestPossibleEKSource() else {
             return // source is required, otherwise calendar cannot be saved
         }
         cal.source = source
         if !eventAlreadyExists() {
             do {
                 try eventStore.saveCalendar(cal, commit: true)
                 //                        save(event, span: .thisEvent)
                 print("Reminder Add in List")
                 //   self.reminders.remove(at: index)
             } catch {
                 print(error.localizedDescription)
             }
         } else {
             print("Reminder is alreedy in List ")
         }
     }
    
    
    private func generateReminder(title: String, date: Date) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = ""
        let cal = Calendar(identifier: .gregorian)
        let nextyearDate = cal.date(byAdding: .year, value: 1, to: Date())
        reminder.dueDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute], from: nextyearDate!)
        print(nextyearDate!)
        reminder.priority = 1
        // reminder.
        reminder.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: 7, end: nil))
        // reminder.notes = ""
        reminder.calendar = getEKCalendar()
        let alarm = EKAlarm(absoluteDate: date.addingTimeInterval(-600)) // Before 10 min alarm is show
        reminder.addAlarm(alarm)
        return reminder
    }
    
    
    func removeReminder() {
        if  getAuthorizationStatus() == .authorized {
            let predicate = self.eventStore.predicateForReminders(in: nil)
            self.eventStore.fetchReminders(matching: predicate, completion: { reminders in
                // print("remnders count \(reminders)")
                for item in reminders ?? [] {
                    if item.title.contains(StringDevices.yourNextDose) {
                        do {
                            try self.eventStore.remove(item, commit: true)
                            print("delet Reminder fromlist")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            })
        }
    }
    
}

enum CustomError: Error {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
}
