//
//  UIColor+Ext.swift
//  UIKitDemo
//
//  Created by Quang Nguyen K. on 25/02/2025.
//

import UIKit

public extension UIColor {
    /*
     This method will initialize a color object with the provided hexadecimal number, and alpha (0.0-1.0).
     (Currently it only supports 24 bits color)
     It is recommended to use this init method directly in swift, and use the following two static methods in objc
     **/
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        // What it does here is, whatever (and) F should return itself, and whatever (and) 0 should return 0. So first it tries to
        // do and (&) operator to take the first two digit for red. second two digit for green, and the rest is for blue. after that, cause 2 digits hexa is
        // 8 digits binary, we only want the value for those red, green or blue component. so for red, we shift the binary by 16 digits, green by 8 digit, and the
        // rest should be blue. (Does not need to shift the binary). By the end of the calculation, it will need to divide the number by 255 (maximum byte),
        // so it will  gets value between 0.0, and 1.0 (float)
        let red = CGFloat((hex & Red.mask) >> Red.rightShift) / UIColor.maxInByte
        let green = CGFloat((hex & Green.mask) >> Green.rightShift) / UIColor.maxInByte
        let blue = CGFloat((hex & Blue.mask) >> Blue.rightShift) / UIColor.maxInByte

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    @objc
    static func color(hex: UInt, alpha: CGFloat) -> UIColor {
        UIColor(hex: hex, alpha: alpha)
    }

    @objc
    static func color(hex: UInt) -> UIColor {
        UIColor(hex: hex)
    }
}

private extension UIColor {
    enum Red {
        static let mask: UInt = 0xFF0000
        static let rightShift = 16
    }

    enum Green {
        static let mask: UInt = 0x00FF00
        static let rightShift = 8
    }

    enum Blue {
        static let mask: UInt = 0x0000FF
        static let rightShift = 0
    }

    static let maxInByte = CGFloat(0xFF)
}
