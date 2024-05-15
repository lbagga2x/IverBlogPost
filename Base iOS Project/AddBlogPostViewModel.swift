//
//  AddBlogPostViewModel.swift
//  Base iOS Project
//
//  Created by Lalit Bagga on 2021-01-12.
//  Copyright © 2021 Iversoft Solutions Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import DKImagePickerController

class AddBlogPostViewModel: BaseViewModel {
    let blogCreationWatcher = PublishSubject<BlogPost>()
    let imageWatcher = PublishSubject<UIImage?>()
    private var selectedImage: UIImage?
    
    func onPostButtonPressed(blogTitle: String?, blogContent: String?, shouldPublish: Bool) {
        // build the required data based on the input fields
        var params = [String : Any]()
        params["title"] = blogTitle
        params["content"] = blogContent
        params["published"] = shouldPublish
        
        isLoading.onNext(true)
        HttpClient().createBlogPost(SettingModel.APIRouter.createBlogPosts(parameters: params), image: selectedImage, params: params, type: BlogPost.self, ApiCallback(onFinish: { [weak self](response) in
            self?.isLoading.onNext(false)
            guard let self = self else { return }
            if let error = response?.error {
                self.isError.onNext((response?.data, error))
            } else if let blogPost = response?.baseMappable as? BlogPost {
                self.blogCreationWatcher.onNext(blogPost)
            }
        }))
    }
    
    func onImageSelected(assets: [DKAsset]) {
        assets.first?.fetchOriginalImage(completeBlock: {[weak self] (image, _) in
            self?.selectedImage = image
            self?.imageWatcher.onNext(image)
        })
    }
}
