ScootsCraft.loadOptions = function()
    if(ScootsCraft.optionsLoaded) then
        return nil
    end
    
    ScootsCraft.options = {
        ['active'] = true,
        ['recipe-tooltip'] = nil,
        ['draggable'] = false,
        ['remember-filters'] = false
    }
    
    if(ScootsCraft.addonLoaded and _G['SCOOTSCRAFT_OPTIONS'] ~= nil) then
        for key, value in pairs(_G['SCOOTSCRAFT_OPTIONS']) do
            ScootsCraft.options[key] = value
        end
        
        ScootsCraft.optionsLoaded = true
    end
end

ScootsCraft.setOption = function(key, value)
    if(not ScootsCraft.optionsLoaded) then
        ScootsCraft.loadOptions()
    end
    
    ScootsCraft.options[key] = value
    
    if(ScootsCraft.addonLoaded) then
        _G['SCOOTSCRAFT_OPTIONS'] = ScootsCraft.options
    end
end

ScootsCraft.getOption = function(key)
    if(not ScootsCraft.optionsLoaded) then
        ScootsCraft.loadOptions()
    end
    
    return ScootsCraft.options[key]
end

ScootsCraft.extractId = function(link)
    if(link) then
        local subString = string.match(link, 'item:%d+')
        if(subString) then
            return 'item', tonumber(string.match(subString, '%d+'))
        end
        
        subString = string.match(link, 'enchant:%d+')
        if(subString) then
            return 'spell', tonumber(string.match(subString, '%d+'))
        end
    end
    
    return 'unknown', nil
end

ScootsCraft.mapInvTypeToSlot = function(invType)
    local map = {
        ['INVTYPE_RANGEDRIGHT'] = 'Ranged',
        ['INVTYPE_SHIELD'] = 'Off Hand',
        ['INVTYPE_WEAPON'] = '1H Weapon',
        ['INVTYPE_2HWEAPON'] = '2H Weapon',
        ['INVTYPE_WRIST'] = 'Wrist',
        ['INVTYPE_TRINKET'] = 'Trinket',
        ['INVTYPE_NECK'] = 'Neck',
        ['INVTYPE_CLOAK'] = 'Back',
        ['INVTYPE_BODY'] = 'Shirt',
        ['INVTYPE_HEAD'] = 'Head',
        ['INVTYPE_FEET'] = 'Feet',
        ['INVTYPE_ROBE'] = 'Chest',
        ['INVTYPE_BAG'] = 'Container',
        ['INVTYPE_HOLDABLE'] = 'Off Hand',
        ['INVTYPE_AMMO'] = 'Ammunition',
        ['INVTYPE_FINGER'] = 'Finger',
        ['INVTYPE_THROWN'] = 'Ranged',
        ['INVTYPE_HAND'] = 'Hands',
        ['INVTYPE_WAIST'] = 'Waist',
        ['INVTYPE_LEGS'] = 'Legs',
        ['INVTYPE_SHOULDER'] = 'Shoulder',
        ['INVTYPE_CHEST'] = 'Chest',
        ['INVTYPE_WEAPONMAINHAND'] = '1H Weapon'
    }
    
    if(map[invType]) then
        return map[invType]
    end
    
    return 'Created Items'
end

ScootsCraft.mapSpellIdToSlot = function(spellId)
    local map = {
        ['Head'] = {
            67839
        },
        ['Shoulders'] = {
            61117, 61118, 61119, 61120
        },
        ['Back'] = {
            55002, 63765, 55769, 55642, 55777, 44631, 47899, 44591, 47898, 47672, 60663, 44596, 44556, 44500, 44582, 47051, 34005, 60609, 34003, 34004, 27961, 25086, 25081, 25082, 25083, 25084, 20015, 20014, 13882, 13746, 13794, 13657, 13635, 13522, 7861, 13421, 13419, 7771, 7454, 44483, 44494, 44590, 34006, 27962
        },
        ['Chest'] = {
            60692, 44588, 47900, 44509, 47766, 44492, 46594, 44623, 27958, 27960, 33992, 33990, 27957, 20025, 20028, 33991, 20026, 13941, 13917, 13858, 13700, 13663, 13640, 13626, 13607, 13538, 7857, 7748, 7426, 7443, 7420, 7776
        },
        ['Wrist'] = {
            55628, 57683, 57691, 57690, 62256, 60767, 44575, 44593, 44598, 44616, 44635, 44555, 60616, 27914, 27913, 27911, 27905, 27899, 34001, 34002, 23802, 23801, 20011, 20009, 20008, 13945, 13939, 13931, 13846, 13822, 13661, 13646, 13648, 13642, 13622, 13536, 13501, 7859, 7779, 7782, 7766, 7457, 7428, 7418, 27917, 27906, 20010
        },
        ['Hands'] = {
            55641, 54998, 54999, 63770, 44625, 60668, 44529, 44488, 44484, 44513, 44592, 44506, 33997, 33994, 33999, 33995, 33996, 33993, 25078, 20013, 25079, 25073, 25080, 25072, 20012, 13948, 13947, 13868, 13887, 13841, 13815, 13698, 13620, 71692, 25074, 13617, 13612
        },
        ['Waist'] = {
            54736, 54793
        },
        ['Legs'] = {
            60583, 60584, 56034, 56039
        },
        ['Feet'] = {
            55016, 60763, 47901, 44589, 44508, 44584, 60623, 60606, 44528, 27954, 34008, 27951, 27950, 27948, 20023, 20024, 20020, 13935, 63746, 13890, 13836, 13687, 13644, 13637, 7867, 7863, 34007
        },
        ['Finger'] = {
            44645, 44636, 59636, 27926, 27927, 27924, 27920
        },
        ['1H Weapon'] = {
            64441, 64579, 59619, 59621, 59625, 60714, 60707, 44621, 44524, 44576, 44633, 44510, 44629, 60621, 42974, 27984, 27982, 27981, 28004, 28003, 34010, 27975, 27967, 27972, 42620, 46578, 23800, 20034, 22750, 20032, 23804, 23803, 22749, 23799, 20031, 20033, 20029, 13898, 13943, 13915, 13693, 13653, 13655, 13503, 7786, 7788, 27968, 21931
        },
        ['2H Weapon'] = {
            62948, 60691, 44595, 44630, 62959, 27977, 27971, 27837, 20036, 20035, 20030, 13937, 13695, 13529, 13380, 7745, 7793
        },
        ['Off Hand'] = {
            44489, 60653, 27946, 44383, 27945, 34009, 27944, 20016, 20017, 13933, 13905, 13817, 13689, 13659, 13631, 13485, 13464, 13378
        },
        ['Created Items'] = {
            60893, 61177, 61288, 69412
        }
    }
    
    for slot, idList in pairs(map) do
        for _, mappedSpellId in pairs(idList) do
            if(spellId == mappedSpellId) then
                return slot
            end
        end
    end
    
    return nil
end

ScootsCraft.getItemLinkTooltipAsString = function(itemLink)
    if(not itemLink) then
        return ''
    end

    local lines = {}
    ScootsCraft.frames.tooltip:SetOwner(UIParent)
    ScootsCraft.frames.tooltip:ClearLines()
    ScootsCraft.frames.tooltip:SetHyperlink(itemLink)
    
    for _, line in ipairs({ScootsCraft.frames.tooltip:GetRegions()}) do
        if(line:IsObjectType('FontString')) then
            table.insert(lines, line:GetText())
        end
    end
    
    ScootsCraft.frames.tooltip:Hide()
    
    return table.concat(lines, ' ')
end