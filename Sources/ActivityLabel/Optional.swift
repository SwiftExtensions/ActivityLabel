//
//  Optional.swift
//  ActivityLabel
//
//  Created by Александр Алгашев on 18.11.2026.
//

extension Optional where Wrapped == String {
    /**
     Булево значение, указывающее на отсутствие символов в строке.
     */
    var isEmpty: Bool {
        let isEmpty: Bool
        if case let .some(string) = self {
            isEmpty = string.isEmpty
        } else {
            isEmpty = true
        }
        
        return isEmpty
    }
    
    
}
