#import "MGLCameraChange.h"

#define MGL_CAMERA_CHANGE_REASON_DEF(name) const MGLCameraChangeReason name = @ #name

MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonUnknown);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonProgramatic);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGestureResetNorth);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGesturePan);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGesturePinch);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGestureRotate);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGestureDoubleTap);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGestureTwoFingerSingleTap);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGestureQuickZoom);
MGL_CAMERA_CHANGE_REASON_DEF(MGLCameraChangeReasonGesturePitchStart);

#undef MGL_CAMERA_CHANGE_REASON_DEF
