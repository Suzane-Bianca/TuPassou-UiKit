//
//  Matter.swift
//  TuPassou?
//
//  Created by Bianca Moura on 11/11/26.
//

import SwiftData

@Model
class Matter {
    var classe: String
    var course: String
//    var grade: [Int]
    
    init(classe: String, course: String/*, grade: [Int]*/) {
        self.classe = classe
        self.course = course
//        self.grade = grade
    }
}
