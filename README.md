# PMTabBarController

PMTabBarController is a subclass of UITabBarController that replaces the conventional tab bar with a circularly scrolling scroll view of any number of tab bar icon views. 

![Demo](http://pm-dev.github.io/PMTabBarController.gif)


## Requirements & Notes

- PMTabBarController was built for iOS and requires a minimum iOS target of iOS 7.
- Thorough commenting of header files is currently in progress. (6/12/14).

## How To Get Started

- Check out the documentation (coming soon).

### Installation with CocoaPods

PMTabBarController is available through [CocoaPods](http://cocoapods.org). [CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like PMTabBarController in your projects. See the ["Getting Started" guide for more information](http://guides.cocoapods.org/using/getting-started.html).

#### Podfile

To install, simply add the following line to your Podfile.

```ruby
platform :ios, '7.0'
pod "PMTabBarController"
```

## Usage

To see PMTabBarController in action, run the example project at /Example/PMTabBarController-iOSExample.xcworkspace.
After installing the PMTabBarController pod, integrating into your project is as easy as:

```objective-c

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	/* Instantiate viewController1, viewController2, etc... */

	PMTabBarController *tbc = [PMTabBarController new];

	tbc.viewControllers = @[viewController1, viewController2, viewController3, /*....*/];
							
	tbc.tabViews = @[/*UIView tab for viewController1*/,
					 /*UIView tab for viewController2*/,
					 /*UIView tab for viewController3*/,
					 /*...*/];

	tbc.tabBarBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
	tbc.tabBarShadowRadius = 20.0f;
	tbc.minimumTabBarSpacing = 30.0f;
    
	[self.window setRootViewController:tbc];
    
	return YES;
}
```

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/PMTabBarController). (Tag 'PMTabBarController')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/PMTabBarController).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Author

- [Peter Meyers](mailto:petermeyers1@gmail.com)

## License

PMTabBarController is available under the MIT license. See the LICENSE file for more info.
