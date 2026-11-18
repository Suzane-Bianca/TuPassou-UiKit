//
//  Matter.swift
//  TuPassou?
//
//  Created by Bianca Moura on 11/11/26.
//

import SwiftData
import Foundation

@Model
class Matter {
    var classe: String
    var course: String
    var typeCalc: String
    var grade: [Float]
    var emoji: String
    
    init(classe: String, course: String, grade: [Float], typeCalc: String, emoji: String = "📚") {
        self.classe = classe
        self.course = course
        self.grade = grade
        self.typeCalc = typeCalc
        self.emoji = emoji
    }
}

extension Matter {
    func calcNotesSemester() -> String {
        if typeCalc != "Padrão IF" {
            return "Cálculo pendente"
        }
        
        let pesos: [Float] = [1.0, 1.0, 1.5, 1.5]
        let pointToPass: Float = 35.0
        
        var pc: Float = 0.0
        var somaRest: Float = 0.0
        
        for i in 0..<4 {
            if i < grade.count {
                pc += grade[i] * pesos[i]
            } else {
                somaRest += pesos[i]
            }
        }
        
        if somaRest == 0 {
            let mediaFinal = pc / 5.0
            if mediaFinal >= 7.0 {
                return String(format: "Passou! Media: %.2f", mediaFinal)
            } else {
                return String(format: "Reprovou/Final! Media: %.2f", mediaFinal)
            }
        }
        
        let pointsRest = pointToPass - pc
        
        if pointsRest <= 0 {
            return "Passou"
        }
        
        let mediaNeed = pointsRest / somaRest
        
        if mediaNeed > 10.0{
            return "Final"
        }
        
        return String(format: "%.2f", mediaNeed)
    }
}
