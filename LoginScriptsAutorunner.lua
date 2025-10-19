--[[

	LoginScriptsAutorunner: Runs a set of scripts on Load
		copyright 2019 by xds

]]

local _rootFrame = CreateFrame("Frame", "LoginScriptsAutorunnerFrame", UIParent);
_rootFrame:Hide(); -- will be shown at the end of the initialization if the loaded settings say so

local _global, _elapsedTimeSinceLastFiring, _interval = (_G or getenv(0)), 0, 5 -- 5seconds
local function LoginScriptsAutorunner_OnUpdate()
    _elapsedTimeSinceLastFiring = _elapsedTimeSinceLastFiring + _global.arg1 --00
    if _elapsedTimeSinceLastFiring < _interval then
        return
    end

    repeat
        _elapsedTimeSinceLastFiring = _elapsedTimeSinceLastFiring - _interval --10
    until _elapsedTimeSinceLastFiring < _interval

    do
        _rootFrame:Hide(); -- we only needed it to lazy-trigger this script block a few seconds after login
        _rootFrame:SetScript("OnUpdate", nil); -- disable further OnUpdate invocations
        
        DEFAULT_CHAT_FRAME:AddMessage("[LSA] Loaded lazily after " .. _interval .. " seconds delay", 0.5, 1.0, 0.5);

        -- SetCVar("UIScale", 0.1);

        if QuestFrame ~= nil and QuestFrame.SetScale then
            QuestFrame:SetScale(2);
        end

        if HideNameplates ~= nil then
            HideNameplates(); -- hide nameplates by default when logging in    
        end

        if HideFriendNameplates ~= nil then
            HideFriendNameplates(); -- hide nameplates by default when logging in
        end

        -- SpellStopCasting(); -- todo   this still doesnt work for some weird reason and I dont know why ... 
        CastSpellByName("Find Minerals"); -- enable sensible tracking by default when logging in
        CastSpellByName("Find Herbs");
        CastSpellByName("Find Treasure");
        CastSpellByName("Track Humanoids");
        CastSpellByName("Track Beasts");
        CastSpellByName("Sense Undead");
    end

    -- 00  arg1 is the elapsed time since the previous callback invocation   there is no other way to get this value
    --     other than grabbing it from the global environment like we do here   very strange but true
    --
    -- 10  _elapsedTimeSinceLastFiring >= _interval   its important to trim down the excess time as much as it is
    --     necessary to ensure it goes beneath the interval threshold
end

local function LoginScriptsAutorunner_OnEvent()
    local eventSnapshot = _global.event
    local addonThatJustGotLoaded = _global.arg1
    
    if eventSnapshot == "ADDON_LOADED" and addonThatJustGotLoaded == "LoginScriptsAutorunner" then
        _rootFrame:SetScript("OnUpdate", LoginScriptsAutorunner_OnUpdate); -- start the OnUpdate loop to run our code a few seconds after login
        _rootFrame:Show(); -- vital
        return
    end
end

_rootFrame:RegisterEvent("ADDON_LOADED"); -- :SetScript("OnLoad", ...) would not work because it only works if defined via the xml file!
_rootFrame:SetScript("OnEvent", LoginScriptsAutorunner_OnEvent);
