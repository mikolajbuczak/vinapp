package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

playlist = {}
isLoaded = false
sliderMax = 10000
prevVolume = -1
repeatOn = false
randomOn = false
stopPressed = false
currentSongIndex = -1
autoPlay = false
settingSliderPosition = false
thumbRelease = false

local IDCounter = nil
local function NewID()
    if not IDCounter then IDCounter = wx.wxID_HIGHEST end
    IDCounter = IDCounter + 1
    return IDCounter
end

ID_TIME_LABEL                   = NewID()
ID_TITLE_LABEL                  = NewID()
ID_DURATION_BAR                 = NewID()
ID_MODE_LABEL                   = NewID()
ID_RANDOM_BUTTON                = NewID()
ID_REPEAT_BUTTON                = NewID()
ID_BACKWARDS_BUTTON             = NewID()
ID_PLAY_BUTTON                  = NewID()
ID_PAUSE_BUTTON                 = NewID()
ID_STOP_BUTTON                  = NewID()
ID_FORWARD_BUTTON               = NewID()
ID_VOLUME_BAR                   = NewID()
ID_VOLUME_BUTTON                = NewID()
ID_ADD_TO_PLAYLIST_BUTTON       = NewID()
ID_REMOVE_FROM_PLAYLIST_BUTTON  = NewID()
ID_PLAY_SELECTED_TRACK_BUTTON   = NewID()
ID_UP_BUTTON                    = NewID()
ID_DOWN_BUTTON                  = NewID()
ID_MEDIA                        = NewID()

ID__MAX                         = NewID()

function msToMMSS(ms)
    local m = math.floor(ms/(60*1000))
    local s = math.floor((ms - m*60*1000)/1000)
    return string.format("%02d:%02d", m, s)
end

function UpdateButtons()
    local playEnabled  = false
    local pauseEnable = false
    local stopEnabled  = false
    local forwardEnabled = false
    local backwardsEnabled = false

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
        if listBox:GetCount() > 1 then
            forwardEnabled = true
            backwardsEnabled = true
        end
    end

    playButton:Enable(playEnabled)
    pauseButton:Enable(pauseEnable)
    stopButton:Enable(stopEnabled)
    forwardButton:Enable(forwardEnabled)
    backwardsButton:Enable(backwardsEnabled)
end

frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "VinApp", wx.wxDefaultPosition, wx.wxSize(400, 500), wx.wxDEFAULT_FRAME_STYLE - wx.wxRESIZE_BORDER - wx.wxMAXIMIZE_BOX)
panel = wx.wxPanel(frame, wx.wxID_ANY)

--Adding window icon
icon=wx.wxIcon("D:/GitHub/vinapp/resources/logo3.ico", wx.wxBITMAP_TYPE_ICO)
frame:SetIcon(icon)

-- Song info GUI
time = wx.wxStaticText(panel, ID_TIME_LABEL, "00:00/00:00", wx.wxPoint(10, 10), wx.wxSize(70, 30))
title = wx.wxStaticText(panel, ID_TIME_LABEL, "Title", wx.wxPoint(80, 10), wx.wxSize(340, 30))
duration = wx.wxSlider(panel, ID_DURATION_BAR, 0, 0, sliderMax, wx.wxPoint(0, 35), wx.wxSize(390, 30))
    
topLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 69), wx.wxSize(400, 1))

mode = wx.wxStaticText(panel, ID_TIME_LABEL, "Mode: None", wx.wxPoint(10, 80), wx.wxSize(80, 30))

-- Buttons BUI
randomButton = wx.wxButton(panel, ID_RANDOM_BUTTON, "Random", wx.wxPoint(270, 80), wx.wxSize(55, 30))
repeatButton = wx.wxButton(panel, ID_REPEAT_BUTTON, "Repeat", wx.wxPoint(330, 80), wx.wxSize(55, 30))

backwardsButton = wx.wxButton(panel, ID_BACKWARDS_BUTTON, "<", wx.wxPoint(10, 125), wx.wxSize(30, 30))
playButton = wx.wxButton(panel, ID_PLAY_BUTTON, "►", wx.wxPoint(45, 125), wx.wxSize(30, 30))
pauseButton = wx.wxButton(panel, ID_PAUSE_BUTTON, "‖", wx.wxPoint(80, 125), wx.wxSize(30, 30))
stopButton = wx.wxButton(panel, ID_STOP_BUTTON, "■", wx.wxPoint(115, 125), wx.wxSize(30, 30))
forwardButton = wx.wxButton(panel, ID_FORWARD_BUTTON, ">", wx.wxPoint(150, 125), wx.wxSize(30, 30))

-- Volume GUI
volumeBar = wx.wxSlider(panel, ID_VOLUME_BAR, sliderMax, 0, sliderMax, wx.wxPoint(205, 130), wx.wxSize(150, 30))
muteButton = wx.wxButton(panel, ID_VOLUME_BUTTON, "♫", wx.wxPoint(355, 125), wx.wxSize(30, 30))

midLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 165), wx.wxSize(400, 1))

-- Playlist GUI
listBox = wx.wxListBox(panel, wx.wxID_ANY, wx.wxPoint(10, 175), wx.wxSize(375, 235), playlist, wx.wxLB_SINGLE)

bottomLine = wx.wxStaticLine(panel, wx.wxID_ANY, wx.wxPoint(0, 419), wx.wxSize(400, 1))

-- Playlist buttons GUI
addToPlaylistButton = wx.wxButton(panel, ID_ADD_TO_PLAYLIST_BUTTON, "+", wx.wxPoint(10, 430), wx.wxSize(30, 30))
removeFromPlaylistButton = wx.wxButton(panel, ID_REMOVE_FROM_PLAYLIST_BUTTON, "-", wx.wxPoint(45, 430), wx.wxSize(30, 30))
playSelectedButton = wx.wxButton(panel, ID_PLAY_SELECTED_TRACK_BUTTON, "LOAD", wx.wxPoint(80, 430), wx.wxSize(50, 30))

upButton = wx.wxButton(panel, ID_UP_BUTTON, "▲", wx.wxPoint(320, 430), wx.wxSize(30, 30))
downButton = wx.wxButton(panel, ID_DOWN_BUTTON, "▼", wx.wxPoint(355, 430), wx.wxSize(30, 30))

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
        str = string.format("%s/%s", msToMMSS(pos), msToMMSS(len))
        if not settingSliderPosition then
            duration:SetValue(sliderMax * pos / len)
        end
        time:SetLabel(str)
    end
)

timer:Start(300)

-- Scrolling through duration bar
panel:Connect(ID_DURATION_BAR, wx.wxEVT_SCROLL_THUMBTRACK,
    function(event)
        if not isLoaded then return end
        settingSliderPosition = true 
        local pos = event:GetPosition()
        local len = media:Length()
        
        local ok = media:Seek(math.floor(len * pos / sliderMax))
        if ok == wx.wxInvalidOffset then
            wx.wxMessageBox(string.format("Cannot to scroll"), "Error", wx.wxICON_ERROR + wx.wxOK)
        end
    end
)

panel:Connect(ID_DURATION_BAR, wx.wxEVT_SCROLL_THUMBRELEASE,
    function(event)
        if not isLoaded then return end
        settingSliderPosition = false
        thumbRelease = true
    end
)
panel:Connect(ID_DURATION_BAR, wx.wxEVT_SCROLL_CHANGED,
    function(event)
        if not isLoaded then return end
        if thumbRelease then
            thumbRelease = false
            return
        end
        local pos = event:GetPosition()
        local len = media:Length()
        
        local ok = media:Seek(math.floor(len * pos / sliderMax))
        if ok == wx.wxInvalidOffset then
            wx.wxMessageBox(string.format("Cannot to scroll"), "Error", wx.wxICON_ERROR + wx.wxOK)
        end
    end
)

-- Turn on/off repeat mode
frame:Connect(ID_REPEAT_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
  function(event)
    repeatOn = not repeatOn
    if repeatOn and randomOn then
        mode:SetLabel("Mode: Random / Repeat")
    elseif repeatOn and not randomOn then
        mode:SetLabel("Mode: Repeat")
    elseif not repeatOn and randomOn then
        mode:SetLabel("Mode: Random")
    else
        mode:SetLabel("Mode: None")
    end
  end
)
frame:Connect(ID_RANDOM_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
    function(event)
        randomOn = not randomOn
        if repeatOn and randomOn then
            mode:SetLabel("Mode: Random / Repeat")
        elseif repeatOn and not randomOn then
            mode:SetLabel("Mode: Repeat")
        elseif not repeatOn and randomOn then
            mode:SetLabel("Mode: Random")
        else
            mode:SetLabel("Mode: None")
        end
    end
)

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
        
        local songsNoExtension = {}
        
        for index, song in pairs(songs) do
            local title = song:match("(.+)%..+$")
            table.insert(songsNoExtension, title)
        end
        
        listBox:InsertItems(songsNoExtension, listBox:GetCount())
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
    if not (listBox:GetCount() > 0) then
        table.remove(playlist, selectedIndex + 1)
        return
    end
    if selectedIndex >= listBox:GetCount() then
        listBox:SetSelection(selectedIndex - 1)
    elseif listBox:GetCount() > 0 then
        listBox:SetSelection(selectedIndex - 1)
    end
    
    if selectedIndex <= currentSongIndex then  
        currentSongIndex = currentSongIndex - 1
    end
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
    currentSongIndex = selectedIndex
    title:SetLabel(file)
    media:SetVolume(volumeBar:GetValue() / sliderMax)
    stopPressed = true
  end
)

media:Connect(wx.wxEVT_MEDIA_STATECHANGED,
    function (event)
        if not (listBox:GetCount() > 0) then
            UpdateButtons()
            return 
        end
        UpdateButtons()
        -- Replay song if repeat mode on
        if isLoaded and repeatOn and media:GetState() == wx.wxMEDIASTATE_STOPPED and not stopPressed then
            media:Play()
        -- Check if the song is over with none mode on
        elseif isLoaded and not repeatOn and media:GetState() == wx.wxMEDIASTATE_STOPPED and not stopPressed and not autoPlay then 
            -- Check if the next song is a song at next index and load that song
            if randomOn then
                randomIndex = math.random(0, listBox:GetCount()-1)
                while currentSongIndex == randomIndex do
                    randomIndex = math.random(0, listBox:GetCount()-1)
                end
                currentSongIndex = randomIndex
                local file = listBox:GetString(currentSongIndex)
                media:Load(playlist[currentSongIndex + 1])
                title:SetLabel(file)
                UpdateButtons()
                autoPlay = true
            elseif listBox:GetCount() > currentSongIndex + 1 then                 
                isLoaded = false
                
                local file = listBox:GetString(currentSongIndex + 1)
                
                if not media:Load(playlist[currentSongIndex + 2]) then
                    wx.wxMessageBox(string.format("Cannot load  %s.", file), "Error", wx.wxICON_ERROR + wx.wxOK)
                    return
                end
                
                isLoaded = true
                currentSongIndex = currentSongIndex + 1
                title:SetLabel(file)
                media:SetVolume(volumeBar:GetValue() / sliderMax)
                autoPlay = true
            -- Next song is a song with index 0, load it
            else
                isLoaded = false
    
                local file = listBox:GetString(0)
                
                if not media:Load(playlist[1]) then
                    wx.wxMessageBox(string.format("Cannot load  %s.", file), "Error", wx.wxICON_ERROR + wx.wxOK)
                    return
                end
                
                isLoaded = true
                currentSongIndex = 0
                title:SetLabel(file)
                media:SetVolume(volumeBar:GetValue() / sliderMax)
                autoPlay = true
            end
            listBox:SetSelection(currentSongIndex)
        -- Play songs from playlist
        elseif isLoaded and not repeatOn and media:GetState() == wx.wxMEDIASTATE_STOPPED and not stopPressed and autoPlay then 
            media:Play()
            autoPlay = false
        end
    end
)

frame:Connect(ID_BACKWARDS_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
    function(event)
        if not isLoaded then return end
        if media:Tell() < 2000 and not randomOn then
        local indexDelta = 2
            if media:GetState() == wx.wxMEDIASTATE_STOPPED or repeatOn then indexDelta = 1 end
            if currentSongIndex == 0 then
                currentSongIndex = listBox:GetCount() - indexDelta
            elseif currentSongIndex == 1 and indexDelta == 2 then
                currentSongIndex = listBox:GetCount() + 1 - indexDelta 
            else
                currentSongIndex = currentSongIndex - indexDelta 
            end
            local file = listBox:GetString(currentSongIndex)
            if media:GetState() == wx.wxMEDIASTATE_STOPPED or repeatOn then listBox:SetSelection(currentSongIndex) end
            media:Load(playlist[currentSongIndex + 1])
            title:SetLabel(file)
            UpdateButtons()
        else
            media:Seek(0)
        end
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
    
    stopPressed = false
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
    
    stopPressed = true
  end
)
frame:Connect(ID_FORWARD_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
    function(event)
    if randomOn then
        randomIndex = math.random(0, listBox:GetCount()-1)
        while currentSongIndex == randomIndex do
            randomIndex = math.random(0, listBox:GetCount()-1)
        end
        currentSongIndex = randomIndex
        local file = listBox:GetString(currentSongIndex)
        if media:GetState() == wx.wxMEDIASTATE_STOPPED or repeatOn then listBox:SetSelection(currentSongIndex) end
        media:Load(playlist[currentSongIndex + 1])
        title:SetLabel(file)
        UpdateButtons()
    elseif media:GetState() == wx.wxMEDIASTATE_STOPPED or repeatOn then 
        currentSongIndex = currentSongIndex + 1
        if currentSongIndex >= listBox:GetCount() then currentSongIndex = 0 end
        local file = listBox:GetString(currentSongIndex)
        listBox:SetSelection(currentSongIndex)
        media:Load(playlist[currentSongIndex + 1])
        title:SetLabel(file)
        UpdateButtons()
    else
        local canStop = media:Stop()
    
        if not canStop then return end
    end
  end
)

-- Change volume
frame:Connect(ID_VOLUME_BAR, wx.wxEVT_SCROLL_CHANGED,
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
    
    if selectedIndex == currentSongIndex then 
        currentSongIndex = currentSongIndex - 1
    elseif selectedIndex  == currentSongIndex + 1 then
        currentSongIndex = currentSongIndex +1 
    end
    
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
    
    if selectedIndex == currentSongIndex then 
        currentSongIndex = currentSongIndex + 1
    elseif selectedIndex == currentSongIndex -1 then
        currentSongIndex = currentSongIndex - 1
    end
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