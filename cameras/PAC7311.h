//
//  PAC7311.h
//
//  macam - webcam app and QuickTime driver component
//  PAC7311 - driver for PixArt PAC7311 single chip VGA webcam solution
//
//  Created by HXR on 1/15/06.
//  Copyright (C) 2006 HXR (hxr@users.sourceforge.net) and Roland Schwemmer (sharoz@gmx.de).
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA
//


#import <Cocoa/Cocoa.h>
#include "MyPixartDriver.h"


@interface PAC7311 : MyPixartDriver 
{

}

+ (NSArray *) cameraUsbDescriptions;

- (CameraError) startupGrabbing;

@end
