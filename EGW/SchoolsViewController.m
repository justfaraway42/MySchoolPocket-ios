//
//  SchoolsViewController.m
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//


#import "SchoolsViewController.h"
#import "AppDelegate.h"


@implementation SchoolsViewController

@synthesize managedObjectContext, entityArray, entityName, entitySearchPredicate, currentSchool;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"initSchoolViewController"]) {
        
        entityName = @"State";
        [defaults setBool:NO forKey:@"initSchoolViewController"];
        [defaults synchronize]; // save state
    }
    if ([defaults boolForKey:@"changeSchool"]) {
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"buttonCancel", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(pushCancel)];
        self.navigationItem.leftBarButtonItem = doneButton;
        
        [defaults setBool:NO forKey:@"changeSchool"];
        [defaults synchronize]; // save state
    }
    
    if ([self.entityName isEqual: @"State"]) {
        self.title = NSLocalizedString(@"schoolsChooseState", NULL);
    } else if ([self.entityName isEqual: @"Community"]) {
        self.title = NSLocalizedString(@"schoolsChooseCommunity", NULL);
    } else if ([self.entityName isEqual: @"School"]) {
        self.title = NSLocalizedString(@"schoolsChooseSchool", NULL);
    } else if ([self.entityName isEqual: @"Class"]) {
        self.title = NSLocalizedString(@"schoolsChooseClass", NULL);
    }
    
	// Load locations if we havn't already done so
	if (self.entityArray == nil) {
		[self loadLocations];
	}
}

- (void)pushCancel {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) loadLocations{
	
	if(entitySearchPredicate == nil) {
		// Use the CoreDataHelper class to get all objects of the given
		// type sorted by the "name" key
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        // If a sort key was passed, use it for sorting.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
		self.entityArray = mutableFetchResults;
	}
	else
	{
		// Use the CoreDataHelper class to search for objects using
		// a given predicate, the result is sorted by the "Name" key
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        // predicate pass to the query
        [request setPredicate:entitySearchPredicate];
        
        // sorting.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
		self.entityArray = mutableFetchResults;
	}
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [entityArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *CellIdentifier = @"Cell";
	
	// Create a cell. It's important to differentiate between cells that have indicators and not. That's
	// why the CellIndentifier is changed if the cell has an indicator.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithDisclosure"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([self.entityName isEqual: @"Class"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = [entityArray objectAtIndex:indexPath.row];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [(NSManagedObject *)[entityArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.numberOfLines = 2;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self.entityName isEqual: @"Class"]) ? 46 : 64;
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	
	if ([self.entityName isEqual: @"State"] || [self.entityName isEqual: @"Community"]) {
		// Get the object the user selected from the array
		NSManagedObject *selectedObject = [entityArray objectAtIndex:indexPath.row];
		
		// Create a new table view of this very same class.
		SchoolsViewController *rootViewController = [[SchoolsViewController alloc]
                                                     initWithStyle:UITableViewStylePlain];
		
		// Pass the managed object context
		rootViewController.managedObjectContext = self.managedObjectContext;
		NSPredicate *predicate = nil;
        
		
		if ([self.entityName isEqual: @"State"]) {
            rootViewController.entityName = @"Community";
			
			// Create a query predicate to find all child objects of the selected object.
			predicate = [NSPredicate predicateWithFormat:@"(communityToState == %@)", selectedObject];
			
		} else if ([self.entityName isEqual: @"Community"]) {
			rootViewController.entityName = @"School";
            
			// Create a query predicate to find all child objects of the selected object.
			predicate = [NSPredicate predicateWithFormat:@"(schoolToCommunity == %@)", selectedObject];
		}
        [rootViewController setEntitySearchPredicate:predicate];
        
		//Push the new table view on the stack
		[self.navigationController pushViewController:rootViewController animated:YES];
	} else if ([self.entityName isEqual: @"School"]) {
        // Get the object the user selected from the array
        
        SchoolsViewController *rootViewController = [[SchoolsViewController alloc]
                                                     initWithStyle:UITableViewStylePlain];
        
        rootViewController.entityName = @"Class";
        rootViewController.currentSchool = [entityArray objectAtIndex:indexPath.row];
        
        NSArray *classesArray = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"lproj", NULL), @"/Timetables"] ofType:@"plist"]];
        
        rootViewController.entityArray = [classesArray valueForKey:@"name"];
        
		[self.navigationController pushViewController:rootViewController animated:YES];
        
    } else if ([self.entityName isEqual: @"Class"]) {
        
        // Get all articles
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        // Delete all Articles
        for (int i = 0; i < [mutableFetchResults count]; i++) {
            [managedObjectContext deleteObject:[mutableFetchResults objectAtIndex:i]];
        }
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]; // speichert
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSMutableString *userDocumentDir = [NSMutableString stringWithString:[paths objectAtIndex:0]];
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Timetables", userDocumentDir] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Representation", userDocumentDir] error:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:self.currentSchool.name forKey:@"school_name"];
        [defaults setValue:self.currentSchool.feed forKey:@"school_feed"];
        [defaults setValue:self.currentSchool.timetablesNames forKey:@"timetables_names"];
        [defaults setValue:self.currentSchool.timetablesUrls forKey:@"timetables_urls"];
        [defaults setValue:self.currentSchool.timetablesClasses forKey:@"timetables_classes"];
        [defaults setValue:self.currentSchool.representationUrls forKey:@"representation_urls"];
        [defaults setValue:self.currentSchool.phoneNumber forKey:@"phone_number"];
        [defaults setValue:self.currentSchool.website forKey:@"website"];
        [defaults setValue:self.currentSchool.emailAddress forKey:@"email_address"];
        [defaults setValue:self.currentSchool.address forKey:@"address"];
        
        NSArray *classesArray = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"lproj", NULL), @"/Timetables"] ofType:@"plist"]];
        [defaults setInteger:[(NSNumber *)[[classesArray valueForKey:@"value"] objectAtIndex:indexPath.row] integerValue] forKey:@"classLevel"];
        
        if ([[(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] selectedIndex] != 0) {
            [[(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:0];
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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


@end