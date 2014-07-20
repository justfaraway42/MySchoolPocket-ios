//
//  SettingsView.m
//  Info
//
//  Created by Justus Dög on 14.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "SettingsViewController.h"
#import "SwitchTableCell.h"
#import "SwitchTableCell7.h"
#import "ReminderViewController.h"
#import "PickerViewController.h"
#import "SchoolsViewController.h"
#import "NewsViewController.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "UINavigationControllerPortrait.h"


@implementation SettingsViewController

// http://developer.apple.com/library/ios/#DOCUMENTATION/iPhone/Conceptual/iPhoneOSProgrammingGuide/Preferences/Preferences.html
// Creating and Modifying the Settings Bundle


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // set section Headers
    sectionHeaders = [NSMutableArray arrayWithObjects: NSLocalizedString(@"news", NULL), NSLocalizedString(@"timetables", NULL), NSLocalizedString(@"representation", NULL), NSLocalizedString(@"settingsChangeSchool", NULL), NSLocalizedString(@"settingsAboutApp", NULL), nil]; //", @"<developer settings>""
    // strong, da wir es dauerhaft im TableView benötigen (ansonsten stürzt es ab)
    
    self.title = NSLocalizedString(@"settings", NULL);
    
    [self.tableView reloadData];
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
#pragma mark Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (section == 0) ? 3 : (section == 1) ? 2 : (section == 2) ? 2 : (section == 3) ? 1 : (section == 4) ? 1 : 0; //": (section == 4) ? 2 : 0"
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return /*(section == 5) ? @"If \"Remember Me\" is enabled, you are reminded every day of the week on possible changes." :*/ nil;
    
    // @"Wenn \"Erinnere Mich\" aktiviert ist, werden Sie jeden Wochentag an mögliche Änderungen erinnert."
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            static NSString *cellIdentifier;
            
            if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
                // iOS 7+
                cellIdentifier = @"SwitchTableCell7";
                SwitchTableCell7 *cell = (SwitchTableCell7 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell7" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsReloadOnStartup", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"reloadSwitch"];
                [cell.changeSwitch addTarget:self action:@selector(reloadOnStartup:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone; // Zelle wird nicht blau, wenn man darauf drückt
                
                return cell;
            } else {
                cellIdentifier = @"SwitchTableCell";
                SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsReloadOnStartup", NULL);
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
                cell.changeSwitch.on = [defaults boolForKey:@"reloadSwitch"];
                [cell.changeSwitch addTarget:self action:@selector(reloadOnStartup:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone; // Zelle wird nicht blau, wenn man darauf drückt
                
                return cell;
            }
            
        } else if (indexPath.row == 1) {
            static NSString *cellIdentifier;
            
            if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
                // iOS 7+
                cellIdentifier = @"SwitchTableCell7";
                SwitchTableCell7 *cell = (SwitchTableCell7 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell7" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsShowBadge", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"badgeSwitch"];
                [cell.changeSwitch addTarget:self action:@selector(showBadge:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                cellIdentifier = @"SwitchTableCell";
                SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsShowBadge", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"badgeSwitch"];
                [cell.changeSwitch addTarget:self action:@selector(showBadge:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        } else if (indexPath.row == 2) {
            NSString *cellIdentifier = @"CellIdentifier";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Pfeil
                
            cell.textLabel.text = NSLocalizedString(@"settingsMaximumArticles", NULL);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [defaults integerForKey:@"maxArticles"]];
            
            return cell;
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            NSString *cellIdentifier = @"CellIdentifier";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Pfeil
            
            cell.textLabel.text = NSLocalizedString(@"settingsClassLevel", NULL);
            
            NSInteger detailTextLabelIndex = 0;
            
            if ([defaults integerForKey:@"classLevel"] == 42) {
                detailTextLabelIndex = 8;
            } else {
                detailTextLabelIndex = [defaults integerForKey:@"classLevel"]-5;
            }
            
            cell.detailTextLabel.text = [[[[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"lproj", NULL), @"/Timetables"] ofType:@"plist"]] valueForKey:@"name"] objectAtIndex:detailTextLabelIndex];
            
            return cell;
        } else if (indexPath.row == 1) {
            
            static NSString *cellIdentifier;
            
            if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
                // iOS 7+
                cellIdentifier = @"SwitchTableCell7";
                SwitchTableCell7 *cell = (SwitchTableCell7 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell7" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsLoadManually", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"loadTimetablesManually"];
                [cell.changeSwitch addTarget:self action:@selector(loadTimetablesManually:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                cellIdentifier= @"SwitchTableCell";
                SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsLoadManually", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"loadTimetablesManually"];
                [cell.changeSwitch addTarget:self action:@selector(loadTimetablesManually:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            
            static NSString *cellIdentifier;
            
            if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
                // iOS 7+
                cellIdentifier = @"SwitchTableCell7";
                SwitchTableCell7 *cell = (SwitchTableCell7 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell7" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsTodayFirst", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"todaySwitch"];
                [cell.changeSwitch addTarget:self action:@selector(showTodayFirst:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                cellIdentifier= @"SwitchTableCell";
                SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsTodayFirst", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"todaySwitch"];
                [cell.changeSwitch addTarget:self action:@selector(showTodayFirst:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        } else if (indexPath.row == 1) {
            
            static NSString *cellIdentifier;
            
            if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
                // iOS 7+
                cellIdentifier = @"SwitchTableCell7";
                SwitchTableCell7 *cell = (SwitchTableCell7 *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell7" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsLoadManually", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"loadRepresentationManually"];
                [cell.changeSwitch addTarget:self action:@selector(loadRepresentationManually:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                cellIdentifier= @"SwitchTableCell";
                SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell" owner:self options:nil] lastObject];
                
                cell.textLabel.text = NSLocalizedString(@"settingsLoadManually", NULL);
                cell.changeSwitch.on = [defaults boolForKey:@"loadRepresentationManually"];
                [cell.changeSwitch addTarget:self action:@selector(loadRepresentationManually:) forControlEvents:UIControlEventValueChanged];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
        }
    } else if (indexPath.section == 3) {
        
        NSString *cellIdentifier = @"CellIdentifier";
        
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Pfeil
        
        if (indexPath.row == 0) {
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"settingsChangeSchool", NULL);
        }
        
        return cell;
        
    }  else if (indexPath.section == 4) {
        
        NSString *cellIdentifier = @"CellIdentifier";
        
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Pfeil
        
        if (indexPath.row == 0) {
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"settingsAboutApp", NULL);
        }
        
        return cell;
        
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            NSString *cellIdentifier = @"CellIdentifier";
            
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Pfeil
            }
            
            cell.textLabel.text = @"Set Reminder";
            
        } else if (indexPath.row == 1) {
        
            static NSString *cellIdentifier = @"SwitchTableCell";
            
            SwitchTableCell *cell = (SwitchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SwitchTableCell" owner:self options:nil] lastObject];
            }
            
            cell.textLabel.text = @"Remind Me";
            cell.changeSwitch.enabled = NO;
            cell.changeSwitch.on = [defaults boolForKey:@"remindSwitch"];
            [cell.changeSwitch addTarget:self action:@selector(remindMe:) forControlEvents:UIControlEventValueChanged];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone; // Zelle wird nicht blau, wenn man darauf drückt
            
            return cell;
        }
    }
    
    return nil; // wenn indexPath.selection nicht 0 oder 1 ist, wird keine Zelle zurückgegeben
}

#pragma mark -
#pragma mark NSUserDefaults

- (void)reloadOnStartup:(UISwitch *)reloadSwitch {
    [defaults setBool:reloadSwitch.on forKey:@"reloadSwitch"];
    [defaults synchronize]; // save state
}

- (void)showBadge:(UISwitch *)badgeSwitch {
    [defaults setBool:badgeSwitch.on forKey:@"badgeSwitch"];
    [defaults synchronize];
}

- (void)loadTimetablesManually:(UISwitch *)reloadSwitch {
    [defaults setBool:reloadSwitch.on forKey:@"loadTimetablesManually"];
    [defaults synchronize];
}

- (void)showTodayFirst:(UISwitch *)todaySwitch {
    [defaults setBool:todaySwitch.on forKey:@"todaySwitch"];
    [defaults synchronize];
}

- (void)loadRepresentationManually:(UISwitch *)reloadSwitch {
    [defaults setBool:reloadSwitch.on forKey:@"loadRepresentationManually"];
    [defaults synchronize];
}

- (void)remindMe:(UISwitch *)remindSwitch {
    [defaults setBool:remindSwitch.on forKey:@"remindSwitch"];
    [defaults synchronize];
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
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            
            PickerViewController *pickerView = [[PickerViewController alloc] init];
            
            pickerView.key = @"maxArticles";
            pickerView.array = [[NSMutableArray alloc] initWithObjects:@"10", @"15", @"20", @"25", @"30", nil];
            
            //hide tabbar
            pickerView.hidesBottomBarWhenPushed = YES;
            
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:pickerView animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            PickerViewController *pickerView = [[PickerViewController alloc] init];
            
            pickerView.key = @"classLevel";
            pickerView.array = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"lproj", NULL), @"/Timetables"] ofType:@"plist"]];
            
            //hide tabbar
            pickerView.hidesBottomBarWhenPushed = YES;
            
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:pickerView animated:YES];

        }
    } else if (indexPath.section == 3) {
        
        if (indexPath.row == 0) {
            NSURL *xmlURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"xml"]];
            
            NSError *parseError = nil;
            
            // Parse the xml and store the results in our object model
            LocationsParser *xmlParse = [[LocationsParser alloc] init];
            [xmlParse parseXMLFileAtURL:xmlURL parseError:&parseError];
            
            SchoolsViewController *addController = [[SchoolsViewController alloc] initWithNibName:@"SchoolsView" bundle:nil];
            
            [defaults setBool:YES forKey:@"initSchoolViewController"];
            [defaults setBool:YES forKey:@"changeSchool"];
            [defaults synchronize]; // save state
            
            // This is where you wrap the view up nicely in a navigation controller
            UINavigationController *navigationController = [[UINavigationControllerPortrait alloc] initWithRootViewController:addController];
            
            // And now you want to present the view in a modal fashion all nice and animated
            [self presentModalViewController:navigationController animated:YES];
        }
    } else if (indexPath.section == 4) {
        
        if (indexPath.row == 0) {
            NSURL *xmlURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"xml"]];
            
            NSError *parseError = nil;
            
            // Parse the xml and store the results in our object model
            LocationsParser *xmlParse = [[LocationsParser alloc] init];
            [xmlParse parseXMLFileAtURL:xmlURL parseError:&parseError];
            
            AboutViewController *addController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
            
            // This is where you wrap the view up nicely in a navigation controller
            UINavigationController *navigationController = [[UINavigationControllerPortrait alloc] initWithRootViewController:addController];
            
            // And now you want to present the view in a modal fashion all nice and animated
            [self presentModalViewController:navigationController animated:YES];
        }
    } else if (indexPath.section == 5) {
        
        if (indexPath.row == 0) {
            ReminderViewController *reminderView = [[ReminderViewController alloc] init];
            
            //hide tabbar
            reminderView.hidesBottomBarWhenPushed = YES;
            
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:reminderView animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // clears Selection
    self.clearsSelectionOnViewWillAppear = YES;
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

