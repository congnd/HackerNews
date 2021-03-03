# Welcome to the HackerNews iOS project 📱

*Please read carefully this documentation before starting to make any change*

## Table of contents
* [Features](#features)
* [Modular Design](#modular-design)
* [Design pattern for UI layer](#design-pattern-for-ui-layer)
* [Input-Output pattern for ViewModels](#input-output-pattern-for-viewmodels)
* [Making UI](#making-ui)
* [Coding Guidelines](#coding-guidelines)
* [Testing](#testing)
* [Environment](#environment)
* [Documentation](#documentation)

## Features
Implemented features so far:
- List stories screen with the following features:
  - Fetch and show top 50 stories from `HackerNews`
  - Allow user to filter the fetched stories by time or ranking (score)
  - Allow user to refresh the stories
  - Don't clear fetched storis after refresh failure
  - Open links associated with stories in in-app Safari browser

***Known issue***: `HackerNews` doesn't seem to providing a batch API 
to fetch detail info for multiple stories at once. So currently, 
we are making multiple request a time to fetch detail info for fetched story ids.
This is really bad, I know, but it seems that we have no way except creating our own API.

## Modular Design
To reduce the complexity as the project growths and having good separation of concerns,
this project has been devided into multiple parts, each part has its own responsibility. 
We call them, modules. Those modules are not only separeted conventionally but also configured
to prevent you - engineers from incorrectly connecting them together. Please take a look 
at the picture below to understand how they are connected.

![Modular Design](/docs/resources/modular_design.png)

Using modular design not only helps us to having well code separation but also reduces 
build time (both clean builds and incremental builds) significantly. Look at the picture 
below for details.

![Modular Design](/docs/resources/modular_design_faster.png)

Now, let's have a brief explaination about all modules and their responsibilities:

- ___Domain___: Contains business logic & model definition. This module doesn't 
depend on any other modules. The business logic should be defined as pure protocols. 
The detail implmenetation must be done in `Platform`.

- ___Api___: Contains the network layer that will actually communicate with 
the API server. Responses should be defined here. They SHOULD BE different from models 
defined in the `Domain`. This module is an independent.

- ___Platform___: Contains detail implementation for the `Domain`. This module 
depends on the `Api` to fetch the response & convert to `Domain`'s models if needs. 
Do NOT import view related modules here. Modules like `UIKit` must NOT 
be imported in this module.

- ___iOS___: Contains UI implementation for the app. All the user interface modules 
(view, screen, ...) must be implemented here. This module depends on only the `Domain`. 
Do NOT use `Platform` directly here.

- ___HackerNews___: The main module of the application. This module is the 
composition root for the app. It will be the PIC for creating screens, initiating view models, 
injecting dependecies, and routing between scenes. This module depends on `iOS` and `Platform`.


## Design pattern for UI layer
This application utilizes MVVM-C (MVVM plus the Coordinator) pattern. We are also 
using RxSwift & RxCocoa intensively to implement the MVVM for the UI layer.
So you should get familiar with all of them first.

- The coordinator pattern helps us separate view controller and the navigation between 
view controllers. Therefore, each view controller is completely isolated.

- RxSwift: reactive programming used to control the UI layer. RxSwift is NOT allowed 
in any other modules except the iOS module where application user interface is managed.

- `ViewControllers`: setup & manage views and that's all.
- `ViewModels`: acts the middle layer between the view controller and services (from `Platform`).
`ViewModels` receive UI events from `ViewControllers`, parse them, call proper actions on services
and then response to the ViewController to update views. `ViewControllers` do depend on `ViewModels`.
The services that the `ViewModels` depend on are injected when creating the ViewController-ViewModel
instances within the main module.

## Input-Output pattern for ViewModels
As explained above, `ViewModels` are preaty much like outputing data based on input events.
To make life a little bit easier, for both reading side and implementing side, we use Input-Output
pattern for all the `ViewModels`.

Input-Out pattern is pretty simple. To adopt this pattern, all you need to do is making your view model
conforms to this protocol.

```Swift
protocol ViewModelType {
  associatedtype Input
  associatedtype Output

  func transform(_ input: Input) -> Output
}
```

Then, when setting up binding in view controller, all you need to do is passing 
necessary input Rx streams and getting output Rx streams to control your views.
Please take a look at the `StoriesViewModel.swift` and `StoriesViewController.swift` for details.

Please refer to these pages if you have no idea about what I've mentioned above.
1. Coordinator pattern: https://khanlou.com/2015/10/coordinators-redux/
2. RxSwift: https://github.com/ReactiveX/RxSwift


## Making UI
Storyboard and Xibs are great but they are not friendly for code review. 
That's the reason interface builder tools like Storyboards and Xibs are not allowed in this project.

You have to create all of you views by code with the help from `SnapKit` to write layout code 
a bit shorter and cleaner.


## Coding Guidelines
We are following the coding guidelines defined by Google here: 

https://google.github.io/swift/

Please make sure that you understand all the rules written there before writting code.

Additionally, we are also using SwfitLint to enfoce all the common rules so please make sure that
you don't violate any of them. Always try to solve all the warnings.

Last but not least, please make sure that you are not leaving any layout constraint warnings.


## Testing
We use unit testing to ensure the product quality.
All the modules below need to be covered by unit test:
- Api
- Platform
- iOS (use unit testing for all of you ViewModels)

When writting unit tests please:
- consider edge cases as much as possible
- don't dealing with async operations by waiting for seconds
- don't break existing tests
- run all the tests before commit

Please check the implemented unit tests in each module above for details.


## Environment
- Xcode 12.4
- Swift 5.3
- Dependency manager:
  - SwiftPM

## Documentation
Refer to the `docs` folder of this project for details about each feature. (Under construction)
