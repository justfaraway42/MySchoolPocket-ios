//
//  PlansViewController.m
//  Timetables
//
//  Created by Justus Dög on 23.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "PlansViewController.h"
#import "AppDelegate.h"


@implementation PlansViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // aus dem aktuellen TabBarItem entnehmen wir nun den im Interface Builder festgelegten Tag
    selectedItemTag = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBar] selectedItem].tag;
    
    today = 0;
    names = [[NSMutableArray alloc] init];
    urls = [[NSMutableArray alloc] init];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if (selectedItemTag == 1) {
        
        self.title = NSLocalizedString(@"timetables", NULL);
        
        NSArray *allNames = [[defaults stringForKey:@"timetables_names"] componentsSeparatedByString:@";"];
        NSArray *allUrls = [[defaults stringForKey:@"timetables_urls"] componentsSeparatedByString:@";"];
        
        classes = [[defaults stringForKey:@"timetables_classes"] componentsSeparatedByString:@";"];
        
        NSLog(@"%@", allNames);
        NSLog(@"%@", allUrls);
        NSLog(@"%@", classes);
        
        for (int i = 0; i < [allNames count]; i++) {
            if ([defaults integerForKey:@"classLevel"] == [[classes objectAtIndex:i] integerValue]) {
                [names addObject:[allNames objectAtIndex:i]];
                [urls addObject:[allUrls objectAtIndex:i]];
            } else if ([defaults integerForKey:@"classLevel"] == 42) {
                [names addObject:[allNames objectAtIndex:i]];
                [urls addObject:[allUrls objectAtIndex:i]];
            }
        }
        [self.tableView reloadData];
        
    } else if (selectedItemTag == 2) {
        
        self.title = NSLocalizedString(@"representation", NULL);
        
        urls = [NSMutableArray arrayWithArray:[[defaults stringForKey:@"representation_urls"] componentsSeparatedByString:@";"]];
        
        if ([urls count] == 5) {
            NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
            [weekdayFormatter setDateFormat: @"EEEE"];
            
            NSArray *weekdays = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", nil];
            
            for (int i = 0; i < [weekdays count]; i++) {
                
                [weekdayFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-UK"] ]; // wir interpretieren die oben eingesetzten Wochentage mit dem englischen Lokalitäts-Identifier (da sie ja englisch sind)
                NSDate *weekdayDate = [weekdayFormatter dateFromString:[weekdays objectAtIndex:i]]; // auf diese Weise erhalten wir ein NSDate, welches auf den jeweiligen Wochentag zeigt (hier immer gegen 1970)
                
                [weekdayFormatter setLocale:[NSLocale currentLocale]]; // setzt die aktuelle System-Localisierung für den NSDateFormatter
                
                [names addObject:[weekdayFormatter stringFromDate:weekdayDate]]; // das so erstellte Datum wird mit dem NSDateFormatter in einen lokalisierten Wochentag umgewandelt und für die jeweiligeStelle im Array genutzt
                
                if ([[names objectAtIndex:i] isEqual:[weekdayFormatter stringFromDate:[NSDate date]]] && [defaults boolForKey:@"todaySwitch"]) {
                    
                    today = i+1; // today = i + 1, da sonst am Montag today = 0 (NULL) wäre || Montags: today = 1,...
                }
            }
            
            if ([defaults boolForKey:@"todaySwitch"] && today) {
                NSObject *moveObject;
                
                for (int i = 1; i < today; i++) {
                    // sorting Array...
                    moveObject = [names objectAtIndex:0];
                    [names removeObject:[names objectAtIndex:0]];
                    [names addObject:moveObject];
                    
                    moveObject = [urls objectAtIndex:0];
                    [urls removeObject:[urls objectAtIndex:0]];
                    [urls addObject:moveObject];
                }
            }
        } else {
            names = [NSMutableArray arrayWithObject:NSLocalizedString(@"plansToday", NULL)];
        }
        [self.tableView reloadData];
    }
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];
 }
*/
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

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return ([defaults boolForKey:@"todaySwitch"] && selectedItemTag == 2 && today) ? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (selectedItemTag == 1) {
        return ([defaults integerForKey:@"classLevel"] != 42) ? [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"plansClass", NULL), [defaults stringForKey:@"classLevel"]] : NSLocalizedString(@"plansAllClasses", NULL);
    } else if ([defaults boolForKey:@"todaySwitch"] && selectedItemTag == 2 && today && [urls count] == 5) {
        return (section == 0) ? NSLocalizedString(@"plansToday", NULL) : NSLocalizedString(@"plansRestWeek", NULL);
    } else if (selectedItemTag == 2) {
        return ([urls count] == 5) ? NSLocalizedString(@"plansWeekOverview", NULL): NSLocalizedString(@"plansToday", NULL);
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ([defaults boolForKey:@"todaySwitch"] && selectedItemTag == 2 && today) {
        return (section == 0) ? 1 : 4;
    } else {
        return [names count];
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Pfeil
    }
    
    // Configure the cell...
        
    if ([defaults boolForKey:@"todaySwitch"] && selectedItemTag == 2 && today && indexPath.section == 1) {
        cell.textLabel.text = [names objectAtIndex:indexPath.row+1];
    } else {
        cell.textLabel.text = [names objectAtIndex:indexPath.row];
    }
    
    return cell;
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
    
    NSString *selectedCellName = nil;
    NSString *selectedCellURL = nil;
	
    if ([defaults boolForKey:@"todaySwitch"] && selectedItemTag == 2 && today && indexPath.section == 1) {
        selectedCellName = [names objectAtIndex:indexPath.row+1];
        selectedCellURL = [urls objectAtIndex:indexPath.row+1];
    } else {
        //get selected cell
        selectedCellName = [names objectAtIndex:indexPath.row];
        selectedCellURL = [urls objectAtIndex:indexPath.row];
    }

    // je nachdem, welcher Stundenplan angeklickt wird, wird er als *.pdf in der App gespeichert
    
	//Init the detail view controller nd display it like!
    PlansDetailViewController *nextController = [[PlansDetailViewController alloc] initWithNibName:@"PlansDetailView" bundle:[NSBundle mainBundle]];
    
    nextController.currentName = selectedCellName;
    nextController.currentURL = selectedCellURL;
    // hier werden die oben ausgelesenen Daten (Name, URL und File) an den "nächsten Controller" (PlansDetailViewController) mit den jeweiligen Variablen (currentName, currentURL, currentFile) übergeben
    
    NSLog(@"%@", selectedCellURL);
    
    //hide tabbar
    nextController.hidesBottomBarWhenPushed = YES;
    
    //add it to stack.
	[self.navigationController pushViewController:nextController animated:YES];
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

