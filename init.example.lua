sh = require('lunarySpoon')
command_table={}


--
-- Config
--

-- FnMate
sh.useSpoon{
   name = 'FnMate',
}

-- Seal
-- sh.useSpoon{
--    name = 'Seal',
--    config = function()
--       spoon.Seal:loadPlugins{'apps', 'calc', 'safari_bookmarks', 'screencapture'}
--       spoon.Seal:start()
--       spoon.Seal.chooser:bgDark(true)
--       spoon.Seal.chooser:fgColor{hex='#DDDDDD', alpha=1}
--       spoon.Seal.chooser:subTextColor{hex='#DDDDDD', alpha=1}
--    end
-- }

-- Commander
sh.useSpoon{
   name = 'Commander',
   config = function()
      spoon.Commander.chooser:bgDark(true)
      spoon.Commander.forceLayout = 'ABC'
   end
}

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


-- RecursiveBinder
sh.useSpoon{
   name = 'RecursiveBinder',
   config = function()
      spoon.RecursiveBinder.escapeKey = {{'control'}, 'g'}
      -- just a shortcut
      singleKey = spoon.RecursiveBinder.singleKey
      -- Spec of keymap:
      -- Every key is of format {{modifers}, key, (optional) description}
      -- The first two element is what you usually pass into a hs.hotkey.bind() function.
      --
      -- Each value of key can be in two form:
      -- 1. A function. Then pressing the key invokes the function
      -- 2. A table. Then pressing the key bring to another layer of keybindings.
      --    And the table have the same format of top table: keys to keys, value to table or function
      mymapWithName = {
         [{{}, 'space', 'Commander'}] = spoon.Commander.show,
         -- [{{'shift'}, 'space', 'Seal'}] = function() spoon.Seal:show() end,
         [singleKey('`', 'run command')] = runCommand,
         [singleKey('f', 'file+')] = {
            [singleKey('D', 'Desktop')] = function() openWithFinder('~/Desktop') end,
            [singleKey('p', 'Project')] = function() openWithFinder('~/p') end,
            [singleKey('d', 'Download')] = function() openWithFinder('~/Downloads') end,
            [singleKey('a', 'Application')] = function() openWithFinder('~/Applications') end,
            [singleKey('h', 'home')] = function() openWithFinder('~') end,
            [singleKey('f', 'hello')] = function() hs.alert.show('hello!') end},
         [singleKey('t', 'toggle+')] = {
            [singleKey('v', 'file visible')] = function() hs.eventtap.keyStroke({'cmd', 'shift'}, '.') end,
         },
         [singleKey('a', 'app+')] = {
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
         },
         [singleKey('c', 'console+')] = {
            [singleKey('c', 'Console')] = function() hs.console.hswindow():focus() end,
            [singleKey('r', 'reload config')] = hs.reload,
         }
      }

      local keyNone = {}
      hs.hotkey.bind({'control', 'option'}, 'space', spoon.RecursiveBinder.recursiveBind(mymapWithName))

      spoon.RecursiveBinder.helperFormat.textFont = 'SF Mono'
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

-- emacs-china

local function Chinese()
  hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM")
end

local function English()
  hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end

local function set_app_input_method(app_name, set_input_method_function, event)
  event = event or hs.window.filter.windowFocused

  hs.window.filter.new(app_name)
    :subscribe(event, function()
                 set_input_method_function()
              end)
end

set_app_input_method('Hammerspoon', English, hs.window.filter.windowCreated)
set_app_input_method('Spotlight', English, hs.window.filter.windowCreated)
set_app_input_method('Emacs', English)
set_app_input_method('iTerm2', English)
set_app_input_method('Safari', English)
set_app_input_method('WeChat', Chinese)

-- This method slows down keystokes

-- cxBinding = hs.hotkey.bind({'control'}, 'x', function()
--       print('C-x')
--       cxBinding:disable()
--       hs.eventtap.keyStroke({'control'}, 'x')
--       switchInputMethod()
--       -- to prevent infinite loop
--       hs.timer.doAfter(1, function() cxBinding:enable() end)
-- end)

-- function switchInputMethod()
--     if hs.execute('xkbswitch -g', true) ~= 2 then
--        switchedInput = true
--        hs.execute('xkbswtich -s 2', true)
--     end
-- end


-- function switchInputMethodBack()
--    if switchedInput then
--       switchedInput = false
--       hs.execute('xkbswitch -s 0', true)
--    end
-- end
   
-- hs.allowAppleScript(true)
