//
//  KAZ_ViewController.m
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import "KAZ_ViewController.h"
#import "KAZ_DynamicControllerScene.h"
#import "KAZ_FixedControllerScene.h"

@interface KAZ_ViewController(){
    SKView *skView;
}

@end

@implementation KAZ_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [KAZ_DynamicControllerScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)changeScene:(id)sender{
    UISegmentedControl *buttons = (UISegmentedControl *)sender;
    SKScene *scene;
    if ( buttons.selectedSegmentIndex == 0 ){
        scene = [KAZ_DynamicControllerScene sceneWithSize:skView.bounds.size];
    } else {
        scene = [KAZ_FixedControllerScene sceneWithSize:skView.bounds.size];
    }
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
}

@end
