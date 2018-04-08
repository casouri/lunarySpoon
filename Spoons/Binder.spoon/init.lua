local obj={}
obj.__index = obj


-- Metadata
obj.name = "Binder"
obj.version = "0.7"
obj.author = "Yuan Fu <casouri@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"


--- Binder.escapeKey
--- Variable
--- key to abort, default to {keyNone, 'escape'}
obj.escapeKey = {keyNone, 'escape'}

--- Binder.recursiveBindHelperMaxLineLengthInChar
--- Variable
--- max length of helper measured in character
--- default is 80
obj.recursiveBindHelperMaxLineLengthInChar = 80

--- Binder.recursiveBindHelperFormat
--- format of helper, the helper is just a hs.alert
--- default to {atScreenEdge=2,
---                          strokeColor={ white = 0, alpha = 2 },
---                          textFont='SF Mono'}
obj.recursiveBindHelperFormat = {atScreenEdge=2,
                             strokeColor={ white = 0, alpha = 2 },
                             textFont='SF Mono'}

--- Binder.showBindHelper()
--- whether to show helper, can be true of false
obj.showBindHelper = true

-- used by next model to close previous helper
local previousHelperID = nil

-- this function is used by helper to display 
-- appropriate 'shift + key' bindings
-- it turns a lower key to the corresponding
-- upper key on keyboard
local function keyboardUpper(key)
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

--- Binder.singleKey(key, name)
--- Method
--- this function simply return a table with empty modifiers
--- also it translates capital letters to normal letter with shift modifer
---
--- Parameters:
---  * key - a letter
---  * name - the description to pass to the keys binding function
---
--- Returns:
---  * a table of modifiers and keys and names, ready to be used in keymap
---    to pass to Binder.recursiveBind()
function obj.singleKey(key, name)
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

-- generate a string representation of a key spec
-- {{'shift', 'command'}, 'a} -> 'shift+command+a'
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

-- show helper of available keys of current layer
local function showHelper(keyFuncNameTable)
   -- keyFuncNameTable is a table that key is key name and value is description
   local helper = ''
   local separator = '' -- first loop doesn't need to add a separator, because it is in the very front. 
   local lastLine = ''
   for keyName, funcName in pairs(keyFuncNameTable) do
      -- only measure the length of current line
      lastLine = string.match(helper, '\n.-$')
      if lastLine and string.len(lastLine) > obj.recursiveBindHelperMaxLineLengthInChar then
         separator = '\n'
      elseif not lastLine then
         separator = '\n'
      end
      helper = helper..separator..keyName..' → '..funcName
      separator = '   '
   end
   helper = string.match(helper, '[^\n].+$')
   previousHelperID = hs.alert.show(helper, obj.recursiveBindHelperFormat, true)
end

--- Binder.recursiveBind(keymap)
--- Method
--- Bind sequential keys by a nested keymap.
---
--- Parameters:
---  * keymap - A table that specifies the mapping.
---
--- Returns:
---  * A function to start. Bind it to a initial key binding.
---
--- Note:
--- Spec of keymap:
--- Every key is of format {{modifers}, key, (optional) description}
--- The first two element is what you usually pass into a hs.hotkey.bind() function.
--- 
--- Each value of key can be in two form:
--- 1. A function. Then pressing the key invokes the function
--- 2. A table. Then pressing the key bring to another layer of keybindings.
---    And the table have the same format of top table: keys to keys, value to table or function

-- the actual binding function
function obj.recursiveBind(keymap)
   if type(keymap) == 'function' then
      -- in this case "keymap" is actuall a function
      return keymap
   end
   local modal = hs.hotkey.modal.new()
   local keyFuncNameTable = {}
   for key, map in pairs(keymap) do
      local func = obj.recursiveBind(map)
      -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f' 
      modal:bind(key[1], key[2], function() modal:exit() hs.alert.closeSpecific(previousHelperID) func() end)
      modal:bind(obj.escapeKey[1], obj.escapeKey[2], function() modal:exit() hs.alert.closeSpecific(previousHelperID) end)
      if #key >= 3 then
         keyFuncNameTable[createKeyName(key)] = key[3]
      end
   end
   return function()
      modal:enter()
      if obj.showBindHelper then
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


return obj
