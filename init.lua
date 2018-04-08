hs.loadSpoon('Window')
hs.loadSpoon('Binder')

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


singleKey = spoon.Binder.singleKey
-- Spec of keymap:
-- Every key is of format {{modifers}, key, (optional) description}
-- The first two element is what you usually pass into a hs.hotkey.bind() function.
--
-- Each value of key can be in two form:
-- 1. A function. Then pressing the key invokes the function
-- 2. A table. Then pressing the key bring to another layer of keybindings.
--    And the table have the same format of top table: keys to keys, value to table or function
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
   -- [singleKey('h', '←')] = function() moveAndResize('left') moveWindowMode() end,
   -- [singleKey('j', '↓')] = function() moveAndResize('down') moveWindowMode() end,
   -- [singleKey('k', '↑')] = function() moveAndResize('up') moveWindowMode() end,
   -- [singleKey('l', '→')] = function() moveAndResize('right') moveWindowMode() end
}

keyNone = {}
hyperMod = {'control' , 'option', 'command'}

hs.hotkey.bind(hyperMod, 'space', nil, spoon.Binder.recursiveBind(mymapWithName))
hs.hotkey.bind(hyperMod, 'h', nil, spoon.Window.moveWindowLeft)
hs.hotkey.bind(hyperMod, 'j', nil, spoon.Window.moveWindowDown)
hs.hotkey.bind(hyperMod, 'k', nil, spoon.Window.moveWindowUp)
hs.hotkey.bind(hyperMod, 'l', nil, spoon.Window.moveWindowRight)
hs.hotkey.bind(hyperMod, 'f', nil, spoon.Window.moveWindowFullscreen)
hs.hotkey.bind(hyperMod, 'c', nil, spoon.Window.moveWindowCenter)
