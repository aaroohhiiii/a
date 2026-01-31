--[[
  INTRO IMAGE SEQUENCE (fake video) for Core
  Plays PNG frames on a UI Image at ~25 FPS (0.04s per frame).
  This is how official Core splash screens work.

  SETUP:
  1. Convert your video to PNG frames (see CONVERSION.txt in this folder).
  2. Import all frame PNGs into Core (Project Content → Import).
  3. Add custom property "IntroImage" (UI Image reference) — assign your fullscreen UI Image.
  4. Fill FRAME_ASSET_IDS below with each frame's Asset ID (MUID) in order.
     Right‑click an image in Project → Copy Asset ID, paste into the table.
  5. Place this script in a Client context (e.g. under Client folder).
  6. Optional: listen for "IntroImageSequence_Finished" to transition to gameplay (e.g. hide panel, enable input).
]]

local INTRO_IMAGE = script:GetCustomProperty("IntroImage"):WaitForObject()
local FRAME_DURATION = 0.5  -- 2 FPS (~60 frames for ~30 sec intro)

-- Add your frame asset IDs in order (frame_001, frame_002, ...). Get ID: Right‑click image in Project → Copy Asset ID.
local FRAME_ASSET_IDS = {
  -- Example: "A1B2C3D4E5F6...",
  -- Paste one ID per line, in order.
}

local currentTask = nil

-- Other scripts can start the intro with: Events.Broadcast("IntroImageSequence_Play")
Events.Connect("IntroImageSequence_Play", function()
  PlayIntroSequence()
end)

function PlayIntroSequence()
  if #FRAME_ASSET_IDS == 0 then
    warn("[IntroImageSequence] FRAME_ASSET_IDS is empty. Add your frame asset IDs in the script.")
    return
  end

  if currentTask and currentTask:GetStatus() == Task.Status.RUNNING then
    return
  end

  currentTask = Task.Spawn(function()
    for i, assetId in ipairs(FRAME_ASSET_IDS) do
      INTRO_IMAGE:SetImage(assetId)
      Task.Wait(FRAME_DURATION)
    end
    Events.Broadcast("IntroImageSequence_Finished")
  end)
end

function StopIntroSequence()
  if currentTask and currentTask:GetStatus() == Task.Status.RUNNING then
    currentTask:Cancel()
    currentTask = nil
  end
end

-- Auto-play when script runs. Comment out to trigger only via Events.Broadcast("IntroImageSequence_Play").
PlayIntroSequence()

-- Other scripts: listen for "IntroImageSequence_Finished" to transition to gameplay, e.g.:
-- Events.Connect("IntroImageSequence_Finished", function() ... end)
