/*
 *  UIInputToolbar.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "UIInputToolbar.h"

NSString * const CHExpandingTextViewWillChangeHeightNotification = @"CHExpandingTextViewWillChangeHeight";

@interface UIInputToolbar ()
@property (nonatomic, assign) UIColor *characterCountIsValidTextColor;
@property (nonatomic, assign) UIColor *characterCountIsValidShadowColor;
@property (nonatomic, assign) UIColor *characterCountIsNotValidTextColor;
@property (nonatomic, assign) UIColor *characterCountIsNotValidShadowColor;

@property (nonatomic, retain) UIView    *containerView;
@property (nonatomic, retain) UIButton  *innerBarButton;

@end

#define kSetupTBIBTextViewSizeWidth 206.0
#define kSetupTBIETextViewSizeWidth 236.0

#define kUIInputToolbarLocalizableTableName @"UIInputToolbarLocalizable"

@implementation UIInputToolbar
@synthesize delegate;

- (void)inputButtonPressed {
    
    if ([self.delegate respondsToSelector:@selector(uiImputToolbar:inputButtonPressed:)]) {
        [self.delegate uiImputToolbar:self inputButtonPressed:self.textView.text];
    }
    
    /* Remove the keyboard and clear the text */
    [self.textView clearText];
    [self.textView resignFirstResponder];
    
}

- (void)cameraButtonPressed {
    
    if ([self.delegate respondsToSelector:@selector(uiImputToolbarCameraButtonPressed:)]) {
        [self.delegate uiImputToolbarCameraButtonPressed:self];
    }
    
}

- (void)locationButtonPressed {
    
    if ([self.delegate respondsToSelector:@selector(uiImputToolbarLocationButtonPressed:)]) {
        [self.delegate uiImputToolbarLocationButtonPressed:self];
    }
    
}

- (void)setupToolbar:(NSString *)buttonLabel {
  
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.tintColor = [UIColor lightGrayColor];
    
    if (self.shouldUseCustomInterface) {
        /* Create custom send button*/
        [self setInputButtonImage:[UIImage imageNamed:@"buttonbg.png"]];
        [self setBackgroundImage:[UIImage imageNamed:@"toolbarbg.png"]];

        UIImage *stretchableButtonImage = [self.inputButtonImage stretchableImageWithLeftCapWidth:floorf(self.inputButtonImage.size.width/2)
                                                                                     topCapHeight:floorf(self.inputButtonImage.size.height/2)];
        
        UIButton *button               = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font         = [UIFont boldSystemFontOfSize:15.0f];
        button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        button.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 0, 2);
        button.contentStretch          = CGRectMake(0.5, 0.5, 0, 0);
        button.contentMode             = UIViewContentModeScaleToFill;
        
        [button setBackgroundImage:stretchableButtonImage forState:UIControlStateNormal];
        [button setTitle:buttonLabel forState:UIControlStateNormal];
        [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
        [button sizeToFit];
        
        self.innerBarButton = button;
        self.inputButton = [[UIBarButtonItem alloc] initWithCustomView:button];        
    } else {
        self.inputButton = [[UIBarButtonItem alloc] initWithTitle:buttonLabel
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(inputButtonPressed)];
    }
    
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.inputButton setStyle:UIBarButtonItemStyleBordered];
    /* Disable button initially */
    self.inputButton.enabled = NO;
    self.inputButtonShouldDisableForNoText = YES;
    
    /* Create UIExpandingTextView input */
    self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(0.0, 7.0, kSetupTBIBTextViewSizeWidth, 26)];
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textView];
            
    /* Add the character count label */
    self.characterCountIsValidTextColor = [UIColor whiteColor];
    self.characterCountIsValidShadowColor = [UIColor darkGrayColor];
    self.characterCountIsNotValidTextColor = [UIColor redColor];
    self.characterCountIsNotValidShadowColor = [UIColor clearColor];
    
    self.characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(253, -5, 50, 40)];
    self.characterCountLabel.textAlignment = UITextAlignmentCenter;
    self.characterCountLabel.font = [UIFont boldSystemFontOfSize:12];
    self.characterCountLabel.textColor = self.characterCountIsValidTextColor;
    self.characterCountLabel.shadowColor = self.characterCountIsValidShadowColor;
    self.characterCountLabel.shadowOffset = CGSizeMake(0, -1);
    self.characterCountLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.characterCountLabel];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSetupTBIBTextViewSizeWidth, 40)];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.clipsToBounds = YES;
    [self.containerView addSubview:self.textView];
    
    self.textViewButton = [[UIBarButtonItem alloc] initWithCustomView:self.containerView];
    
    NSArray *items = [NSArray arrayWithObjects: self.textViewButton, self.inputButton, nil];
    [self setItems:items animated:NO];
    
    self.cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                      target:self
                                                                      action:@selector(cameraButtonPressed)];
    [self.cameraButton setStyle:UIBarButtonItemStyleBordered];

    self.locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"uiBarButtonItemLocation_iPhone.png"]
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(locationButtonPressed)];

}

- (void)setupWithToolbarItensEditing {
    
    self.textViewButton.width = kSetupTBIETextViewSizeWidth;

    NSArray *items = [NSArray arrayWithObjects: self.textViewButton, self.inputButton, nil];
    [self setItems:items animated:YES];
    
}

- (void)setupWithToolbarItensButtons {
    
    self.textViewButton.width = kSetupTBIBTextViewSizeWidth;
    
    NSArray *items = [NSArray arrayWithObjects: self.locationButton, self.cameraButton, self.textViewButton, nil];
    [self setItems:items animated:YES];
    
}

- (id)initWithFrame:(CGRect)frame andCustomInterface:(BOOL)customInterface {
    if ((self = [super initWithFrame:frame])) {
        [self setShouldUseCustomInterface:customInterface];
        [self setupToolbar:NSLocalizedStringFromTable(@"Send", kUIInputToolbarLocalizableTableName, Nil)];
    }
    return self;
}

- (id)initWithCustomInterface:(BOOL)customInterface {
    if ((self = [super init])) {
        [self setShouldUseCustomInterface:customInterface];
        [self setupToolbar:NSLocalizedStringFromTable(@"Send", kUIInputToolbarLocalizableTableName, Nil)];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGRect i = self.inputButton.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.inputButton.customView.frame = i;

    if (NO == self.shouldUseCustomInterface) {
        [super drawRect:rect];
        return;
    }

    /* Draw custon toolbar background */
    UIImage *stretchableBackgroundImage = [self.backgroundImage stretchableImageWithLeftCapWidth:floorf(self.backgroundImage.size.width/2) topCapHeight:floorf(self.backgroundImage.size.height/2)];
    [stretchableBackgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
}

#pragma mark - UIExpandingTextView delegate

- (void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height {
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (self.textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.frame = r;
	
	NSDictionary *aUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:height],CH_TEXTVIEW_HEIGHT_KEY, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:CHExpandingTextViewWillChangeHeightNotification object:nil userInfo:(NSDictionary *)aUserInfo];
}

- (void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView {
    /* Enable/Disable the button */
    if (self.inputButtonShouldDisableForNoText) {
        if ([expandingTextView hasText]) {
            self.inputButton.enabled = YES;
        } else {
            self.inputButton.enabled = NO;
        }
    }
    
    /* Show/Hide the character count and update its text */
    if (self.characterLimit > 0) {
        if (self.frame.size.height > 40) {
            self.characterCountLabel.hidden = NO;
        } else {
            self.characterCountLabel.hidden = YES;
        }
        
        self.characterCountLabel.text = [NSString stringWithFormat:@"%i/%i",expandingTextView.text.length, self.characterLimit];
        
        if (expandingTextView.text.length > self.characterLimit) {
            self.characterCountLabel.textColor = self.characterCountIsNotValidTextColor;
            self.characterCountLabel.shadowColor = self.characterCountIsNotValidShadowColor;
            self.inputButton.enabled = NO;
        } else if (expandingTextView.text.length > 0) {
            self.characterCountLabel.textColor = self.characterCountIsValidTextColor;
            self.characterCountLabel.shadowColor = self.characterCountIsValidShadowColor;
            self.inputButton.enabled = YES;
        }
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.textView.placeholder = placeholder;
}

@end
