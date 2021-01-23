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

--wxDEFAULT_FRAME_STYLE & ~(wxRESIZE_BORDER | wxMAXIMIZE_BOX)
dialog = wx.wxDialog(wx.NULL, wx.wxID_ANY, "VinApp", wx.wxDefaultPosition, wx.wxSize(400, 500))
panel = wx.wxPanel(dialog, wx.wxID_ANY)
local time = wx.wxStaticText(panel, ID_TIME_LABEL, "00:00", wx.wxPoint(10, 10), wx.wxSize(30, 30))
local title = wx.wxStaticText(panel, ID_TIME_LABEL, "Title", wx.wxPoint(50, 10), wx.wxSize(340, 30))
local duration = wx.wxSlider(panel, ID_DURATION_BAR, 0, 0, 100, wx.wxPoint(0, 35), wx.wxSize(390, 30))

local topLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 69), wx.wxSize(400, 1))

local randomButton = wx.wxButton(panel, ID_RANDOM_BUTTON, "Random", wx.wxPoint(210, 80), wx.wxSize(55, 30))
local repeatButton = wx.wxButton(panel, ID_REPEAT_BUTTON, "Repeat", wx.wxPoint(270, 80), wx.wxSize(55, 30))
local selectFileButton = wx.wxButton(panel, ID_SELECT_FILE_BUTTON, "Select", wx.wxPoint(330, 80), wx.wxSize(55, 30))

local backwardsButton = wx.wxButton(panel, ID_BACKWARDS_BUTTON, "Back", wx.wxPoint(10, 125), wx.wxSize(40, 30))
local playButton = wx.wxButton(panel, ID_PLAY_BUTTON, "Play", wx.wxPoint(55, 125), wx.wxSize(40, 30))
local pauseButton = wx.wxButton(panel, ID_PAUSE_BUTTON, "Pause", wx.wxPoint(100, 125), wx.wxSize(40, 30))
local stopButton = wx.wxButton(panel, ID_STOP_BUTTON, "Stop", wx.wxPoint(145, 125), wx.wxSize(40, 30))
local forwardButton = wx.wxButton(panel, ID_FORWARD_BUTTON, "Next", wx.wxPoint(190, 125), wx.wxSize(40, 30))

local volumeBar = wx.wxSlider(panel, ID_VOLUME_BAR, 0, 0, 100, wx.wxPoint(250, 130), wx.wxSize(105, 30))
local muteButton = wx.wxButton(panel, ID_VOLUME_BUTTON, "M", wx.wxPoint(355, 125), wx.wxSize(30, 30))

local midLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 165), wx.wxSize(400, 1))

local playlist = {}

local listBox = wx.wxListBox(panel, wx.wxID_ANY, wx.wxPoint(10, 175), wx.wxSize(375, 235), playlist, wx.wxLB_SINGLE)

local bottomLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 419), wx.wxSize(400, 1))

local addToPlaylistButton = wx.wxButton(panel, ID_ADD_TO_PLAYLIST_BUTTON, "ADD", wx.wxPoint(10, 430), wx.wxSize(40, 30))
local removeFromPlaylistButton = wx.wxButton(panel, ID_REMOVE_FROM_PLAYLIST_BUTTON, "REM", wx.wxPoint(55, 430), wx.wxSize(40, 30))
local playSelectedButton = wx.wxButton(panel, ID_PLAY_SELECTED_TRACK_BUTTON, "SELECT", wx.wxPoint(100, 430), wx.wxSize(60, 30))

dialog:Connect(wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    -- button logic
  end
)

dialog:Connect(wx.wxEVT_CLOSE_WINDOW,
    function (event)
        dialog:Destroy()
        event:Skip()
    end)

dialog:Centre()
dialog:Show(true)

wx.wxGetApp():MainLoop()