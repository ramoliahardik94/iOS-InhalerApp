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
    static let BLEOnOff = Notification.Name("BLEOnOff")
    static let BLEBatteryLevel = Notification.Name("BLEBatteryLevel")
    static let BLEAcuationCount = Notification.Name("BLEAcuationCount")
    static let BLEAcuationLog = Notification.Name("BLEAcuationLog")
    static let medUpdate = Notification.Name("medUpdate")
    static let DataSyncDone = Notification.Name("SYNC_SUCCESS_ACUATION")
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
     static let connecting = "Connecting..."
    static let notInRange = "Not in range"
     static let disconnect = "Disconnected"
    static let scanning = "Scanning..."
     static let battery = "Battery:"
    static let  rescueDose = "Take as needed"
    static let  noInternetConnection = "No Internet connection"
    static let  noDataFount = "No record found"
    static let  notSet = "Not set"
    static let  schedule = "Schedule"
    static let  privacyUrl = "https://connectedliving.ochsner.org/privacy.html"
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
    static let forgotePass = "Forgot password"
    static let updateProfile = "Update Profile"
    static let update = "Update"
    static let usePassword = "Use Password"
    static let dontHaveAccout = "Don't have an account?"
    static let email = "EMAIL"
    static let createPassword = "Create Password"
    static let firstName = "First Name"
    static let lastName = "Last Name"
    static let sendLink = "Send Link"
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
    static let removeDevice = "Are you sure to remove this device?"
    static let mantainance = "Cannot add more than one mantainance device."
    static let privacyPolicy = "You must accept our privacy policy!"
    static let forgoteSuccess = "If an account with this email exists, a link to reset your password will be sent to it."
    static let bluetoothOn = "Please Turn on Bluetooth"
    static let mismatchUUID = "Your devices have been changed from the previously paired. Re-configure the device to track the medication."
    static let startSync = "Data sync to phone start"
    static let startSyncCloudNo = "No data found to sync"
    static let startSyncCloud = "Data sync to cloud start"
    static let syncLoader = "Data Sync Inprogress"
    static let successAcuation = "Data Sync Successful"
    static let failAcuation = "Data Sync Fail"
    static let doseError = "Multiple doses for the same time cannot be scheduled!"
}

struct BLEStatusMsg {
    static let scanConnectBLE = "Device Connecting..."
    static let featchDataFromDevice = "Fetching Data..."
    static let syncStart = "Data Sync Inprogress..."
    static let syncFailNoData = "No Data to Sync."
    static let syncSuccess = "Data Sync Successful."
    static let noDeviceFound = "No Device Nearby."
}

struct ValidationButton {
    static let tryAgain = "Try again"
}

// MARK: Profile
struct StringProfile {
    static let name = "Name"
    static let  updateEmail = "Update Email"
    static let  changePassword = "Change Password"
    static let  logOut = "Logout"
    static let  changeProvider = "Change Provider"
    static let  remove = "Remove"
    static let  settings = "Settings"
    static let  receiveNotifications = "Receive Notifications"
    static let  shareLocation = "Share Location"
    static let  shareUsageWithProvider = "Share Usage With Provider"
    static let  useFaceID = "Use FaceID"
    static let  sureLogout = "Are you sure you want to logout?"
    static let  locarionPermission = "Turn on your location\nGoto Settings, Select OchsnerInhelarApp select location and tap Always or While Usings"
}

// MARK: Providers
struct StringPoviders {
    static let providerConnectLabel = "Connect your Health Care Provider"
    static let selectProvider = "Select Provider"
    static let skipForNow = "Skip For Now"
    static let selectOrganization = "Select an Organization"
    static let providerSubHeader = "Where do you receive your healthcare?"
    static let switchOrganization = "Switch organizations"
    static let continueProvider = "Continue"
    static let change = "Change"
    static let providerBaseUrl = "https://inhalertracking.ochsner.app/?provider"
}
// MARK: Add Device
struct StringAddDevice {
    static let great = "Great!"
    static let addDevice = "Let’s add \n your device"
    static let ConnectedInhalerSensor = "Connected Inhaler Sensor"
    static let addDeviceInto = "Ready to set up your device? Now, we’ll attach your Connected Inhaler Sensor to your inhaler, and link it to this app."
    static let startSetup = "Start Set Up"
    static let removeIsolationTag = "First, remove the battery isolation tag"
    static let removeIsolationTaginfo = "Remove and discard the yellow tag to activate your device."
    static let removeIsolationTagWithScan = "1. Remove and discard the yellow tag to activate your device. \n\n2. Make sure the device is nearby to the phone."
    
    static let next = "Next"
    static let connectDevice = "Connect device to your phone"
    static let scanDevicetitle = "Scan your device"
    static let connectDeviceInfo = "1. \"Scanning\" - Your Device is being scanned right now. Please wait! \n\n 2. \"Pair Device\" - Once enabled, Tap 3 times on the Device and click \"Pair Device\" within 5 seconds of tapping. \n\n 3. \"Pairing\" - Your Device is being paired."
    
    // "1. Make sure that Bluetooth is turned “on” in settings.\n\n 2. To initiate device pairing mode, Press the top of the device three times within five seconds period.\n \n3. Click the \"Pair Device\" button below."
    static let pairDevice = "Pair Device"
    static let scanningDevice = "Scanning"
    static let scanInstructionOne = "Make sure the device is nearby to the phone."
    static let scanInstructionTwo = "Your device is ready to pair."
    static let pairScreen = "Tap 3 times on the device and within 5 seconds click \"Pair Device\"."
    static let scanDevice = "Scan Device"
    static let pairingDevice = "Pairing"
    static let mountDevice = "Mount device to your Inhaler"
   // static let mountDeviceInfo = "Once paired to mobile phone, slip device over top of a compatible inhaler tank and press firmly into place."
    static let mountDeviceInfo = "Device is successfully paired to mobile phone, Now slip device over top of a compatible inhaler tank and press firmly into place."
    static let medication = "Now, let us know what inhaler medication you will use with this sensor."
    static let medicationInfo = "Your Connected Inhaler Sensor tracks usage of the medication in your inhaler, so we’ll need to associate it with a current prescription."
    static let selectMedication = "Select Medication"
    static let addAnotherDevice = "Would you like to add another device?"
    static let goHome = "All Set, Take Me To Provider Screen"
    static let addAnotherDeviceBtn = "Add Another Device Now"
    static let connect = "Connect"
    static let scanlist = "Scan device"
    static let titleAddDevice = "Connected Inhaler Application"
    static let titleHome = "Home"
    static let rescueInhaler = "(Rescue Inhaler)"
    static let maintenanceInhaler = "(Maintenance Inhaler)"
    static let removeAndDiscard = "Remove and discard the yellow tag to activate your device."
    static let infoCharecter = "\n\n\nⓘ "
    static let deviceNearBy = "Make sure the device is nearby to the phone."
    static let pairScreenStringArray = ["Tap", " 3 times ", "on the device within", "\n5 seconds ", "then click \"Pair Device\"."]
    
}
// MARK: Medication
struct StringMedication {
    static let titleMedication = "Which Medication will be \n used with this Sensor?"
    static let inhealerType = "How will this \n Inhaler be used?"
    static let titleMedicationDetail = "What are the directions for use of this Maintenance Inhaler?"
    static let puffTitle = "How many puffs per dose?"
    static let doseTime = "Dose Times"
    static let reminder = "Set Reminders?"
    static let done = "Done"
    static let shareYourInhalerUsage = "Share Your Inhaler Usage With Ochsner"
    static let addDose = "Add another daily dose."
    static let addFirstDose = "Add daily dose."
    static let permissionDose = "Need permission to enable reminders of your daily doses.\nGoto Settings,Select OchsnerInhelarApp and turn on Notification"
   
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
    static let yourNextDose = "Your dose is at"
    
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
    static let  nextScheduled = "Next Scheduled Dose: "
}

struct CellIdentifier {
    static let medicationCell = "MedicationCell"
    static let doseTimeCell = "DoseTimeCell"
    static let manageDeviceCell = "ManageDeviceCell"
    static let NotificationCell = "NotificationCell"
    static let DoseDetailCell = "DoseDetailCell"
}

// MARK: Local Notification
struct StringLocalNotifiaction {
    static let title = StringAddDevice.titleAddDevice
    static let body = "You will be no longer able to track the medicine usage"
    static let reminderBody = "Hi, %@ Just reminding you about your scheduled %@ doses at %@.Please take your dose and keep your device and Application nearby to update the latest reading. Ignore if the reading is already updated."
    static let notificationMsg = "You have missed your dose or it has not been synced."
    static let titleForRimander = "Your schedule dose time"
    static let idRimander = "com.ochsner.inhalertrack.reminderdose"
    static let noNotification = "No notification found"
}

// MARK: Date Formate
struct DateFormate {
    static let dateFromLog = "yyyy-MM-dd HH:mm:ss"
    static let useDateLocalAPI = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let useDateLocalBagCompare = "yyyy-MM-dd HH"    
    static let deviceSyncDateUTCAPI = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    static let doseTime = "hh:mm a"
    static let doseTime12Hr = "HH:mm"
    static let reminder = "dd/MM/yyyy hh:mm a"
    static let notificationDate = "yyyy-MM-dd hh:mm a"
    static let notificationFormate = "MMM dd,yyyy"
    static let useDateLocalyyyyMMddDash = "yyyy-MM-dd"
}
