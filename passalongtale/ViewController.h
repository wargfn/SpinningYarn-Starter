//
//  ViewController.h
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

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface ViewController : UIViewController <UITextFieldDelegate, GCTurnBasedMatchHelperDelegate>
{
    
    IBOutlet UITextView *mainTextController;
    IBOutlet UIView *inputView;
    IBOutlet UITextField *textInputField;
    IBOutlet UILabel *characterCountLabel;
}

- (IBAction)presentGCTurnViewController:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)sendTurn:(id)sender;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
- (IBAction)updateCount:(id)sender;


@end
