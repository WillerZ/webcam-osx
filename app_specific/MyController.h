/*
    macam - webcam app and QuickTime driver component
    Copyright (C) 2002 Matthias Krauss (macam@matthias-krauss.de)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 $Id$
*/

#import <Cocoa/Cocoa.h>
#include "GlobalDefs.h"
#import "MyCameraCentral.h"
#import "MyCameraDriver.h"

@class MyCameraInspector;


@interface MyController : NSObject
{
    IBOutlet id window;
    IBOutlet id brightnessSlider;
    IBOutlet id contrastSlider;
    IBOutlet id gammaSlider;
    IBOutlet id sharpnessSlider;
    IBOutlet id saturationSlider;
    IBOutlet id manGainCheckbox;
    IBOutlet id gainSlider;
    IBOutlet id shutterSlider;
    IBOutlet id compressionSlider;
    IBOutlet id previewView;
    IBOutlet id statusText;
    IBOutlet id whiteBalancePopup;
    IBOutlet id sizePopup;
    IBOutlet id fpsPopup;
    IBOutlet MyCameraCentral* central;
    IBOutlet id disclaimerWindow;
    IBOutlet id settingsDrawer;
    IBOutlet NSWindow* inspectorWindow;
    MyCameraInspector* inspector;
    MyCameraDriver* driver;
    NSBitmapImageRep* imageRep;
    NSImage* image;

    BOOL imageGrabbed;			//If there ever has been a grabbed image
    BOOL cameraGrabbing;		//If camera is currently grabbing
    long cameraMediaCount;		//The number of images (etc.) stored on the camera
    BOOL terminating;			//For deferred shutting down (shutdown the driver properly)
}
- (void) dealloc;
- (void) awakeFromNib;			//Initiates the disclaimer or startup
- (void) startup;			//starts up the main window

//Disclaimer handling
- (void) disclaimerOK:(id)sender;	
- (void) disclaimerQuit:(id)sender;

//UI: Handlers for control value changes
- (IBAction)brightnessChanged:(id)sender;
- (IBAction)contrastChanged:(id)sender;
- (IBAction)gammaChanged:(id)sender;
- (IBAction)sharpnessChanged:(id)sender;
- (IBAction)saturationChanged:(id)sender;
- (IBAction)manGainChanged:(id)sender;
- (IBAction)gainChanged:(id)sender;
- (IBAction)shutterChanged:(id)sender;
- (IBAction)formatChanged:(id)sender;		//Handles both size and fps popups
- (IBAction)compressionChanged:(id)sender;
- (IBAction)whiteBalanceChanged:(id)sender;

//UI: Actions to do
- (IBAction)doGrab:(id)sender;
- (IBAction)doStopGrab:(id)sender;
- (IBAction)doNextCam:(id)sender;
- (IBAction)doDownloadMedia:(id)sender;
- (IBAction)doSaveImage:(id)sender;
- (IBAction)doSavePrefs:(id)sender;
- (IBAction)toggleSettingsDrawer:(id)sender;
- (IBAction)doQuit:(id)sender;

//Sheet ended handlers
- (void)askDownloadMediaSheetEnded:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)con;
- (void)downloadSaveSheetEnded:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)con;

//delegate calls from camera central
- (void)cameraDetected:(unsigned long)uid;

//delegate calls from camera driver
- (void)imageReady:(id)cam;
- (void)grabFinished:(id)cam withError:(CameraError)err;
- (void)cameraHasShutDown:(id)cam;
- (void) cameraEventHappened:(id)sender event:(CameraEvent)evt;
//menu item validation
- (BOOL) validateMenuItem:(NSMenuItem *)item;
//Toolbar stuff
- (void) setupToolbar;
- (NSToolbarItem*) toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdent willBeInsertedIntoToolbar:(BOOL)wbi;
- (NSArray*) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray*) toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (BOOL) validateToolbarItem:(NSToolbarItem*)toolbarItem;
//Common tools - could also be private
- (BOOL) canDoGrab;
- (BOOL) canDoStopGrab;
- (BOOL) canToggleSettings;
- (BOOL) canDoDownloadMedia;
- (BOOL) canDoSaveImage;
- (BOOL) canDoNextCam;
- (BOOL) canDoSavePrefs;
- (void) updateCameraMediaCount;
//Delegates from the application
- (BOOL) applicationOpenUntitledFile:(NSApplication*)theApplication;

@end
