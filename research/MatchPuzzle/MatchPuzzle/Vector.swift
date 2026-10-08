//
//  Vector.swift
//  MatchPuzzle
//
//  Created by Tetsuo Kawakami on 2024/08/13.
//

import Foundation

struct Vector {
    let x: Int
    let y: Int
}

// MARK: Vector maths
extension Vector {
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

// MARK: Basic values
extension Vector {
    static var down: Vector {
        Vector(x: 0, y: -1)
    }
    
    static var up: Vector {
        Vector(x: 0, y: 1)
    }
    
    static var left: Vector {
        Vector(x: -1, y: 0)
    }
    
    static var right: Vector {
        Vector(x: 1, y: 0)
    }
}

extension Vector: Hashable { }
