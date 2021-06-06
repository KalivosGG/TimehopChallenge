# Timehop Challenge

### Architecture

This project uses MVVM (Model-View-ViewModel) architecture pattern to achieve "separation of concerns" by breaking the main code into parts that each have their own responsability. Each corresponding part of the MVVM is located inside the folder with it's name - Views, Models and  ViewModels.

This project also features Dependency Injection for better testability and coupling reduction by using Swinject. The Container class registers all classes that are used as dependencies. Inside the Services folder you will find classes that acts as helpers and are injected in the MainViewModel by the Container.

RxSwift is used to work with asynchronous calls (reactive programming) and can be found being used mostly at MainViewModel and Repository classes. The Repository folder contains the protocols and classes related to networking that are used when fetching data.

There are also the Utils and Components folders that are basically convenient extensions for some classes

### How it works

This is an one-screen app and only uses one View (and one ViewModel), most of the work is done inside the ViewModel part, which is responsible for fetching the data, parsing, downloading, storing and caching all images/videos.

When started, the app will begin fetching data, this is done when viewModel.getStories() is called,
this method then uses RxSwift to build all steps that will follow after the initial fetching is done. 

If there's any error when fetching data, the stream of events will stop and an error will be emitted. After that initial fetching, if any step fails for any of the elements (Story), such as downloading the image/video, the stream will not be canceled/disposed, thus making this part impossible to fail as any ocurring errors will be filtered out.

The step after downloading is the saving of the image/video in the cache directory to prevent the app from downloading the same data in the future. When this part is done there is also a caching of images using NSCache so we can access these images/video faster when needed.

When all of these steps are completed for the first element (Story) then an Media object will be emitted to the view and so the first image/video will be shown to the user. This was made so the user won't have to wait for all images or videos to be fetched/downloaded/saved first, making it more user friendly.

All subsequent images/videos will be added to an ordered set and the user will be able to navigate between them by tap each side of the screen.

### Cocoapods:
- Moya/RxSwift, RxSwift, RxCocoa, RxBlocking, RxTest, Swinject, SnapKit, Quick and Nimble.

### Swift Package Manager
- Swime, swift-collections
