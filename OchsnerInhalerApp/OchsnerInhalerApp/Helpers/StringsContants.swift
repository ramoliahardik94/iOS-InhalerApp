//
//  StringsContants.swift
//

import Foundation


// MARK: Notification Identifiers
extension Notification.Name {
    static let BLEFound = Notification.Name("BLEFound")
    static let BLENotFound = Notification.Name("BLENotFound")
    static let BLEConnect = Notification.Name("BLEConnect")
    static let BLENotConnect = Notification.Name("BLENotConnect")
    static let BLEDisconnect = Notification.Name("BLEDisconnect")
    static let BLEGetMac = Notification.Name("BLEGetMac")
    static let BLEChange = Notification.Name("BLEChange")
    static let BLEBatteryLevel = Notification.Name("BLEBatteryLevel")
    static let BLEAcuationCount = Notification.Name("BLEAcuationCount")
    static let BLEAcuationLog = Notification.Name("BLEAcuationLog")
}

// MARK: Common Message
struct StringCommonMessages {
     static let commonMessage = ""
     static let cancel = "Cancel"
     static let skip = "Skip"
     static let grant = "Grant"
     static let share = "Share"
     static let copyRight = "©2022 Ochsner Health"
     static let connected = "Connected"
     static let connecting = "Connecting"
     static let disconnect = "Disconnected"
     static let battery = "Battery:"
    static let  rescueDose = "Take as needed"

}
struct AppFont {
    static let AppRegularFont = Constants.CustomFont.SFProTextRegular
    static let AppBoldFont = Constants.CustomFont.SFProDisplayBold
    static let AppSemiBoldFont = Constants.CustomFont.SFProTextSemibold
    static let AppLightItalicFont = Constants.CustomFont.SFProDisplayLightItalic
    static let AppLightFont = Constants.CustomFont.SFProDisplayLight
    static let SFProTextBold = Constants.CustomFont.SFProTextBold
}

// MARK: UserManagement
struct StringUserManagement {
    static let login = "Login"
    static let createAccount = "Create Account"
    static let updateProfile = "Update Profile"
    static let update = "Update"
    static let usePassword = "Use Password"
    static let dontHaveAccout = "Don't Have an Account?"
    static let email = "EMAIL"
    static let createPassword = "Create Password"
    static let firstName = "First Name"
    static let lastName = "Last Name"
    
    static let emailPlaceHolder = "Enter email"
    static let passwordPlaceHolder = "Enter password"
    static let confirmPasswordPlaceHolder = "Enter confirm password"
    static let placeHolderFirstName = "Enter first name"
    static let placeHolderLastName = "Enter last name"
    
    static let changePassTitle = "Change Password"
    static let currrentPassPlaceholder = "Enter current password"
    static let currentPass = "Current Password"
    
    static let newPassPlaceholder = "Enter new password"
    static let newPass = "New Password"
    
    static let confiremPassPlaceholder = "Enter confirm password"
    static let confiremPassword = "Confirm Password"
    static let updatePass = "Update Password"
    static let password = "Password"
    static let signup = "Sign Up"
}
struct ValidationMsg {
    static let fName = "Please enter Firstname"
    static let lName = "Please enter Lastname"
    static let matchPass = "Password & Confirm password must be same"
    static let email = "Please enter valid email"
    static let  password = "Please enter password"
    static let  confirmPassword = "Please enter confirm password"
    static let CommonError = "There might be some issue please try again."
    static let medication = "Please select medication."
    static let bluetooth = "Please turn on all the bluetooth"
    static let bleNotfound = "There is no nearby Inhaler sensor found. Please make sure that your sensor is activated properly and nearby to your phone."
    static let bleNotPair = "There might be some problem with pairing the Inhaler sensor. Please follow the steps mentioned on the screen to enable the paring mode and try again."
    static let addDose = "Please add daily dose."
    static let addPuff = "Please add how many puffs per dose?"
    
}
struct ValidationButton {
    static let tryAgain = "Try again"
}

// MARK: Profile
struct StringProfile {
    static let name = "Name"
    static let  updateEmail = "Update Email"
    static let  changePassword = "Change Password"
    static let  logOut = "Log Out"
    static let  changeProvider = "Change Provider"
    static let  remove = "Remove"
    static let  settings = "Settings"
    static let  receiveNotifications = "Receive Notifications"
    static let  shareLocation = "Share Location"
    static let  shareUsageWithProvider = "Share Usage With Provider"
    static let  useFaceID = "Use FaceID"
    static let  sureLogout = "Are you sure you want to logout?"
}

// MARK: Providers
struct StringPoviders {
    static let providerConnectLabel = "Connect Your Health Care Provider"
    static let selectProvider = "Select Provider"
    static let skipForNow = "Skip For Now"
    static let selectOrganization = "Select an Organization"
    static let providerSubHeader = "Where do you receive your healthcare?"
    static let switchOrganization = "Switch organizations"
    static let continueProvider = "Continue"
    static let change = "Change"
}
// MARK: Add Device
struct StringAddDevice {
    static let great = "Great!"
    static let addDevice = "Let’s Add \n Your Device"
    static let ConnectedInhalerSensor = "Connected Inhaler Sensor"
    static let addDeviceInto = "Ready to set up your device? Now, we’ll attach your Connected Inhaler Sensor to your inhaler, and link it to this app."
    static let startSetup = "Start Set Up"
    static let removeIsolationTag = "First, Remove the Battery Isolation Tag"
    static let removeIsolationTaginfo = "Remove and discard the yellow tag to activate your device."
    static let next = "Next"
    static let connectDevice = "Connect Device to Your Phone"
    static let connectDeviceInfo = "1. Make sure that Bluetooth is turned “on” in settings.\n\n 2. To initiate device pairing mode, Press the top of the device three times within five seconds period.\n \n3. Click the \"Pair Device\" button below."
    static let pareDevice = "Pair Device"
    static let mountDevice = "Mount Device to Your Inhaler"
    static let mountDeviceInfo = "Once paired to mobile phone, slip device over top of a compatible inhaler tank and press firmly into place."
    static let medication = "Now, let us know what inhaler medication you will use with this sensor."
    static let medicationInfo = "Your Connected Inhaler Sensor tracks usage of the medication in your inhaler, so we’ll need to associate it with a current prescription."
    static let selectMedication = "Select Medication"
    static let addAnotherDevice = "Would You Like to Add Another Device?"
    static let goHome = "All Set, Take Me To My Home Screen"
    static let addAnotherDeviceBtn = "Add Another Device Now"
    static let connect = "Connect"
    static let scanlist = "Scan device"
    static let titleAddDevice = "Connected Inhaler Application"
}
// MARK: Medication
struct StringMedication {
    static let titleMedication = "Which Medication Will be \n Used With This Sensor?"
    static let inhealerType = "How Will This \n Inhaler Be Used?"
    static let titleMedicationDetail = "What Are The Directions For Use of This Maintenance Inhaler?"
    static let puffTitle = "How many puffs per dose?"
    static let doseTime = "Dose Times"
    static let reminder = "Set Reminders?"
    static let done = "Done"
    static let shareYourInhalerUsage = "Share Your Inhaler Usage With Ochsner"
    static let addDose = "Add another daily dose."
    static let addFirstDose = "Add daily dose."
}
// MARK: Permissions
struct StringPermissions {
    static let bluetoothPermission = "Grant Bluetooth Permissions"
    static let locationPermission = "Grant Location Permissions"
    static let notificationPermission = "Grant Notification Permissions"

    static let shareYourInhalerUsage = "Share Your\nInhaler Usage\nWith Ochsner"
    static let sorrybluetoothPermission = "Sorry, Bluetooth Permissions Are Required"
    static let oneLastThing = "One last thing…"
    static let keepYourOchsner = "keeps your Ochsner in the loop as you use your inhaler. Your information is never shared with 3rd parties."
    static let privacyPolicy = "Privacy Policy"
    static let shareYourInhaler = "Share your inhaler usage information with Ochsner."
    static let blePermissionMsg = "Bluetooth permissions are required to access the Inhaler sensor device."
    static let turnOn = "Ochsner Inhaler Connect need to turn on Bluetooth."

    
}


// MARK: Device
struct StringDevices {
    static let pairedDevice = "Paired Device"
    static let removeDevice = "Remove Device"
    static let editDirection = "Edit Directions"
    static let usage = "Usage: "
    static let addAnotherDevice = "Add Another Device"
    
}

// MARK: Splash
struct StringSplash {
    static let connectdInhalerSensor = "Connected\nInhaler Sensor"
}
// MARK: Home screen
struct StringHome {
    static let  today = "Today"
    static let  thisWeek = "This Week"
    static let  thisMonth = "This Month"
    static let  adherance = "Adherance: "
}

struct CellIdentifier {
    static let medicationCell = "MedicationCell"
    static let doseTimeCell = "DoseTimeCell"
    static let manageDeviceCell = "ManageDeviceCell"
}
