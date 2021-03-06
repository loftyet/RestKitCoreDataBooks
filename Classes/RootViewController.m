/*
     File: RootViewController.m
 Abstract:  Abstract: The table view controller responsible for displaying the list of books, supporting additional functionality:
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "RootViewController.h"
#import "DetailViewController.h"
#import "Book.h"
#import "User.h"
#import "Tag+Addition.h"

@interface RootViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Tag *tag;
@end


#pragma mark -

@implementation RootViewController


#pragma mark - View lifecycle
- (void)loadData
{
//    NSDictionary *filter = @{@"--data-urlencode":@"include=tags"};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"classes/Book?include=tags&&include=user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        RKLogInfo(@"Load complete: Table should refresh...%@", mappingResult);
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];
    
}

//- (void)createAUser
//{
//    self.user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
//    self.user.username = @"LJiang6";
//    self.user.password = @"secret6";
//    self.user.email = @"ljiang6@ljapps.com";
//    
//    [[RKObjectManager sharedManager] postObject:self.user path:@"/1/users" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        RKLogInfo(@"so the user is : %@",self.user);
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Load failed with error: %@", error);
//    }];
//}

//-(void)loadUser
//{
//    
//    [[RKObjectManager sharedManager] getObjectsAtPath:@"/1/users" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        self.user = [mappingResult.array firstObject];
//        RKLogInfo(@"Load First User %@", self.user);
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Load failed with error: %@", error);
//    }];
//    
//}

-(void)creaeTag
{
    
    Tag *newTag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    newTag.name = @"Sci-Fi";
    [[RKObjectManager sharedManager] postObject:self.user path:@"/1/classes/tag" parameters:nil success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
//    [self createAUser];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self loadData];
}


- (void)viewWillAppear {
    
    [self.tableView reloadData];
}


- (void)viewDidUnload {
    
    // Release any properties that are loaded in viewDidLoad or can be recreated lazily.
    self.fetchedResultsController = nil;
}


#pragma mark - Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


#pragma mark - Table view editing

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // The table view should not be re-orderable.
    return NO;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
        self.rightBarButtonItem = nil;
    }
}


#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"author" ascending:YES];
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[authorDescriptor, titleDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}    


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
        {
           
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"AddBook"]) {
        
        /*
         The destination view controller for this segue is an AddViewController to manage addition of the book.
         This block creates a new managed object context as a child of the root view controller's context. It then creates a new book using the child context. This means that changes made to the book remain discrete from the application's managed object context until the book's context is saved.
          The root view controller sets itself as the delegate of the add controller so that it can be informed when the user has completed the add operation -- either saving or canceling (see addViewController:didFinishWithSave:).
         IMPORTANT: It's not necessary to use a second context for this. You could just use the existing context, which would simplify some of the code -- you wouldn't need to perform two saves, for example. This implementation, though, illustrates a pattern that may sometimes be useful (where you want to maintain a separate set of edits).
         */
        
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddViewController *addViewController = (AddViewController *)[navController topViewController];
        addViewController.delegate = self;
        
        // Create a new managed object context for the new book; set its parent to the fetched results controller's context.
//        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        [addingContext setParentContext:[self.fetchedResultsController managedObjectContext]];
        
//        Book *newBook = (Book *)[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:addingContext];
//        addViewController.book = newBook;
//        addViewController.managedObjectContext = addingContext;
        Book *newBook = (Book *)[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
        
//        newBook.user = self.user;
        addViewController.book = newBook;
        addViewController.managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowSelectedBook"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];

        // Pass the selected book to the new view controller.
        DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
        detailViewController.book = selectedBook;
    }    
}


#pragma mark - Add controller delegate

/*
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new book.
 */
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
    
    if (save) {
        
        /*
         The new book is associated with the add controller's managed object context.
         This means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad. Saving changes to that context, though, only push changes to the fetched results controller's context. To save the changes to the persistent store, you have to save the fetch results controller's context as well.
         */        
        NSError *error;
        NSManagedObjectContext *addingManagedObjectContext = [controller managedObjectContext];
        if (![addingManagedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    // Dismiss the modal view to return to the main list
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)deleteBook:(NSIndexPath *)indexPath
{
    Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *path = [NSString stringWithFormat:@"classes/Book/%@",selectedBook.objectId];
    [[RKObjectManager sharedManager] deleteObject:selectedBook path:path parameters:nil
                                          success:nil failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              RKLogError(@"Load failed with error: %@", error);
                                          }];
}

@end

