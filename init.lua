
keyNone = {}
keyMod = {'control' , 'option', 'command'}
escapeKey = {keyNone, 'escape'}

-- used by nex model to close previous helper
local previousHelperID = nil

function recursiveBind(keymap)
   print(keymap)
   if type(keymap) == 'function' then
      -- in this case "keymap" is actuall a function
      return function() keymap() hs.alert.closeSpecific(previousHelperID) end
   end
   local modal = hs.hotkey.modal.new()
   local keyFuncNameTable = {}
   for key, map in pairs(keymap) do
      print('key', key, 'map', map)
      local func = recursiveBind(map)
      print('bind')
      modal:bind(key[1], key[2], function() func() modal:exit() end)
      modal:bind(escapeKey[1], escapeKey[2], function() print('escape') modal:exit() end)
      keyFuncNameTable[key[2]] = key[3]
   end
   return function()
      modal:enter()
      hs.alert.closeSpecific(previousHelperID)
      local helper = ''
      local separator = '' -- first loop doesn't need to add a separator, because it is in the very front. 
      for keyName, funcName in pairs(keyFuncNameTable) do
         if string.len(helper) > 30 then
            separator = '\n'
         end
         helper = helper..separator..keyName..'  :  '..funcName
         separator = '      '
      end
       -- bottom of screen, lasts for 3 sec, no border
      previousHelperID = hs.alert.show(helper, {atScreenEdge=2, fadeOutDuration=3, strokeColor={ white = 0, alpha = 2 }}, true)
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

function singleKey(key, name)
   if name then
      return {{}, key, name}
   else
      return {{}, key}
   end
end



function runCommand()
   local buttonValue, command = hs.dialog.textPrompt('', '', '', 'OK', "Cancel")
   if buttonValue == 'OK' then
      hs.execute(command)
   end
end


mymapWithName = {[singleKey('`', 'run command')] = runCommand, [singleKey('f', 'find+')] = {[singleKey('f', 'hello')] = function() hs.alert.show('hello!') end}}
hs.hotkey.bind(keyMod, 'space', nil, recursiveBind(mymapWithName))
