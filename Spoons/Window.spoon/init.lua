local obj={}
obj.__index = obj

local previousCommand = ''
local moveWindowModal = nil

local function calculateOption(command)
   if (command == 'left' and previousCommand == 'up')
   or (command == 'up' and previousCommand == 'left') then
      previousCommand = command
      return 'cornerNW'
   elseif (command == 'right' and previousCommand == 'up')
   or (command == 'up' and previousCommand == 'right') then
      previousCommand = command
      return 'cornerNE'
   elseif (command == 'left' and previousCommand == 'down')
   or (command == 'down' and previousCommand == 'left') then
      previousCommand = command
      return 'cornerSW'
   elseif (command == 'right' and previousCommand == 'down')
   or (command == 'down' and previousCommand == 'right') then
      previousCommand = command
      return 'cornerSE'
   elseif command == 'left' then
      previousCommand = command
      return 'halfleft'
   elseif command == 'right' then
      previousCommand = command
      return 'halfright'
   elseif command == 'up' then
      previousCommand = command
      return 'halfup'
   elseif command == 'down' then
      previousCommand = command
      return 'halfdown'
   else
      previousCommand = command
      return command
   end
end

local function moveAndResize(option)
    local cwin = hs.window.focusedWindow()
    if cwin then
        local cscreen = cwin:screen()
        local cres = cscreen:fullFrame()
        local wf = cwin:frame()
        option = calculateOption(option)
        if option == "halfleft" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
        elseif option == "halfright" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
        elseif option == "halfup" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
        elseif option == "halfdown" then
            cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
        elseif option == "cornerNW" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerNE" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerSW" then
            cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        elseif option == "cornerSE" then
            cwin:setFrame({x=cres.x+cres.w/2, y=cres.y+cres.h/2, w=cres.w/2, h=cres.h/2})
        elseif option == "fullscreen" then
            cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
        elseif option == "center" then
            cwin:centerOnScreen()
        end
    else
        hs.alert.show("No focused window!")
    end
end


local function enterMoveWindowMode()
   moveWindowModal = hs.hotkey.modal.new()
   moveWindowModal:bind({}, 'h', function() moveAndResize('left') end)
   moveWindowModal:bind({}, 'j', function() moveAndResize('down') end)
   moveWindowModal:bind({}, 'k', function() moveAndResize('up') end)
   moveWindowModal:bind({}, 'l', function() moveAndResize('right') end)
   moveWindowModal:bind({}, 'c', function() moveAndResize('center') end)
   moveWindowModal:bind({}, 'f', function() moveAndResize('fullscreen') end)
   moveWindowModal:bind({}, 'q', function() moveWindowModal:exit() end)
   moveWindowModal:bind({}, 'escape', function() moveWindowModal:exit() end)
   moveWindowModal:enter()
end

--- Window.moveWindowDown
--- Function
--- Move the focused window down and occupy lower half of the screen.
function obj.moveWindowDown()
   moveAndResize('down')
end

--- Window.moveWindowUp
--- Function
--- Move the focused window up and occupy upper half of the screen.
function obj.moveWindowUp()
   moveAndResize('up')
end

--- Window.moveWindowLeft
--- Function
--- Move the focused window left and occupy left half of the screen.
function obj.moveWindowLeft()
   moveAndResize('left')
end

--- Window.moveWindowRight
--- Function
--- Move the focused window right and occupy right half of the screen.
function obj.moveWindowRight()
   moveAndResize('right')
end

return obj
