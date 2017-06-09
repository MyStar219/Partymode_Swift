//
//  APAddressBookAccessRoutine
//  AddressBook
//
//  Created by Alexey Belkevich on 21.09.15.
//  Copyright © 2015 alterplay. All rights reserved.
//

#import <AddressBook/ABAddressBook.h>
#import "APAddressBookAccessRoutine.h"
#import "APAddressBookRefWrapper.h"

@implementation APAddressBookAccessRoutine

#pragma mark - public

+ (APAddressBookAccess)accessStatus
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            return APAddressBookAccessDenied;

        case kABAuthorizationStatusAuthorized:
            return APAddressBookAccessGranted;

        default:
            return APAddressBookAccessUnknown;
    }
}

- (void)requestAccessWithCompletion:(void (^)(BOOL granted, NSError *error))completionBlock
{
    ABAddressBookRequestAccessWithCompletion(self.wrapper.ref, ^(bool granted, CFErrorRef errorRef)
    {
        NSError *error = (__bridge NSError *)errorRef;
        if (!error && !granted)
        {
            error = self.accessDeniedError;
            dispatch_async(dispatch_get_main_queue(), ^{
                // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                //"To re-enable, please go to Settings and turn on Contact permission for this app."
                
                NSString *contactPermission = [[NSUserDefaults standardUserDefaults]
                                        stringForKey:@"contactPermission"];
                
                if ([contactPermission isEqualToString:@"denied"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Contact permission disabled!" message:NSLocalizedString(@"contact_settings_alert", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"settings", @"") otherButtonTitles:NSLocalizedString(@"cancel", @""), nil];
                    
                    alertView.tag = 200;
                    [alertView show];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Partymode" message:NSLocalizedString(@"alert_disabled_contact_permission", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    alertView.tag = 100;
                    [alertView show];
                    
                    NSString *valueToSave = @"denied";
                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"contactPermission"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            });
        }
        completionBlock ? completionBlock(granted, error) : nil;
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        if (buttonIndex == 0)
        {
            //Code for OK button
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"notification_goToLogin"
             object:self];
        }
    }
    else if (alertView.tag == 200)
    {
        if (buttonIndex == 0)
        {
            //Code for Settings button
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        if (buttonIndex == 1)
        {
            //Code for Cancel button
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"notification_goToLogin"
             object:self];
        }
    }
}
#pragma mark - Private

- (NSError *)accessDeniedError
{
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey:
                               @"Address book access has been denied by user"};
    return [[NSError alloc] initWithDomain:@"APAddressBookErrorDomain" code:101 userInfo:userInfo];
}

@end
