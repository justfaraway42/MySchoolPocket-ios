//
//  InfoView.m
//  Info
//
//  Created by Justus Dög on 14.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoTableCellView.h"
#import "InfoTableCellView7.h"


@implementation InfoViewController


// http://developer.apple.com/library/ios/#DOCUMENTATION/iPhone/Conceptual/iPhoneOSProgrammingGuide/Preferences/Preferences.html
// Creating and Modifying the Settings Bundle


#pragma mark -
#pragma mark View lifecycle

- (id)init {
    self = [super initWithNibName:@"InfoView" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    defaults = [NSUserDefaults standardUserDefaults];
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    self.title = NSLocalizedString(@"info", NULL);
    
    actionArray = [NSArray arrayWithObjects:NSLocalizedString(@"infoCall", NULL), NSLocalizedString(@"infoWeb", NULL), NSLocalizedString(@"infoMail", NULL), NSLocalizedString(@"infoNavigation", NULL), nil];
    descriptionArray = [NSArray arrayWithObjects:[defaults stringForKey:@"phone_number"], [defaults stringForKey:@"website"], [defaults stringForKey:@"email_address"], [defaults stringForKey:@"address"], nil];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

#pragma mark -
#pragma mark Mail Maodal View

- (void)showEmailModalView {
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self; // &lt;- very important step if you want feedbacks on what the user did with your email sheet
    
    [mailComposeViewController setSubject:@"MySchool App"];
    [mailComposeViewController setToRecipients:[NSArray arrayWithObject:[defaults stringForKey:@"email_address"]]];
    
    //mailComposeViewController.navigationBar.barStyle = UIBarStyleDefault; // set Style
    
    [self presentModalViewController:mailComposeViewController animated:YES];
    
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error { 
    // Notifies users about errors associated with the interface
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return nil;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [defaults stringForKey:@"school_name"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
        // iOS 7+
        static NSString *cellIdentifier = @"InfoTableCellView7"; // wir benennen die Zelle auch als CustomFileCell (Identifier = Klassenname)
        
        InfoTableCellView7 *cell = (InfoTableCellView7 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"InfoTableCellView7" owner:self options:nil] lastObject];
        }
        
        
        cell.actionLabel.text = [actionArray objectAtIndex:indexPath.row];
        
        cell.descriptionLabel.text = [descriptionArray objectAtIndex:indexPath.row];
        //    [cell.descriptionLabel sizeToFit];
        
        return cell;
    } else {
    
        static NSString *cellIdentifier = @"InfoTableCellView"; // wir benennen die Zelle auch als CustomFileCell (Identifier = Klassenname)
        
        InfoTableCellView *cell = (InfoTableCellView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"InfoTableCellView" owner:self options:nil] lastObject];
        }
        
        cell.actionLabel.text = [actionArray objectAtIndex:indexPath.row];
        
        cell.descriptionLabel.text = [descriptionArray objectAtIndex:indexPath.row];
        //    [cell.descriptionLabel sizeToFit];
        
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark Table view Menu

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                pasteboard.string = [[defaults stringForKey:@"phone_number"] mutableCopy];
            } else if (indexPath.row == 1) {
                pasteboard.string = [[defaults stringForKey:@"website"] mutableCopy];
            } else if (indexPath.row == 2) {
                pasteboard.string = [[defaults stringForKey:@"email_address"] mutableCopy];
            } else if (indexPath.row == 3) {
                pasteboard.string = [[defaults stringForKey:@"address"] mutableCopy];
            }
        }
    }
}

#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSString *urlString = nil; // clean it from before
        
        if (indexPath.row == 0) {
            NSMutableString *phone = [[defaults stringForKey:@"phone_number"] mutableCopy];
            [phone replaceOccurrencesOfString:@" " 
                                   withString:@"" 
                                      options:NSLiteralSearch 
                                        range:NSMakeRange(0, [phone length])];
            [phone replaceOccurrencesOfString:@"(" 
                                   withString:@"" 
                                      options:NSLiteralSearch 
                                        range:NSMakeRange(0, [phone length])];
            [phone replaceOccurrencesOfString:@")" 
                                   withString:@"" 
                                      options:NSLiteralSearch 
                                        range:NSMakeRange(0, [phone length])];
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:@"iPhone"] ) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", phone]]];
            } else {
                UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"alertDeviceNotSupported", NULL) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; //Title:NSLocalizedString(@"alertWarning", NULL)
                [Notpermitted show];
            }
            
        } else if (indexPath.row == 1) {
            urlString = [defaults stringForKey:@"website"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"	" withString:@""];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        } else if (indexPath.row == 2) { 
            [self showEmailModalView];
        } else if (indexPath.row == 3) {
            NSString *title = [defaults stringForKey:@"address"];
            
            if (([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)) {
                //iOS 6+
                urlString = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@", title];
            } else {
                urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", title];
            }
            
            //@Home
            //float latitude = 50.883530;
            //float longitude = 12.633120;
        }
        
        if (urlString) {
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@", urlString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

