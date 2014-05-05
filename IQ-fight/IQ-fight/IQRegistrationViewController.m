//
//  IQRegistrationViewController.m
//  IQ-fight
//
//  Created by Petar Antonov on 5/5/14.
//  Copyright (c) 2014 Petar Antonov. All rights reserved.
//

#import "IQRegistrationViewController.h"
#import "IQAppDelegate.h"
#import "IQServerCommunication.h"
#import "IQSettings.h"
#import "NSString+RegularExpressions.h"

@interface IQRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

@end

@implementation IQRegistrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)createButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    if (![self.usernameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] && ![self.repeatPasswordTextField.text isEqualToString:@""]) {
     
        if ([self.usernameTextField.text isValidEmail]) {
            
            if ([self.passwordTextField.text isEqualToString:self.repeatPasswordTextField.text]) {
                [[IQSettings sharedInstance] showHud:@"" onView:self.view];
                
                IQServerCommunication *sc = [[IQServerCommunication alloc] init];
                [sc createRegistrationWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text withCompetionBlock:^(id result, NSError *error) {
                    
                    if (result) {
                        if (![result[@"username"] isEqualToString:@""]) {
                            [IQSettings sharedInstance].currentUser.username = result[@"username"];
                            
                            [[IQSettings sharedInstance] hideHud:self.view];
                            
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                            UINavigationController *navViewController = [storyboard instantiateViewControllerWithIdentifier:@"homeRoot"];
                            IQAppDelegate *delegate = [UIApplication sharedApplication].delegate;
                            delegate.window.rootViewController = navViewController;
                        } else {
                            //kakvo stava akop username-a e prazen?
                            [[IQSettings sharedInstance] hideHud:self.view];
                            [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
                        }
                    } else {
                        [[IQSettings sharedInstance] hideHud:self.view];
                        [self showAlertWithTitle:@"Error" message:[error localizedDescription] cancelButton:@"OK"];
                    }
                }];
            } else {
                [self showAlertWithTitle:@"Error" message:@"Passwords doesn't match." cancelButton:@"OK"];
            }
        } else {
            [self showAlertWithTitle:@"Error" message:@"Email isn't valid." cancelButton:@"OK"];
        }
    } else {
        [self showAlertWithTitle:@"Error" message:@"Empty fields." cancelButton:@"OK"];
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alert show];
}

@end
