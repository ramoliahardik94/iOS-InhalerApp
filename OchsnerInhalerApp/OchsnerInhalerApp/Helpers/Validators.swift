//
//  Validators.swift

import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case email
    case password
    case loginpassword
    case username
    case projectIdentifier
    case requiredField(field: String)
    case confirmpassword(password: String)
    case age
    case numaricValidation(message: String, lenght: Int)
    case mobile
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password: return PasswordValidator()
        case .loginpassword: return LoginPasswordValidator()
        case .username: return UserNameValidator()
        case .projectIdentifier: return ProjectIdentifierValidator()
        case .requiredField(let fieldName): return RequiredFieldValidator(fieldName)
        case .confirmpassword(let password): return ConfirmPasswordValidator(password)
        case .age: return AgeValidator()
        case .numaricValidation(let message, let lenght): return NumericValidator(lenght, message)
        case .mobile: return MobileNumberValidator()
        }
    }
}

// "J3-123A" i.e
struct ProjectIdentifierValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[A-Z]{1}[0-9]{1}[-]{1}[0-9]{3}[A-Z]$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid Project Identifier Format")
            }
        } catch {
            throw ValidationError("Invalid Project Identifier Format")
        }
        return value
    }
}

class AgeValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count > 0 else {throw ValidationError("Age is required")}
        guard let age = Int(value) else {throw ValidationError("Age must be a number!")}
        guard value.count < 3 else {throw ValidationError("Invalid age number!")}
        guard age >= 18 else {throw ValidationError("You have to be over 18 years old to user our app :)")}
        return value
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ field: String) {
        fieldName = field
    }
    
    func validated(_ value: String) throws -> String {
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError(fieldName)
        }
        return value
    }
}

struct UserNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 3 else {
            throw ValidationError("Username must contain more than three characters" )
        }
        guard value.count < 18 else {
            throw ValidationError("Username shoudn't conain more than 18 characters" )
        }
        
        do {
            if try NSRegularExpression(pattern: "^[a-z]{1,18}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid username, username should not contain whitespaces, numbers or special characters")
            }
        } catch {
            throw ValidationError("Invalid username, username should not contain whitespaces,  or special characters")
        }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("password_required_msg".local)}
        guard value.count >= 16 else { throw ValidationError("password_lenth_msg".local) }
        
        do {
            let passwordRegex = "^(?=.*\\d)(?=.*[$@$#!%*?&'()+,-.:;<=>`^_{|}~])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`]{16,}$"
            let status = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: value)
            if status == false {
                throw ValidationError("password_error_msg".local)
            }
        } catch {
            throw ValidationError("password_error_msg".local)
        }
        return value
    }
}

struct LoginPasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("password_required_msg".local)}
        guard value.count >= 16 else { throw ValidationError("password_not_valid_msg".local) }
        
        do {
            let passwordRegex = "^(?=.*\\d)(?=.*[$@$#!%*?&'()+,-.:;<=>`^_{|}~])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`]{16,}$"
            let status = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: value)
            if status == false {
                throw ValidationError("password_not_valid_msg".local)
            }
        } catch {
            throw ValidationError("password_not_valid_msg".local)
        }
        return value
    }
}

struct ConfirmPasswordValidator: ValidatorConvertible {
    private let password: String
    init(_ field: String) {
        password = field
    }
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("confrim_password_required_msg".local)}
        guard value.count >= 16 else { throw ValidationError("confirm_password_lenth_msg".local) }
        
        do {
            let passwordRegex = "^(?=.*\\d)(?=.*[$@$#!%*?&'()+,-.:;<=>`^_{|}~])(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`]{16,}$"
            let status = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: value)
            if status == false {
                throw ValidationError("confirm_password_error_msg".local)
            }
            
        } catch {
            throw ValidationError("confirm_password_error_msg".local)
        }
        
        do {
            if value != password {
                throw ValidationError("confirm_pwd_msg".local)
            }
        } catch {
            throw ValidationError("confirm_pwd_msg".local)
        }
        return value
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("email_required_msg".local)}
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("invalid_email_msg".local)
            }
        } catch {
            throw ValidationError("invalid_email_msg".local)
        }
        return value
    }
}

struct NumericValidator: ValidatorConvertible {
    private let lenght: Int
    private let message: String
    
    init(_ lenght: Int, _ message: String) {
        self.lenght = lenght
        self.message = message
    }
    
    func validated(_ value: String) throws -> String {
        guard value.count == lenght else { throw ValidationError(message.local) }
        do {
            if try NSRegularExpression(pattern: "^[0-9]{\(lenght)}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError(message.local)
            }
        } catch {
            throw ValidationError(message.local)
        }
        return value
    }
}

struct MobileNumberValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
//        guard value.count >= 12 else { throw ValidationError("enter_valid_mobile_msg".local) }
        guard value != "" else {throw ValidationError("enter_mobile_msg".local)}
        do {
            if try NSRegularExpression(pattern: "^[+]{0,1}+[0-9]{11,12}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("enter_valid_mobile_msg".local)
            }
        } catch {
            throw ValidationError("enter_valid_mobile_msg".local)
        }
        return value
    }
}
