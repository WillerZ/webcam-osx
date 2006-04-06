//
//  SPCA561ADriver.m
//
//  macam - webcam app and QuickTime driver component
//  SPCA561ADriver - driver for the Sunplus SPCA561A chip
//
//  Created by hxr on 1/19/06.
//  Copyright (C) 2006 HXR (hxr@users.sourceforge.net). 
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


#import "SPCA561ADriver.h"

#include "USB_VendorProductIDs.h"

#include "spcadecoder.h"


@implementation SPCA561ADriver


+ (NSArray *) cameraUsbDescriptions 
{
    return [NSArray arrayWithObjects:
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_GENERIC_SPCA561_CAM], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_SUNPLUS], @"idVendor",
            @"Generic SPCA561A Webcam", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_VISTA_B], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_CREATIVE_LABS], @"idVendor",
            @"Creative Vista (PD1100)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_VISTA_C], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_CREATIVE_LABS], @"idVendor",
            @"Creative Vista (VF0010)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_VIDEOCAM_EXPRESS_V2], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_GENIUS], @"idVendor",
            @"Genius VideoCam Express V2", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_QUICKCAM_EXPRESS_D], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_LOGITECH], @"idVendor",
            @"Logitech QuickCam Express (Elch2)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_LABTEC_WEBCAM_B], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_LABTEC], @"idVendor",
            @"Labtec Webcam (Elch2)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_QUICKCAM_NOTEBOOKS_A], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_LOGITECH], @"idVendor",
            @"Logitech QuickCam for Notebooks (square)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_LABTEC_WEBCAM_C], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_LABTEC], @"idVendor",
            @"Labtec Webcam (C)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_QUICKCAM_CHAT_B], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_LOGITECH], @"idVendor",
            @"Logitech QuickCam Chat (B)", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_COMPACT_PC_PM3], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_MAXELL], @"idVendor",
            @"Maxell Compact PC PM3", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_IC_150], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_MICRO_INNOVATION], @"idVendor",
            @"Micro Innovation IC 150", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_PETCAM], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_SIGMA_APO], @"idVendor",
            @"Sigma-Apo PetCam", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_FLYCAM_USB100], @"idProduct",
            [NSNumber numberWithUnsignedShort:VENDOR_FLYCAM], @"idVendor",
            @"FlyCam USB100", @"name", NULL], 
        
        NULL];
}


#include "spca561.h"


//
// Initialize the driver
//
- (id) initWithCentral: (id) c 
{
	self = [super initWithCentral:c];
	if (self == NULL) 
        return NULL;
    
    bayerConverter = [[BayerConverter alloc] init];
	if (bayerConverter == NULL) 
        return NULL;
    
    MALLOC(decodingBuffer, UInt8 *, 356 * 292 + 1000, "decodingBuffer");

    spca50x->compress = 1;

//  spca50x->desc = ??; // Not needed
    spca50x->bridge = BRIDGE_SPCA561;
    spca50x->sensor = SENSOR_INTERNAL;
    spca50x->header_len = SPCA561_OFFSET_DATA;
    spca50x->i2c_ctrl_reg = SPCA50X_REG_I2C_CTRL;
    spca50x->i2c_base = SPCA561_INDEX_I2C_BASE;
    spca50x->i2c_trigger_on_write = 1;
    spca50x->cameratype = S561;
    
	return self;
}

//
// This attempts to provide the highest bandwidth
//
- (BOOL) setGrabInterfacePipe
{
    return [self usbSetAltInterfaceTo:7 testPipe:[self getGrabbingPipe]];
}


//
// Scan the frame and return the results
//
IsocFrameResult  spca561aIsocFrameScanner(IOUSBIsocFrame * frame, UInt8 * buffer, 
                                          UInt32 * dataStart, UInt32 * dataLength, 
                                          UInt32 * tailStart, UInt32 * tailLength)
{
    int frameLength = frame->frActCount;
    
    *dataStart = 1;
    *dataLength = frameLength - 1;
    
    *tailStart = frameLength;
    *tailLength = 0;
    
//  printf("buffer[0] = 0x%02x (length = %d) 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n", buffer[0], frameLength, buffer[1], buffer[2], buffer[3], buffer[4], buffer[5]);
    
    if (frameLength < 1 || buffer[0] == SPCA50X_SEQUENCE_DROP) 
        return invalidFrame;
    
    int frameNumber = buffer[SPCA50X_OFFSET_SEQUENCE];
//  int chunkNumber = buffer[SPCA561_OFFSET_FRAMSEQ];
    
//    printf("buffer[0] = 0x%02x (length = %d) 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n", 
//            buffer[0], frameLength, buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7], buffer[8], buffer[9], buffer[10], buffer[11], buffer[12], buffer[13], buffer[14], buffer[15], buffer[16], buffer[17], buffer[18], buffer[19], buffer[20]);
    
    if (frameNumber == 0x00) 
    {
//        printf("Chunk number %3d: \n", chunkNumber);
        
        return newChunkFrame;
    }
    
    return validFrame;
}

//
// These are the C functions to be used for scanning the frames
//
- (void) setIsocFrameFunctions
{
    grabContext.isocFrameScanner = spca561aIsocFrameScanner;
    grabContext.isocDataCopier = genericIsocDataCopier;
}


- (CameraError) spca5xx_init
{
    /*
    static __u16 spca561_ext_modes[][6] = {
    {352, 288, 0x00, 0x27, 0x00, 1023},
    {320, 240, 0x01, 0x27, 0x00, 1023},
    {176, 144, 0x02, 0x23, 0x00, 1023},	// software mode hardware seem buggy slow shift in video
    {160, 120, 0x03, 0x23, 0x00, 1023},
    {0, 0, 0, 0, 0}
    };
    int index = 0;
    */
    
    spca561_init(spca50x);
    
//    spca50x->mode = (spca561_ext_modes[index][2]) & 0x0F;
//    int method = (spca561_ext_modes[index][2] & 0xF0) >> 4;
//    spca50x_reg_write(spca50x->dev, 0, 0x8500, spca50x->mode);            // mode
//    spca50x_reg_write(spca50x->dev, 0, 0x8700, spca561_ext_modes[index][3]);      // clock
    
    return CameraErrorOK;
}



- (CameraError) spca5xx_config
{
    int result = spca561_config(spca50x);
    return (result == 0) ? CameraErrorOK : CameraErrorInternal;
}


- (CameraError) spca5xx_start
{
    spca561_start(spca50x);
    return CameraErrorOK;
}


- (CameraError) spca5xx_stop
{
    spca561_stop(spca50x);
    return CameraErrorOK;
}


- (CameraError) spca5xx_shutdown
{
    spca561_shutdown(spca50x);
    return CameraErrorOK;
}


// brightness also returned in spca5xx_struct

- (CameraError) spca5xx_getbrightness
{
    spca561_getbrightness(spca50x);
    return CameraErrorOK;
}


// takes brightness from spca5xx_struct

- (CameraError) spca5xx_setbrightness
{
    spca561_setbrightness(spca50x);
    return CameraErrorOK;
}


- (CameraError) spca5xx_setAutobright
{
    spca561_setAutobright(spca50x);
    return CameraErrorOK;
}


// contrast also returned in spca5xx_struct

- (CameraError) spca5xx_getcontrast
{
    spca561_getcontrast(spca50x);
    return CameraErrorOK;
}


// takes contrast from spca5xx_struct

- (CameraError) spca5xx_setcontrast
{
    spca561_setcontrast(spca50x);
    return CameraErrorOK;
}


//
// other stuff, including decompression
//
- (void) decodeBuffer: (GenericChunkBuffer *) buffer
{
//    printf("Need to decode a buffer with %ld bytes.\n", buffer->numBytes);
    
    int skip = 0;
	short rawWidth  = [self width];
	short rawHeight = [self height];
    
	// Decode the bytes
    
    if (buffer->buffer[1] & 0x10) 
        decode_spca561(buffer->buffer, decodingBuffer, rawWidth, rawHeight);
    else 
        skip = 20;
    
    // Turn the Bayer data into an RGB image
    
    [bayerConverter setSourceFormat:6];
    [bayerConverter setSourceWidth:rawWidth height:rawHeight];
    [bayerConverter setDestinationWidth:rawWidth height:rawHeight];
    [bayerConverter convertFromSrc:decodingBuffer + skip
                            toDest:nextImageBuffer
                       srcRowBytes:rawWidth
                       dstRowBytes:nextImageBufferRowBytes
                            dstBPP:nextImageBufferBPP
                              flip:hFlip
                         rotate180:NO];
}


@end
