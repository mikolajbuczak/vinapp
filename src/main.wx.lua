package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

playlist = {}
isLoaded = false
sliderMax = 10000
prevVolume = -1

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
ID_UP_BUTTON                    = 17
ID_DOWN_BUTTON                  = 18
ID_MEDIA                        = 19

ID__MAX                         = 20

function msToMMSS(ms)
    local m = math.floor(ms/(60*1000))
    local s = math.floor((ms - m*60*1000)/1000)
    return string.format("%02d:%02d", m, s)
end

function UpdateButtons()
    local playEnabled  = false
    local pauseEnable = false
    local stopEnabled  = false

    if isLoaded then
        local state = media:GetState()

        if state == wx.wxMEDIASTATE_PLAYING then
            playEnabled  = false
            pauseEnable = true
            stopEnabled  = true
        elseif state == wx.wxMEDIASTATE_PAUSED then
            playEnabled  = true
            pauseEnable = false
            stopEnabled  = true
        elseif state == wx.wxMEDIASTATE_STOPPED then
            playEnabled  = true
            pauseEnable = false
            stopEnabled  = false
        end
    end

    playButton:Enable(playEnabled)
    pauseButton:Enable(pauseEnable)
    stopButton:Enable(stopEnabled)
end

frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "VinApp", wx.wxDefaultPosition, wx.wxSize(400, 500), wx.wxDEFAULT_FRAME_STYLE - wx.wxRESIZE_BORDER - wx.wxMAXIMIZE_BOX)
panel = wx.wxPanel(frame, wx.wxID_ANY)

-- Song info GUI
time = wx.wxStaticText(panel, ID_TIME_LABEL, "00:00", wx.wxPoint(10, 10), wx.wxSize(30, 30))
title = wx.wxStaticText(panel, ID_TIME_LABEL, "Title", wx.wxPoint(50, 10), wx.wxSize(340, 30))
duration = wx.wxSlider(panel, ID_DURATION_BAR, 0, 0, sliderMax, wx.wxPoint(0, 35), wx.wxSize(390, 30))

topLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 69), wx.wxSize(400, 1))

-- Buttons BUI
randomButton = wx.wxButton(panel, ID_RANDOM_BUTTON, "Random", wx.wxPoint(210, 80), wx.wxSize(55, 30))
repeatButton = wx.wxButton(panel, ID_REPEAT_BUTTON, "Repeat", wx.wxPoint(270, 80), wx.wxSize(55, 30))
selectFileButton = wx.wxButton(panel, ID_SELECT_FILE_BUTTON, "Select", wx.wxPoint(330, 80), wx.wxSize(55, 30))

backwardsButton = wx.wxButton(panel, ID_BACKWARDS_BUTTON, "Back", wx.wxPoint(10, 125), wx.wxSize(40, 30))
playButton = wx.wxButton(panel, ID_PLAY_BUTTON, "Play", wx.wxPoint(55, 125), wx.wxSize(40, 30))
pauseButton = wx.wxButton(panel, ID_PAUSE_BUTTON, "Pause", wx.wxPoint(100, 125), wx.wxSize(40, 30))
stopButton = wx.wxButton(panel, ID_STOP_BUTTON, "Stop", wx.wxPoint(145, 125), wx.wxSize(40, 30))
forwardButton = wx.wxButton(panel, ID_FORWARD_BUTTON, "Next", wx.wxPoint(190, 125), wx.wxSize(40, 30))

-- Volume GUI
volumeBar = wx.wxSlider(panel, ID_VOLUME_BAR, sliderMax, 0, sliderMax, wx.wxPoint(250, 130), wx.wxSize(105, 30))
muteButton = wx.wxButton(panel, ID_VOLUME_BUTTON, "M", wx.wxPoint(355, 125), wx.wxSize(30, 30))

midLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 165), wx.wxSize(400, 1))

-- Playlist GUI
listBox = wx.wxListBox(panel, wx.wxID_ANY, wx.wxPoint(10, 175), wx.wxSize(375, 235), playlist, wx.wxLB_SINGLE)

bottomLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 419), wx.wxSize(400, 1))

-- Playlist buttons GUI
addToPlaylistButton = wx.wxButton(panel, ID_ADD_TO_PLAYLIST_BUTTON, "ADD", wx.wxPoint(10, 430), wx.wxSize(40, 30))
removeFromPlaylistButton = wx.wxButton(panel, ID_REMOVE_FROM_PLAYLIST_BUTTON, "REM", wx.wxPoint(55, 430), wx.wxSize(40, 30))
playSelectedButton = wx.wxButton(panel, ID_PLAY_SELECTED_TRACK_BUTTON, "SELECT", wx.wxPoint(100, 430), wx.wxSize(60, 30))

upButton = wx.wxButton(panel, ID_UP_BUTTON, "↑", wx.wxPoint(320, 430), wx.wxSize(30, 30))
downButton = wx.wxButton(panel, ID_DOWN_BUTTON, "↓", wx.wxPoint(355, 430), wx.wxSize(30, 30))

-- mp3 player
media = wx.wxMediaCtrl(panel, ID_MEDIA)

UpdateButtons()

timer = wx.wxTimer(panel)

-- Updates time label and position slider value
panel:Connect(wx.wxEVT_TIMER,
    function (event)
        local len = 1
        local pos = 0
        local str = "00:00"

        if not isLoaded then return end
        
        len = media:Length()
        pos = media:Tell()
        str = string.format("%s", msToMMSS(pos))
        duration:SetValue(sliderMax * pos / len)
        time:SetLabel(str)
    end
)

timer:Start(300)

-- Add songs to the playlist
frame:Connect(ID_ADD_TO_PLAYLIST_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local filePicker = wx.wxFileDialog(frame, wx.wxFileSelectorPromptStr, wx.wxGetCwd(), "", "*.mp3", wx.wxFD_OPEN + wx.wxFD_MULTIPLE + wx.wxFD_FILE_MUST_EXIST + wx.wxFD_CHANGE_DIR)
    if filePicker:ShowModal() == wx.wxID_OK then
        local paths = filePicker:GetPaths()
        
        for index, path in pairs(paths) do 
          table.insert(playlist, path)
        end
        
        local songs = filePicker:GetFilenames()
        
        listBox:InsertItems(songs, listBox:GetCount())
    end
    filePicker:Destroy()
  end
)

-- Remove selected song from the playlist
frame:Connect(ID_REMOVE_FROM_PLAYLIST_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local selectedIndex = listBox:GetSelection()
    
    if selectedIndex == -1 then return end
    
    listBox:Delete(selectedIndex)
  
    table.remove(playlist, selectedIndex + 1)
    
  end
)

-- Loads selected song from the playlist
frame:Connect(ID_PLAY_SELECTED_TRACK_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local selectedIndex = listBox:GetSelection()
    
    if selectedIndex == -1 then return end
    
    isLoaded = false
    
    local file = listBox:GetString(selectedIndex)
    
    if not media:Load(playlist[selectedIndex + 1]) then
        wx.wxMessageBox(string.format("Cannot load  %s.", file), "Error", wx.wxICON_ERROR + wx.wxOK)
        return
    end
    
    isLoaded = true
    title:SetLabel(file)
    UpdateButtons()
  end
)


media:Connect(wx.wxEVT_MEDIA_STATECHANGED,
    function (event)
        UpdateButtons()
    end
)

-- Plays loaded song
frame:Connect(ID_PLAY_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    if not isLoaded then
        local selectedIndex = listBox:GetSelection()
    
        if selectedIndex == -1 then return end
        
        local file = listBox:GetString(selectedIndex)
        
        if not media:Load(playlist[selectedIndex + 1]) then
            wx.wxMessageBox(string.format("Cannot load  %s.", file), "Error", wx.wxICON_ERROR + wx.wxOK)
            return
        end
        
        isLoaded = true
    end
  
    local canPlay = media:Play()
    
    if not canPlay then return end
  end
)

-- Pauses played song
frame:Connect(ID_PAUSE_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local canPause = media:Pause()
    
    if not canPause then return end
  end
)

-- Stop played song
frame:Connect(ID_STOP_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local canStop = media:Stop()
    
    if not canStop then return end
  end
)

-- Change volume
frame:Connect(ID_VOLUME_BAR, wx.wxEVT_SCROLL_THUMBRELEASE,
    function (event)
        local pos = event:GetPosition()
        media:SetVolume(pos / sliderMax)
        
        if prevVolume ~= -1 then prevVolume = -1 end
    end 
)

-- Mute
frame:Connect(ID_VOLUME_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    if prevVolume == -1 then
        prevVolume = volumeBar:GetValue()
        media:SetVolume(0)
        volumeBar:SetValue(0)
    else
        media:SetVolume(prevVolume / sliderMax)
        volumeBar:SetValue(prevVolume)
        prevVolume = -1
    end
  end
)

-- Move selected song up
frame:Connect(ID_UP_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local selectedIndex = listBox:GetSelection()
    
    if selectedIndex == -1 then return end
    
    if selectedIndex == 0 then return end
    
    local filename = listBox:GetString(selectedIndex)
    local filepath = playlist[selectedIndex + 1]
    
    listBox:Delete(selectedIndex)
    table.remove(playlist, selectedIndex + 1)
    
    local newItem = { filename }
    listBox:InsertItems(newItem, selectedIndex - 1)
    listBox:SetSelection(selectedIndex - 1)
    
    table.insert(playlist, selectedIndex, filepath)
    
  end
)

-- Move selected song down
frame:Connect(ID_DOWN_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    local selectedIndex = listBox:GetSelection()
    
    if selectedIndex == -1 then return end
    
    local lastIndex = listBox:GetCount()
    
    if selectedIndex == lastIndex - 1  then return end
    
    local filename = listBox:GetString(selectedIndex)
    local filepath = playlist[selectedIndex + 1]
    
    listBox:Delete(selectedIndex)
    table.remove(playlist, selectedIndex + 1)
    
    local newItem = { filename }
    listBox:InsertItems(newItem, selectedIndex + 1 )
    listBox:SetSelection(selectedIndex + 1)
    
    table.insert(playlist, selectedIndex + 2, filepath)
    
  end
)

-- Close window
frame:Connect(wx.wxEVT_CLOSE_WINDOW,
    function (event)
        frame:Destroy()
        event:Skip()
        if timer then
            timer:Stop()
            timer:delete()
            timer = nil
        end
    end)

frame:Centre()
frame:Show(true)

wx.wxGetApp():MainLoop()