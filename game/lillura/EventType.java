public enum EventType {
    NONE,
    COMMAND_NEWGAME, //TODO new game / restart
    COMMAND_RESTART, 
    COMMAND_PLAY, 
    
    NOTIFICATION_PLAYER_WON,
    NOTIFICATION_PLAYER_LOST,
    
    ROBOT_ACTION_COMPLETED,

    PLAY_ROBOT_PROGRAM,
    ROBOT_PROGRAM_COMPLETED,
    
    SWITCH_TO_VIEW_0,  
    SWITCH_TO_VIEW_1,  
    SWITCH_TO_VIEW_2,  
    
    PERCEPTUAL_HAND_OPEN,
    PERCEPTUAL_HAND_CLOSE,
    PERCEPTUAL_HAND_MOVED_TOP_LEFT,
    PERCEPTUAL_HAND_MOVED_TOP_CENTER,
    PERCEPTUAL_HAND_MOVED_TOP_RIGHT,
    PERCEPTUAL_HAND_MOVED_LEFT ,
    PERCEPTUAL_HAND_MOVED_CENTER,
    PERCEPTUAL_HAND_MOVED_RIGHT,
    PERCEPTUAL_HAND_MOVED_BOTTOM_LEFT ,
    PERCEPTUAL_HAND_MOVED_BOTTOM_CENTER,
    PERCEPTUAL_HAND_MOVED_BOTTOM_RIGHT,

    PERCEPTUAL_SWIPE_LEFT,
    PERCEPTUAL_SWIPE_RIGHT
  
};

