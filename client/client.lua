-- Creating all the required menus
local charactersMenu = RageUI.CreateMenu('Characters', 'Choose a Character')
local createCharacter = RageUI.CreateSubMenu(charactersMenu, 'Make a Character', 'Description')
local charSelectConfirm = RageUI.CreateSubMenu(charactersMenu, 'Title', 'Description')
local confirmDelete = RageUI.CreateSubMenu(charSelectConfirm, 'Delete a Character', 'Description')
local charDetailsConfirm = RageUI.CreateSubMenu(createCharacter, 'Are You Sure?', 'Description')

-- Setting indexes for list items
local dob
local index = {
    dobDays = 1,
    dobMonths = 1,
    dobYears = 1,
    charHeight = 1,
    charWeight = 1,
    charSex = 1,
}

PlayerData = {}
ESX = nil

-- Menu cosmetics
charactersMenu:DisplayPageCounter(Config.DisplayPageCounterOnMainMenu)
createCharacter:DisplaySubtitle(false)
charDetailsConfirm:DisplaySubtitle(false)
charSelectConfirm:DisplaySubtitle(false)
confirmDelete:DisplaySubtitle(false)
charactersMenu.Closable = false
charSelectConfirm.TitleFont = 4
confirmDelete.TitleFont = 4

-- Character characteristics (hah) --
dobDays = {}
for i = 1, 31 do
    table.insert(dobDays, i)
end

dobMonths = {}
for i = 1, 12 do
    table.insert(dobMonths, i)
end

dobYears = {}
for i = Config.MinYear, Config.MaxYear do
    table.insert(dobYears, i)
end

charHeight = {}
for i = 60, 80 do
    table.insert(charHeight, i)
end

charWeight = {}
for i = 155, 400 do
    table.insert(charWeight, i)
end

charSex = {}
table.insert(charSex, 'Male')
table.insert(charSex, 'Female')
-- ----------------------------- -- 
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

-- Once player has connected, run the event
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NetworkIsPlayerActive(PlayerId()) and ESX ~= nil then
            TriggerEvent('luke_multicharacter:Characters')
            break
        end
    end
end)

RegisterNetEvent('luke_multicharacter:Characters')
AddEventHandler('luke_multicharacter:Characters', function()
    ESX.TriggerServerCallback('luke_multicharacter:FetchCharacters', function(playerCharacters)
        CharacterMenu(playerCharacters)
    end)
end)

function CharacterMenu(characters)
    local selectedChar
    local selectedSlot
    local inMenu = true
    RageUI.Visible(charactersMenu, not RageUI.Visible(charactersMenu))
    while inMenu == true do -- I have to set inMenu because true causes issues where menus would stack if closed and opened
        Citizen.Wait(1)
        RageUI.IsVisible(charactersMenu, function()
            for k, v in pairs(characters) do
                if v ~= 'Empty Slot' then
                    RageUI.Button(v, nil, {RightLabel = '→→'}, true, {
                        onSelected = function()
                            charSelectConfirm:SetTitle(v)
                            selectedChar = 'char'..k..':'
                        end,
                    }, charSelectConfirm);
                else
                    RageUI.Button(v, nil, {RightLabel = '→→→', Color = { HightLightColor = {191, 27, 27} }}, true, {
                        onSelected = function()
                            selectedSlot = 'char'..k..':'
                        end,
                    }, createCharacter);
                end
            end
        end, function() end)

        RageUI.IsVisible(charSelectConfirm, function()
            RageUI.Button('Play Character', nil, {RightLabel = '→'}, true, {
                onSelected = function()
                    inMenu = false
                    RageUI.CloseAll()
                    TriggerServerEvent('esx:onPlayerJoined', selectedChar)
                end,
            });
            RageUI.Button('Delete Character', nil, {Color = { HightLightColor = {204, 0, 0} }}, true, {
                onSelected = function()

                end,
            }, confirmDelete);
        end)

        RageUI.IsVisible(confirmDelete, function()
            RageUI.Button('Return', nil, {}, true, {
                onSelected = function()
                    
                end,
            }, charSelectConfirm);
            RageUI.Button('Confirm Delete', nil, {Color = { HightLightColor = {204, 0, 0} }}, true, {
                onSelected = function()
                    RageUI.CloseAll()
                    inMenu = false
                    Citizen.Wait(Config.StallTime)
                    TriggerServerEvent('luke_multicharacter:DeleteCharacter', selectedChar)
                end,
            });
        end)

        RageUI.IsVisible(createCharacter, function()
            RageUI.Button('First Name', nil, {RightLabel = firstName}, true, {
                onSelected = function()
                    firstName = KeyboardInput("First name: ", "", 15)
                end,
            });
            RageUI.Button('Last Name', nil, {RightLabel = lastName}, true, {
                onSelected = function()
                    lastName = KeyboardInput("Last name: ", "", 15)
                end,
            });
            RageUI.List('Day of Birth', dobDays, index.dobDays, nil, {}, true, {
                onListChange = function(Index, Item)
                    index.dobDays = Index;
                end,
                onSelected = function(Index, Item)
                end,
            })
            RageUI.List('Month of Birth', dobMonths, index.dobMonths, nil, {}, true, {
                onListChange = function(Index, Item)
                    index.dobMonths = Index;
                end,
                onSelected = function(Index, Item)
                end,
            })
            RageUI.List('Year of Birth', dobYears, index.dobYears, nil, {}, true, {
                onListChange = function(Index, Item)
                    index.dobYears = Index;
                end,
                onSelected = function(Index, Item)
                end,
            })
            RageUI.List('Height(in)', charHeight, index.charHeight, nil, {}, true, {
                onListChange = function(Index, Item)
                    index.charHeight = Index;
                end,
                onSelected = function(Index, Item)
                end,
            })
            RageUI.List('Weight(lbs)', charWeight, index.charWeight, nil, {}, true, {
                onListChange = function(Index, Item)
                    index.charWeight = Index;
                end,
                onSelected = function(Index, Item)
                end,
            })
            RageUI.List('Sex', charSex, index.charSex, nil, {}, true, {
                onListChange = function(Index, Item)
                    index.charSex = Index;
                end,
                onSelected = function(Index, Item)
                end,
            })
            RageUI.Button('Confirm Character', nil, {RightLabel = '→→→', Color = {HightLightColor = {26, 169, 201} }}, true, {
                onSelected = function()         
                    if firstName == '' or firstName == nil or lastName == '' or lastName == nil then
                        return
                    else
                        RageUI.Visible(charDetailsConfirm, not RageUI.Visible(charDetailsConfirm))
                    end
                    dob = index.dobDays..'/'..index.dobMonths..'/'..dobYears[index.dobYears]
                    charDetailsDescription = "First Name: ~b~"..firstName.."\n~w~Last Name: ~b~"..lastName..'\n~w~DoB: ~b~'..dob..'\n~w~Sex: ~b~'..charSex[index.charSex]
                end,
            });
        end, function() end)

        RageUI.IsVisible(charDetailsConfirm, function()
            RageUI.Button('No', charDetailsDescription, {}, true, {
                onSelected = function()

                end
            }, createCharacter);
            RageUI.Button('Yes', charDetailsDescription, {RightLabel = '→→→', Color = {HightLightColor = {26, 169, 201} }}, true, {
                onSelected = function()
                    if firstName == nil or firstName == '' or lastName == nil or lastName == '' then
                        return
                    else
                        -- This will create the character and load the player in
                        inMenu = false
                        TriggerServerEvent('esx:onPlayerJoined', selectedSlot)
                        RageUI.CloseAll()
                        Citizen.Wait(Config.StallTime)
                        TriggerServerEvent('luke_multicharacter:CreateCharacter', selectedSlot, firstName, lastName, charSex[index.charSex], dob, charHeight[index.charHeight], charWeight[index.charWeight])
                    end
                end
            });
        end)
    end
end

-- Not mine, borrowed
function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(200) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(200) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end
-- Kada igrac izabere karaktera treba da trigeruje taj event
--TriggerServerEvent('esx:onPlayerJoined', characterId)