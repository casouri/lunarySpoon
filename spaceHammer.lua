local obj = {}
obj.__index = obj

function obj.runCommand()
   local buttonValue, command = hs.dialog.textPrompt('', '', '', 'OK', "Cancel")
   if buttonValue == 'OK' then
      hs.execute(command)
   end
end

function obj.openWithFinder(path)
   os.execute('open '..path)
   hs.application.launchOrFocus('Finder')
end

function obj.loadSpoonList(spoonList)
   for index = 1, #spoonList do
      hs.loadSpoon(spoonList[index])
   end
end

function obj.useSpoon(argTable)
   if argTable.init then
      argTable.init()
   end
   hs.loadSpoon(argTable.name)
   if argTable.config then
      return argTable.config()
   end
end

return obj
