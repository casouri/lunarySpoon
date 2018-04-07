
keyNone = {}
keyMod = {'control' , 'option', 'command'}
escapeKey = {keyNone, 'escape'}

-- used by next model to close previous helper
local previousHelperID = nil
recursiveBindHelperMaxLineLengthInChar = 80
recursiveBindHelperFormat = {atScreenEdge=2,
                             strokeColor={ white = 0, alpha = 2 },
                             textFont='SF Mono'}

local function createKeyName(key)
   -- key is in the form {{modifers}, key, (optional) name}
   -- create proper key name for helper
   if #key[1] == 1 and key[1][1] == 'shift' then
      -- shift + key map to Uppercase key
      -- shift + d --> D
      return keyboardUpper(key[2])
   else
      -- append each modifiers together
      local keyName = ''
      if #key[1] >= 1 then
         for count = 1, #key[1] do
            if count == 1 then
               keyName = key[1][count]
            else 
               keyName = keyName..' + '..key[1][count]
            end
         end
      end
      -- finally append key, e.g. 'f', after modifers
      return keyName..key[2]
   end
end

local function showHelper(keyFuncNameTable)
   -- keyFuncNameTable is a table that key is key name and value is description
   local helper = ''
   local separator = '' -- first loop doesn't need to add a separator, because it is in the very front. 
   local lastLine = ''
   for keyName, funcName in pairs(keyFuncNameTable) do
      -- only measure the length of current line
      lastLine = string.match(helper, '\n.-$')
      if lastLine and string.len(lastLine) > recursiveBindHelperMaxLineLengthInChar then
         separator = '\n'
      elseif not lastLine then
         separator = '\n'
      end
      helper = helper..separator..keyName..' → '..funcName
      separator = '   '
   end
   helper = string.match(helper, '[^\n].+$')
   -- bottom of screen, lasts for 3 sec, no border
   previousHelperID = hs.alert.show(helper, recursiveBindHelperFormat, true)
end
   
showBindHelper = true
function recursiveBind(keymap)
   if type(keymap) == 'function' then
      -- in this case "keymap" is actuall a function
      return keymap
   end
   local modal = hs.hotkey.modal.new()
   local keyFuncNameTable = {}
   for key, map in pairs(keymap) do
      local func = recursiveBind(map)
      -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f' 
      modal:bind(key[1], key[2], function() modal:exit() hs.alert.closeSpecific(previousHelperID) func() end)
      modal:bind(escapeKey[1], escapeKey[2], function() modal:exit() hs.alert.closeSpecific(previousHelperID) end)
      if #key >= 3 then
         keyFuncNameTable[createKeyName(key)] = key[3]
      end
   end
   return function()
      modal:enter()
      if showHelper then
         showHelper(keyFuncNameTable)
      end
   end
end

-- function testrecursiveModal(keymap)
--    print(keymap)
--    if type(keymap) == 'number' then
--       return keymap
--    end
--    print('make new modal')
--    for key, map in pairs(keymap) do
--       print('key', key, 'map', testrecursiveModal(map))
--    end
--    return 0
-- end

-- mymap = {f = { r = 1, m = 2}, s = {r = 3, m = 4}, m = 5}
-- testrecursiveModal(mymap)

function keyboardUpper(key)
   local upperTable = {
    a='A', 
    b='B', 
    c='C', 
    d='D', 
    e='E', 
    f='F', 
    g='G', 
    h='H', 
    i='I', 
    j='J', 
    k='K', 
    l='L', 
    m='M', 
    n='N', 
    o='O', 
    p='P', 
    q='Q', 
    r='R', 
    s='S', 
    t='T', 
    u='U', 
    v='V', 
    w='W', 
    x='X', 
    y='Y', 
    z='Z', 
    ['`']='~',
    ['1']='!',
    ['2']='@',
    ['3']='#',
    ['4']='$',
    ['5']='%',
    ['6']='^',
    ['7']='&',
    ['8']='*',
    ['9']='(',
    ['0']=')',
    ['-']='_',
    ['=']='+',
    ['[']='}',
    [']']='}',
    ['\\']='|',
    [';']=':',
    ['\'']='"',
    [',']='<',
    ['.']='>',
    ['/']='?'
   }
   uppperKey = upperTable[key]
   if uppperKey then
      return uppperKey
   else
      return key
   end
end

function singleKey(key, name)
   local mod = {}
   if key == keyboardUpper(key) then
      mod = {'shift'}
      print('shift+'..key)
      print(mod)
      key = string.lower(key)
   end

   if name then
      return {mod, key, name}
   else
      return {mod, key, 'no name'}
   end
end



function runCommand()
   local buttonValue, command = hs.dialog.textPrompt('', '', '', 'OK', "Cancel")
   if buttonValue == 'OK' then
      hs.execute(command)
   end
end

function openWithFinder(path)
   os.execute('open '..path)
   hs.application.launchOrFocus('Finder')
end

local previousCommand = ''
function calculateOption(command)
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

function moveAndResize(option)
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

local moveWindowModal = nil

function moveWindowMode()
   moveWindowModal = hs.hotkey.modal.new()
   moveWindowModal:bind({}, 'h', function() moveAndResize('left') end)
   moveWindowModal:bind({}, 'j', function() moveAndResize('down') end)
   moveWindowModal:bind({}, 'k', function() moveAndResize('up') end)
   moveWindowModal:bind({}, 'l', function() moveAndResize('right') end)
   moveWindowModal:bind({}, 'c', function() moveAndResize('center') end)
   moveWindowModal:bind({}, 'f', function() moveAndResize('fullscreen') end)
   moveWindowModal:bind({}, 'q', function() moveWindowModal:exit() end)
   moveWindowModal:bind({}, 'escape', function() moveWindowModal:exit() end)
   -- for key, value in pairs(hs.keycodes.map) do
   --    if key ~= 'h' and key ~= 'j' and key ~= 'k' and key ~= 'l' then
   --       moveWindowModal:bind({}, key, function() moveWindowModal:exit() end)
   --    end
   -- end
   moveWindowModal:enter()
end

mymapWithName = {
   [singleKey('`', 'run command')] = runCommand,
   [singleKey('f', 'find+')] = {
      [singleKey('D', 'Desktop')] = function() openWithFinder('~/Desktop') end,
      [singleKey('p', 'Project')] = function() openWithFinder('~/p') end,
      [singleKey('d', 'Download')] = function() openWithFinder('~/Downloads') end,
      [singleKey('a', 'Application')] = function() openWithFinder('~/Applications') end,
      [singleKey('h', 'home')] = function() openWithFinder('~') end,
      [singleKey('f', 'hello')] = function() hs.alert.show('hello!') end},
   [singleKey('t', 'toggle+')] = {
      [singleKey('v', 'file visible')] = function() hs.eventtap.keyStroke({'cmd', 'shift'}, '.') end
   },
   [singleKey('h', '←')] = function() moveAndResize('left') moveWindowMode() end,
   [singleKey('j', '↓')] = function() moveAndResize('down') moveWindowMode() end,
   [singleKey('k', '↑')] = function() moveAndResize('up') moveWindowMode() end,
   [singleKey('l', '→')] = function() moveAndResize('right') moveWindowMode() end
}

hs.hotkey.bind(keyMod, 'space', nil, recursiveBind(mymapWithName))
