package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

ID_TIME_LABEL                   = 1
ID_TITLE_LABEL                  = 2
ID_DURATION_BAR                 = 3
ID_RANDOM_BUTTON                = 4
ID_REPEAT_BUTTON                = 5
ID_SELECT_FILE_BUTTON           = 6
ID_BACKWARDS_BUTTON             = 7
ID_PLAY_BUTTON                  = 8
ID_PAUSE_BUTTON                 = 9
ID_STOP_BUTTON                  = 10
ID_FORWARD_BUTTON               = 11
ID_VOLUME_BAR                   = 12
ID_VOLUME_BUTTON                = 13
ID_ADD_TO_PLAYLIST_BUTTON       = 14
ID_REMOVE_FROM_PLAYLIST_BUTTON  = 15
ID_PLAY_SELECTED_TRACK_BUTTON   = 16

ID__MAX                         = 17

frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "VinApp", wx.wxDefaultPosition, wx.wxSize(400, 500), wx.wxDEFAULT_FRAME_STYLE)

frame:Connect(wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    -- button logic
  end
)

frame:Connect(wx.wxEVT_CLOSE_WINDOW,
    function (event)
        frame:Destroy()
        event:Skip()
    end)

frame:Centre()
frame:Show(true)

wx.wxGetApp():MainLoop()