package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "VinApp", wx.wxDefaultPosition, wx.wxSize(450, 450), wx.wxDEFAULT_FRAME_STYLE and not(wx.wxRESIZE_BORDER or wx.wxMAXIMIZE_BOX))

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