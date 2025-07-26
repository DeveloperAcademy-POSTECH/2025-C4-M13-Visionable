//
//  NSObject+.swift
//  FFIP-iOS
//
//  Created by mini on 7/26/25.
//

import Foundation

extension NSObject {
    /// UIKit에서 현재 ClassName을 불러와서 identifier로 사용할 때 사용하는 프로퍼티
    static var className: String {
        return String(describing: self)
    }
}
