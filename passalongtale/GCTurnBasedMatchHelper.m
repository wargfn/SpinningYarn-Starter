//
//  GCTurnBasedMatchHelper.m
//  spinningyarn
//
//  Created by Ron Schachtner on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GCTurnBasedMatchHelper.h"

@implementation GCTurnBasedMatchHelper

@synthesize gameCenterAvailable;
@synthesize currentMatch;
@synthesize delegate;

#pragma mark Initialization

static GCTurnBasedMatchHelper *sharedHelper = nil;
+ (GCTurnBasedMatchHelper *) sharedInstance
{
    if (!sharedHelper)
    {
        sharedHelper = [[GCTurnBasedMatchHelper alloc] init];
        
    }
    
    return sharedHelper;
}

-(BOOL)isGameCenterAvailable
{
    //check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *curSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([curSysVer compare:reqSysVer options:NSNumericSearch] !=NSOrderedAscending);
                               
                               return (gcClass && osVersionSupported);
}


-(id)init
{
    if((self = [super init]))
    {
        gameCenterAvailable = [self isGameCenterAvailable];
        if(gameCenterAvailable)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    
    return self;
}

-(void)authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated)
    {
        NSLog(@"Authentication changed; Player Authenticated.");
        userAuthenticated = TRUE;
    }
    else if(![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication Changed; Player NOT Authorized.");
        userAuthenticated = FALSE;
    }
}

#pragma mark User functions

-(void)authenticateLocalUser
{
    
    if(!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user ...");
    
    
    //NOrmal code
    if([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
        
    }
    //End of Normal Code
     
        /*
        //Code to Clean out matches
        if ([GKLocalPlayer localPlayer].authenticated == NO) 
        {     
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError * error) 
             {
                 [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
                  {
                      for (GKTurnBasedMatch *match in matches) 
                      { 
                        NSLog(@"%@", match.matchID); 
                          [match removeWithCompletionHandler:^(NSError *error)
                           {
                               NSLog(@"%@", error);
                           }]; 
                      }
                  }];
            }];        
        } 
        //End of Cleanout Code
         */
        
    else 
    {
        NSLog(@"Already authenticated!");
    }

}


-(void)findMatchWithMinPlayers:(int)minPlayers
                    maxPlayers:(int)maxPlayers
                viewController:(UIViewController *)viewController
{
    if(!gameCenterAvailable) return;
    
    presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc]initWithMatchRequest:request];
    
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
    [presentingViewController presentModalViewController:mmvc animated:YES];
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate
-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match 
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    
    self.currentMatch = match;
    GKTurnBasedParticipant *firstParticipant = [match.participants objectAtIndex:0];
        if (firstParticipant.lastTurnDate == NULL) 
        {
            // It's a new game!
            [delegate enterNewGame:match];
        } 
        else 
        {
            if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) 
            {
                // It's your turn!
                [delegate takeTurn:match];
            } 
            else 
            {
            // It's not your turn, just display the game state.
            [delegate layoutMatch:match];
            }        
        }
}

-(void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"has canceled");
}

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    NSUInteger currentIndex = 
    [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *part;
    
    for (int i = 0; i < [match.participants count]; i++) {
        part = [match.participants objectAtIndex:
                (currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        } 
    }
    NSLog(@"playerquitforMatch, %@, %@", 
          match, match.currentParticipant);
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipant:part matchData:match.matchData completionHandler:nil];
}

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

@end
