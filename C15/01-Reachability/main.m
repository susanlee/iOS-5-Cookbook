/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIDevice-Reachability.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
    NSMutableString *log;
}
- (void) log: (NSString *) formatstring, ...;
@end

@implementation TestBedViewController
#pragma mark -

#pragma mark Tests

// Run basic reachability tests
- (void) runTests
{
    UIDevice *device = [UIDevice currentDevice];
    [self log:@"\n\n"];
    [self log:@"Current host: %@", [device hostname]];
    [self log:@"IPAddress: %@", [device localIPAddress]];
    [self log:@"Local: %@", [device localWiFiIPAddress]];
    [self log:@"All: %@", [device localWiFiIPAddresses]];
    
    [self log:@"Network available?: %@", [device networkAvailable] ? @"Yes" : @"No"];
    [self log:@"Active WLAN?: %@", [device activeWLAN] ? @"Yes" : @"No"];
    [self log:@"Active WWAN?: %@", [device activeWWAN] ? @"Yes" : @"No"];
    [self log:@"Active hotspot?: %@", [device activePersonalHotspot] ? @"Yes" : @"No"];
    if (![device activeWWAN]) return;
    [self log:@"Contacting whatismyip.com"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         NSString *results = [device whatismyipdotcom];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"IP Addy: %@", results];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];         
     }];
}

- (void) checkAddresses
{
    UIDevice *device = [UIDevice currentDevice];
    if (![device networkAvailable]) return;
    [self log:@"Checking IP Addresses"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         NSString *google = [device getIPAddressForHost:@"www.google.com"];
         NSString *amazon = [device getIPAddressForHost:@"www.amazon.com"];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"Google: %@", google];
             [self log:@"Amazon: %@", amazon];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];         
     }];
}

#define CHECK(SITE) [self log:@"• %@ : %@", SITE, [device hostAvailable:SITE] ? @"available" : @"not available"];

- (void) checkSites
{
    UIDevice *device = [UIDevice currentDevice];
    NSDate *date = [NSDate date];
    CHECK(@"www.google.com");
    CHECK(@"www.ericasadun.com");
    CHECK(@"www.notverylikely.com");
    CHECK(@"192.168.0.108");
    CHECK(@"pearson.com");
    CHECK(@"www.pearson.com");
    [self log:@"Elapsed time: %0.1f", [[NSDate date] timeIntervalSinceDate:date]];
}

// Auto perform reachability tests when reachability values change
- (void) reachabilityChanged
{
    [self log:@"REACHABILITY CHANGED!\n"];
    [self runTests];
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 24.0f : 12.0f];
    textView.textColor = COOKBOOK_PURPLE_COLOR;
    [self.view addSubview:textView];
    
    log = [NSMutableString string];
    [self checkSites];
    [self checkAddresses];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(runTests));    
    [[UIDevice currentDevice] scheduleReachabilityWatcher:self];
}

- (void) log: (NSString *) formatstring, ...
{
	if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
	NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    
    printf("%s\n", [outstring UTF8String]);
    
    if (!log) log = [NSMutableString string];
    [log insertString:@"\n" atIndex:0];
    [log insertString:outstring atIndex:0];
    textView.text = log;
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.bounds;
    
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}