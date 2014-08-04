//
//  MGViewController.m
//  MindGame
//
//  Created by Anup Das on 04/08/14.
//  Copyright (c) 2014 anup. All rights reserved.
//

#import "MGViewController.h"
#import "MGPhotoCell.h"
#import "MGImageDO.h"
#import "MGAppUtil.h"

@interface MGViewController ()
{
    int timeToDisplay;
    
}
//hold unique name for the image and ImageDO object
@property (strong, nonatomic) NSMutableDictionary *imagesDictionary;
@property (strong, nonatomic) NSMutableArray *correctAnswersArray;
@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSMutableData* data;
@property (strong, nonatomic) NSTimer *batchTimer;
@property (strong, nonatomic) NSTimer *matchTimer;
@property (strong, nonatomic) MGImageDO *questionImageDO;
@property (assign, nonatomic) BOOL gameStarted;
@property (assign, nonatomic) int numberofattampts;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *questionImage;
@property (weak, nonatomic) IBOutlet UILabel *numberOfTries;


@end

@implementation MGViewController

#define DEFAULT_CARD_IMAGE @"backofthecard.jpg"
#define kNetworkConnectionTimeout   60
#define NUMBER_OF_IMAGES 9
#define URL_IMAGE @"https://api.flickr.com/services/feeds/photos_public.gne?format=json&per_page=9&page=0&nojsoncallback=1&ids=123489520@N02"

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MGPhotoCell" bundle:nil] forCellWithReuseIdentifier:@"MGPhotoCell"];
    
    [self setDefaultSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MGPhotoCell";
    MGPhotoCell *cell = (MGPhotoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.asyncImageView.image=nil;
    NSLog(@"%d - %d",indexPath.section,indexPath.item);
    if (self.imagesDictionary!=nil) {
        //pick from the cache
        MGImageDO *doObj = [self.imagesDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.item+1]];
        if ((doObj != (id)[NSNull null] && doObj!=nil) && !self.gameStarted) {
            [cell setWithImageDO:doObj delegate:doObj];
        }
        else{
            //show back of the card
            if (self.gameStarted ) {
                if (doObj != (id)[NSNull null] && doObj!=nil){
                    if(doObj.hasBeenIdentified){
                       [cell setWithImageDO:doObj delegate:doObj];
                    }else{
                        [cell.asyncImageView setImage:[UIImage imageNamed:DEFAULT_CARD_IMAGE]];
                    }
                }
            }
            else
                [cell.asyncImageView setImage:[UIImage imageNamed:DEFAULT_CARD_IMAGE]];
        }
    }
    else{
        //show back of the card
        [cell.asyncImageView setImage:[UIImage imageNamed:DEFAULT_CARD_IMAGE]];
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200 , 250);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.gameStarted) {
        self.numberofattampts++;
        self.numberOfTries.text = [NSString stringWithFormat:@"Number Of Tries: %d",self.numberofattampts];
        
        if (self.imagesDictionary!=nil) {
            MGImageDO *doObj = [self.imagesDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.item+1]];
            if (doObj!=nil && doObj != (id)[NSNull null]) {
                if ([doObj isEqual:self.questionImageDO]) {
                    doObj.hasBeenIdentified = YES;
                }else{
                    doObj.hasBeenIdentified = NO;
                }
                
                
                MGPhotoCell *cell = (MGPhotoCell*) [collectionView cellForItemAtIndexPath:indexPath];
                if (!doObj.hasBeenIdentified) {
                    //show back of the card
                    
                    [UIView transitionWithView:cell
                                      duration:1.0f
                                       options:UIViewAnimationOptionTransitionFlipFromLeft
                                    animations:^{
                                        [cell.asyncImageView setImage:[UIImage imageNamed:DEFAULT_CARD_IMAGE]];
                                    }
                                    completion:nil
                     ];
                    
                    
                }else{
                    [UIView transitionWithView:cell
                                      duration:1.0f
                                       options:UIViewAnimationOptionTransitionFlipFromRight
                                    animations:^{
                                        [cell setWithImageDO:doObj delegate:doObj];
                                    }
                                    completion:^(BOOL finished){
                                        if (finished) {
                                            // Successful
                                            NSLog(@"Animations completed.");
                                            
                                            [self.correctAnswersArray addObject:doObj];
                                            [self presentNewQuestionImage];
                                            
                                        }
                                        
                                    }
                     ];
                    
                    
                }
            }
        }
    }
}


#pragma mark - NSURLConenction Delegate Methods
- (void)cancelSync {
    if (self.connection) {
        [self.connection cancel];
    }
}
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (self.data==nil) {
		self.data = [[NSMutableData alloc] initWithCapacity:512];
    }
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection
{
    self.connection = nil;
	
    if (self.data!=nil) {
        //NSString *stringResponse = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        
        NSError *errorData;
        NSDictionary* dictionary = [NSJSONSerialization
                                    JSONObjectWithData:self.data
                                    options:NSJSONReadingAllowFragments
                                    error:&errorData];
        
        if (errorData==nil && dictionary !=nil) {
            // parse the dict
            
            NSArray *items = [dictionary objectForKey:@"items"];
            if (items!=nil && [items count]>=9) {
                NSArray *mediaURLArray = [items valueForKeyPath:@"media.m"];
                
                for (int iterationNumber = 1;iterationNumber<=NUMBER_OF_IMAGES;iterationNumber++) {
                    NSString *uniqueID = [MGAppUtil uniqueID];
                    
                    MGImageDO *imgDO = [[MGImageDO alloc] init];
                    imgDO.imageName = uniqueID;
                    imgDO.serverDownlaodStringURL = [NSString stringWithFormat:@"%@", [mediaURLArray objectAtIndex:iterationNumber] ];
                    imgDO.localDownloadStringURL = [NSString stringWithFormat:@"%@/Downloaded/%@.jpg",[MGAppUtil GetDocumentDirectoryPath],uniqueID];
                    
                    [self.imagesDictionary setObject:imgDO forKey:[NSString stringWithFormat:@"%d",iterationNumber]];
                }
                
            }
            [self.collectionView reloadData];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network issue" message:@"There was an unexpected response from the server. Please try again after some time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }

        
    }
}

-(void)showPopup
{
    int countOfFiles = 0;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Downloaded/"]];
    NSArray *filelist= [filemgr contentsOfDirectoryAtPath:imagePath error:&error];
    if (error==nil && [filelist count]>0) {
        countOfFiles = [filelist count];
        NSLog (@"countOfFiles--> %d",countOfFiles);
        
        if (countOfFiles ==9) {
            [self.batchTimer invalidate];
            self.batchTimer = nil;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions" message:@"You need to memorize the image location before counter hits 15!!! You will have to guess the correct location of presented image.Tap and see how much can you memorize." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 1234;
            [alert show];
            return;
        }
    }
    
}

#pragma mark - UIAlterView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch (alertView.tag) {
        case 1234:
        {
            if (buttonIndex== alertView.cancelButtonIndex) {
                [self startBatchTimer];
            }
            
            break;
        }
        case 321:
        {
            [self setDefaultSettings];
            
            break;
        }
        
        case 123:
        {
            if (buttonIndex== alertView.cancelButtonIndex) {
                if (self.gameStarted) {
                    
                    timeToDisplay=0;
                    
                    [self.matchTimer invalidate];
                    self.matchTimer = nil;
                    self.matchTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                       target:self
                                                                     selector:@selector(updateMatchTime)
                                                                     userInfo:nil
                                                                      repeats:YES];
                }else{
                    [self.matchTimer invalidate];
                    self.matchTimer = nil;
                }
                
                [self presentNewQuestionImage];
            }
            
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - Custom Methods

-(void)setDefaultSettings
{
    
    //networks defaults
    self.data = nil;
    [self.connection cancel];
    self.connection=nil;
    
    // set the labels
    self.numberofattampts=0;
    self.numberOfTries.text = [NSString stringWithFormat:@"Number Of Tries: %d",self.numberofattampts];
    timeToDisplay=0;
    self.timeLabel.text=@"";
    
    //set correct and image array to empty
    [self.correctAnswersArray removeAllObjects];
    [self.imagesDictionary removeAllObjects];
    if (self.correctAnswersArray==nil) {
        self.correctAnswersArray = [[NSMutableArray alloc] init];
    }
    if (self.imagesDictionary==nil) {
        self.imagesDictionary= [[NSMutableDictionary alloc] initWithCapacity:NUMBER_OF_IMAGES];
    }
    
    [self.collectionView reloadData];
    
    //reset the question image and questionimagedo
    self.questionImageDO=nil;
    [self.questionImage setImage:[UIImage imageNamed:DEFAULT_CARD_IMAGE]];
    
    //reset game started to No
    self.gameStarted=NO;
    
    //delete exisitng images from background
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^(void) {
        MGImageHandler *handler = [[MGImageHandler alloc] init];
        [handler deleteDownloadedCacheDirectory];
        
    });
    
    
    
    //reset the batch timer
    [self.batchTimer invalidate];
	self.batchTimer = nil;
    self.batchTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(showPopup)
                                                     userInfo:nil
                                                      repeats:YES];
    
    dispatch_queue_t backgroundQueue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue1, ^(void) {
        
        //create the dict with nsnull object
        for (int iterationNumber = 1;iterationNumber<=NUMBER_OF_IMAGES ;iterationNumber++ ) {
            [self.imagesDictionary setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%d",iterationNumber]];
            
        }
        
        NSURL *urlString = [NSURL URLWithString:URL_IMAGE];
        NSURLRequest* request = [NSURLRequest requestWithURL:urlString
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:kNetworkConnectionTimeout];
		
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.connection start];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        
    });
}

-(void)startBatchTimer
{
    self.timeLabel.text=@"";
    [self.batchTimer invalidate];
	self.batchTimer = nil;
    self.batchTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateTime)
                                                userInfo:nil
                                                 repeats:YES];
    
}

-(void)updateTime
{
    if (timeToDisplay<15) {
        [self.timeLabel setText:[NSString stringWithFormat:@"%d",timeToDisplay]];
        timeToDisplay++;
        
    }
    else if (timeToDisplay==15){
        [self.timeLabel setText:[NSString stringWithFormat:@"%d",timeToDisplay]];
        
        [self.batchTimer invalidate];
        self.batchTimer = nil;

        
        [self performSelector:@selector(flipAllImages)];
        
    }
    
    else{
        [self.batchTimer invalidate];
        self.batchTimer = nil;
    }
    
}

-(void)updateMatchTime
{
    if (self.gameStarted) {
        [self.timeLabel setText:[NSString stringWithFormat:@"%d",timeToDisplay]];
        timeToDisplay++;
    }else{
        [self.matchTimer invalidate];
        self.matchTimer = nil;
    }
    
    
}

-(void)flipAllImages
{
    self.gameStarted = YES;
    
    NSArray *images = [self.imagesDictionary allValues];
    for (MGImageDO *imgDo in images) {
        imgDo.hasBeenIdentified = NO;
    }
    
    [self.collectionView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Started" message:@"Game has begun!!! All the best." delegate:self cancelButtonTitle:@"Play" otherButtonTitles:nil, nil];
    alert.tag = 123;
    [alert show];
    
}

-(void)presentNewQuestionImage
{
    @autoreleasepool {
        if ([self.correctAnswersArray count]>=NUMBER_OF_IMAGES) {
            self.gameStarted=NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"Well Done!!!" delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:@"Re Match", nil];
            alert.tag = 321;
            [alert show];
            
            return;
        }
        int minvalue = 1; //Get the current text from your minimum and maximum textfields.
        int maxValue = NUMBER_OF_IMAGES+1;
        
        int randomItem = arc4random_uniform(10) % (maxValue - minvalue) + minvalue; //create the random number.
        NSLog(@"randomItem--> %d",randomItem);
        
        if (randomItem==0 && randomItem>9) {
            [self presentNewQuestionImage];
            return;
        }
        
        if (self.gameStarted) {
            MGImageHandler *handler = [[MGImageHandler alloc] init];
            self.questionImageDO = [self.imagesDictionary objectForKey:[NSString stringWithFormat:@"%d",randomItem]];
            
            if (self.questionImage!=nil) {
                //check if its already answered
                NSArray *alreadyAnswered = [self.correctAnswersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imageName = %@",self.questionImageDO.imageName]];
                if (alreadyAnswered !=nil && [alreadyAnswered count]==0) {
                    UIImage *img = [handler getImageFromDownloadedCache:self.questionImageDO.imageName];
                    [self.questionImage setImage:img];
                }else{
                    [self presentNewQuestionImage];
                }
                
            }else{
                [self presentNewQuestionImage];
            }
            
        }else{
            self.questionImageDO=nil;
            [self.questionImage setImage:[UIImage imageNamed:DEFAULT_CARD_IMAGE]];
        }
    }
    
}

@end
