sh = require('spaceHammer')

--
-- Config
--

-- Emojis
hs.loadSpoon('Emojis')
sh.useSpoon{
   name = 'Emojis',
   config = function()
      local emojiModal = hs.hotkey.modal.new()
      emojiModal:bind({}, 'escape', function()
            spoon.Emojis.chooser:hide()
            emojiModal:exit()
      end)

      function insertEmoji()
         spoon.Emojis.chooser:show()
         emojiModal:enter()
      end
   end
}

-- Binder
sh.useSpoon{
   name = 'Binder',
   config = function()
      -- just a shortcut
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
         [singleKey('o', 'open+')] = {
            [singleKey('e', 'Emacs')] = function() hs.application.launchOrFocus('Emacs') end,
            [singleKey('s', 'Safari')] = function() hs.application.launchOrFocus('Safari') end,
            [singleKey('f', 'Finder')] = function() hs.application.launchOrFocus('Finder') end,
            [singleKey('d', 'Dictionary')] = function() hs.application.launchOrFocus('Dictionary') end,
            [singleKey('m', 'Mail')] = function() hs.application.launchOrFocus('Mail') end,
            [singleKey('q', 'QQ')] = function() hs.application.launchOrFocus('QQ') end,
            [singleKey('w', 'Wechat')] = function() hs.application.launchOrFocus('Wechat') end,
            [singleKey('g', 'Google')] = function() os.execute('open http://google.com') end,
         },
         [singleKey('i', 'insert+')] = {
            [singleKey('e', 'emoji')] = insertEmoji,
         }
      }

      local keyNone = {}
      local hyperMod = {'control' , 'option', 'command'}
      hs.hotkey.bind(hyperMod, 'space', spoon.Binder.recursiveBind(mymapWithName))
      -- config ends here
   end
}

-- Window
sh.useSpoon{
   name = 'Window',
   config = function()
      local hyperMod = {'control' , 'option', 'command'}
      hs.hotkey.bind(hyperMod, 'h', spoon.Window.moveWindowLeft)
      hs.hotkey.bind(hyperMod, 'j', spoon.Window.moveWindowDown)
      hs.hotkey.bind(hyperMod, 'k', spoon.Window.moveWindowUp)
      hs.hotkey.bind(hyperMod, 'l', spoon.Window.moveWindowRight)
      hs.hotkey.bind(hyperMod, 'f', spoon.Window.moveWindowFullscreen)
      hs.hotkey.bind(hyperMod, 'c', spoon.Window.moveWindowCenter)
   end
}
