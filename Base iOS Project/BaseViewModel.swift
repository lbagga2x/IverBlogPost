//
//  BaseViewModel.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Base class for view models
class BaseViewModel {
    var isLoading = PublishSubject<Bool>()
    var isError = PublishSubject<(Data?, Error)>()
}
