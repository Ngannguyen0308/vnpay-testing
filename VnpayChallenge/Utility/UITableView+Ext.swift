//
//  UITableView+Ext.swift
//  UIKitDemo
//
//  Created by Quang Nguyen K. on 24/02/2025.
//

import UIKit

extension UITableView {
    public func register<T: UITableViewCell>(_ aClass: T.Type, at bundleOther: Bundle? = nil) {
        let name = String(describing: aClass)
        let bundle: Bundle
        if let bundleOther = bundleOther {
            bundle = bundleOther
        } else {
            bundle = Bundle(for: aClass)
        }
        if bundle.path(forResource: name, ofType: "nib") != nil {
            let nib = UINib(nibName: name, bundle: bundle)
            register(nib, forCellReuseIdentifier: name)
        } else {
            register(aClass, forCellReuseIdentifier: name)
        }
    }

    public func register<T: UITableViewHeaderFooterView>(_ aClass: T.Type, at bundleOther: Bundle? = nil) {
        let name = String(describing: aClass)
        let bundle: Bundle
        if let bundleOther = bundleOther {
            bundle = bundleOther
        } else {
            bundle = Bundle(for: aClass)
        }
        if bundle.path(forResource: name, ofType: "nib") != nil {
            let nib = UINib(nibName: name, bundle: bundle)
            register(nib, forHeaderFooterViewReuseIdentifier: name)
        } else {
            register(aClass, forHeaderFooterViewReuseIdentifier: name)
        }
    }
}

public extension UITableView {

    func dequeueReusableCell<CellClass>(withCellType cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass {
        // Force casting purposely in order to know something wrong straight away
        return dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as! CellClass
    }

    /// A utility method to register a table header / footer class by its class name
    /// - Warning: The headerFooterClass should not be optional as the `String(describing: cellClass)`
    /// produce different string on optional/non-optional types
    /// - Parameter headerFooterClass: table view header or footer class
    func registerHeaderFooter(_ headerFooterClass: AnyClass) {
        register(headerFooterClass, forHeaderFooterViewReuseIdentifier: String(describing: headerFooterClass))
    }

    func dequeueHeaderFooter<HeaderFooterClass>(withType classType: HeaderFooterClass.Type) -> HeaderFooterClass {
        dequeueReusableHeaderFooterView(withIdentifier: String(describing: classType)) as! HeaderFooterClass
    }
}
