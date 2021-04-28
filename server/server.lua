local noCharacters = true
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('luke_multicharacter:FetchCharacters', function(source, callback)
    local playerCharacters = {}
    local emptySlots = {}
    for k,v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end
    if identifier then
        for i = 1, Config.CharacterSlots do
            MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
                ['@identifier'] = 'char'..i..':'..identifier
            }, function(data)
                for k, v in ipairs(data) do
                    name = v.firstname..' '..v.lastname
                    table.insert(playerCharacters, name)
                end
                if not data[1] then
                    table.insert(playerCharacters, 'Empty Slot')
                end
                if i == Config.CharacterSlots then
                    callback(playerCharacters, emptySlots)
                end
            end)
            Citizen.Wait(100) -- This citizen.wait is here because sometimes the data would
            -- run so fast that some would get lost, this fixes that, hopefully
        end
    end
end)

RegisterNetEvent('luke_multicharacter:CreateCharacter')
AddEventHandler('luke_multicharacter:CreateCharacter', function(charSlot, firstName, lastName, sex, dateOfBirth, height, weight)
    -- Setting values for sex for the database
    if sex == 'Male' then
        sex = 'M'
    else
        sex = 'F'
    end
    print(sex)
    MySQL.Async.execute('UPDATE `users` SET firstname = @firstname, lastname = @lastname, sex = @sex, dateofbirth = @dob, height = @height, weight = @weight WHERE identifier = @identifier', {
        ['@identifier'] = charSlot..identifier,
        ['@firstname'] = firstToUpper(firstName),
        ['@lastname'] = firstToUpper(lastName),
        ['@sex'] = sex,
        ['@dob'] = dateOfBirth,
        ['@height'] = height,
        ['@weight'] = weight
    }, function()
    end)
end)

RegisterNetEvent('luke_multicharacter:DeleteCharacter')
AddEventHandler('luke_multicharacter:DeleteCharacter', function(charSlot)
    MySQL.Async.execute('DELETE FROM users WHERE identifier = @identifier', {
        ['@identifier'] = charSlot..identifier,
    }, function()

    end)
    TriggerClientEvent('luke_multicharacter:Characters', source)
end)

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end