//
//  ViewController.m
//  passalongtale
//
//  Created by Jake Gundersen on 10/6/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ViewController.h"

@implementation ViewController
@synthesize statusLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    textInputField.delegate = self;
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    
    textInputField.enabled = NO;
    statusLabel.text = @"Welcome.  Press Game Center to get started";
}

- (void)viewDidUnload
{
    
    [mainTextController release];
    mainTextController = nil;
    [inputView release];
    inputView = nil;
    [textInputField release];
    textInputField = nil;
    [characterCountLabel release];
    characterCountLabel = nil;
    [self setStatusLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    NSLog(@"text view up");
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (IBAction)presentGCTurnViewController:(id)sender 
{
    [[GCTurnBasedMatchHelper sharedInstance]findMatchWithMinPlayers:2 maxPlayers:12 viewController: self];
}

- (IBAction)sendTurn:(id)sender 
{
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSString *newStoryString;
    
    if ([textInputField.text length] > 250) 
    {
        newStoryString = [textInputField.text substringToIndex:249];
    } 
    else 
    {
        newStoryString = textInputField.text;
    }
    
    NSString *sendString = [NSString stringWithFormat:@"%@ %@", mainTextController.text, newStoryString];
    NSData *data = [sendString dataUsingEncoding:NSUTF8StringEncoding ];
    
    mainTextController.text = sendString;
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
    NSUInteger nextIndex = (currentIndex + 1) % [currentMatch.participants count];
    
    nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    for (int i = 0; i < [currentMatch.participants count]; i++) 
    {
        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1 + i) % [currentMatch.participants count ])];
        
        if (nextParticipant.matchOutcome != 
            GKTurnBasedMatchOutcomeQuit) {
            break;
        } 
    }
    
    [currentMatch endTurnWithNextParticipant:nextParticipant matchData:data completionHandler:^(NSError *error) 
     {
         if (error) 
         {
            NSLog(@"%@", error);
            statusLabel.text = @"Oops, there was a problem.  Try that again.";
         } 
         else 
         {
            statusLabel.text = @"Your turn is over.";
            textInputField.enabled = NO;
         }
     }];
    
    NSLog(@"Send Turn, %@, %@", data, nextParticipant);
    textInputField.text = @"";
    characterCountLabel.text = @"250";
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 210; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    int textFieldMovement = movement * 0.75;
    inputView.frame = CGRectOffset(inputView.frame, 0, movement);
    mainTextController.frame = CGRectMake(mainTextController.frame.origin.x, mainTextController.frame.origin.y, mainTextController.frame.size.width, mainTextController.frame.size.height + textFieldMovement);
    [UIView commitAnimations];
    NSLog(@"%f", mainTextController.frame.size.height);
}

- (IBAction)updateCount:(id)sender {
    UITextField *tf = (UITextField *)sender;
    int len = [tf.text length];
    int remain = 250 - len;
    characterCountLabel.text = [NSString stringWithFormat:@"%d", remain];
    if (remain < 0) {
        characterCountLabel.textColor = [UIColor redColor];
    } else {
        characterCountLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - GCTurnBasedMatchHelperDelegate

-(void)enterNewGame:(GKTurnBasedMatch *)match {
    NSLog(@"Entering new game...");
    statusLabel.text = @"Player 1's Turn (that's you)";
    textInputField.enabled = YES;
    mainTextController.text = @"Once upon a time";
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    NSLog(@"Taking turn for existing game...");
    int playerNum = [match.participants 
                     indexOfObject:match.currentParticipant] + 1;
    NSString *statusString = [NSString stringWithFormat:
                              @"Player %d's Turn (that's you)", playerNum];
    statusLabel.text = statusString;
    textInputField.enabled = YES;
    if ([match.matchData bytes]) {
        NSString *storySoFar = [NSString stringWithUTF8String:
                                [match.matchData bytes]];
        mainTextController.text = storySoFar;
    }
}


-(void)layoutMatch:(GKTurnBasedMatch *)match {
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString;
    
    if (match.status == GKTurnBasedMatchStatusEnded) {
        statusString = @"Match Ended";
    } else {
        int playerNum = [match.participants 
                         indexOfObject:match.currentParticipant] + 1;
        statusString = [NSString stringWithFormat:
                        @"Player %d's Turn", playerNum];
    }
    statusLabel.text = statusString;
    textInputField.enabled = NO;
    NSString *storySoFar = [NSString stringWithUTF8String:
                            [match.matchData bytes]];
    mainTextController.text = storySoFar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
   
    [mainTextController release];
    [inputView release];
    [textInputField release];
    [characterCountLabel release];
    [statusLabel release];
    [super dealloc];
}
@end
