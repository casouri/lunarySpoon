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


-- Spec of keymap:
-- Every key is of format {{modifers}, key, (optional) description}
-- The first two element is what you usually pass into a hs.hotkey.bind() function.
--
-- Each value of key can be in two form:
-- 1. A function. Then pressing the key invokes the function
-- 2. A table. Then pressing the key bring to another layer of keybindings.
--    And the table have the same format of top table: keys to keys, value to table or function
mymapWithName = {
   [spoon.Binder.singleKey('`', 'run command')] = runCommand,
   [spoon.Binder.singleKey('f', 'find+')] = {
      [spoon.Binder.singleKey('D', 'Desktop')] = function() openWithFinder('~/Desktop') end,
      [spoon.Binder.singleKey('p', 'Project')] = function() openWithFinder('~/p') end,
      [spoon.Binder.singleKey('d', 'Download')] = function() openWithFinder('~/Downloads') end,
      [spoon.Binder.singleKey('a', 'Application')] = function() openWithFinder('~/Applications') end,
      [spoon.Binder.singleKey('h', 'home')] = function() openWithFinder('~') end,
      [spoon.Binder.singleKey('f', 'hello')] = function() hs.alert.show('hello!') end},
   [spoon.Binder.singleKey('t', 'toggle+')] = {
      [spoon.Binder.singleKey('v', 'file visible')] = function() hs.eventtap.keyStroke({'cmd', 'shift'}, '.') end
   },
   -- [spoon.Binder.singleKey('h', '←')] = function() moveAndResize('left') moveWindowMode() end,
   -- [spoon.Binder.singleKey('j', '↓')] = function() moveAndResize('down') moveWindowMode() end,
   -- [spoon.Binder.singleKey('k', '↑')] = function() moveAndResize('up') moveWindowMode() end,
   -- [spoon.Binder.singleKey('l', '→')] = function() moveAndResize('right') moveWindowMode() end
}

keyNone = {}
hyperMod = {'control' , 'option', 'command'}

hs.hotkey.bind(hyperMod, 'space', nil, spoon.Binder.recursiveBind(mymapWithName))
hs.hotkey.bind(hyperMod, 'h', nil, spoon.Window.moveWindowLeft)
hs.hotkey.bind(hyperMod, 'j', nil, spoon.Window.moveWindowDown)
hs.hotkey.bind(hyperMod, 'k', nil, spoon.Window.moveWindowUp)
hs.hotkey.bind(hyperMod, 'l', nil, spoon.Window.moveWindowRight)
