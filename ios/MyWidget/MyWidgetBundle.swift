//
//  MyWidgetBundle.swift
//  MyWidget
//
//  Created by  유 주연 on 2023/06/22.
//

import WidgetKit
import SwiftUI

@main
struct MyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MyWidget()
        MyWidgetLiveActivity()
    }
}
