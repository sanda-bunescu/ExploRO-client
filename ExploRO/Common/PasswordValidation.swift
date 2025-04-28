import Foundation

enum PasswordStrengthError: String {
    case tooShort = "Password must be at least 8 characters long."
    case noUppercase = "Password must contain at least one uppercase letter."
    case noLowercase = "Password must contain at least one lowercase letter."
    case noNumber = "Password must contain at least one number."
    case noSpecialChar = "Password must contain at least one special character (e.g., !@#$&*)."
}

func checkPasswordStrength(_ password: String) -> [PasswordStrengthError]? {
    var errors = [PasswordStrengthError]()
    
    if password.count < 8 {
        errors.append(.tooShort)
    }
    
    if (password.rangeOfCharacter(from: .uppercaseLetters) == nil) {
        errors.append(.noUppercase)
    }
    
    if (password.rangeOfCharacter(from: .lowercaseLetters) == nil) {
        errors.append(.noLowercase)
    }
    
    if (password.rangeOfCharacter(from: .decimalDigits) == nil) {
        errors.append(.noNumber)
    }
    
    let specialCharacterSet = CharacterSet(charactersIn: "!@#$&*.,;:_-")
    if password.rangeOfCharacter(from: specialCharacterSet) == nil {
        errors.append(.noSpecialChar)
    }
    
    return errors.isEmpty ? nil : errors
}
