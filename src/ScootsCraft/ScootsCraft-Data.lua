ScootsCraft.data = {}

ScootsCraft.data.getProfessionMap = function()
    return {
        {
            ['name'] = 'Alchemy',
            ['skillId'] = 171,
            ['possibleSpellIds'] = {51304, 28596, 11611, 3464, 3101, 2259}
        },
        {
            ['name'] = 'Blacksmithing',
            ['skillId'] = 164,
            ['possibleSpellIds'] = {51300, 29844, 9785, 3538, 3100, 2018}
        },
        {
            ['name'] = 'Enchanting',
            ['skillId'] = 333,
            ['possibleSpellIds'] = {51313, 28029, 13920, 7413, 7412, 7411}
        },
        {
            ['name'] = 'Engineering',
            ['skillId'] = 202,
            ['possibleSpellIds'] = {51306, 30350, 12656, 4038, 4037, 4036}
        },
        {
            ['name'] = 'Inscription',
            ['skillId'] = 773,
            ['possibleSpellIds'] = {45363, 45361, 45360, 45359, 45358, 45357}
        },
        {
            ['name'] = 'Jewelcrafting',
            ['skillId'] = 755,
            ['possibleSpellIds'] = {51311, 28897, 28895, 28894, 25230, 25229}
        },
        {
            ['name'] = 'Leatherworking',
            ['skillId'] = 165,
            ['possibleSpellIds'] = {51302, 32549, 10662, 3811, 3104, 2108}
        },
        {
            ['name'] = 'Smelting',
            ['skillId'] = 186,
            ['possibleSpellIds'] = {2656}
        },
        {
            ['name'] = 'Tailoring',
            ['skillId'] = 197,
            ['possibleSpellIds'] = {51309, 26790, 12180, 3910, 3909, 3908}
        },
        {
            ['name'] = 'Cooking',
            ['skillId'] = 185,
            ['possibleSpellIds'] = {51296, 33359, 18260, 3413, 3102, 2550}
        },
        {
            ['name'] = 'FirstAid',
            ['skillId'] = 129,
            ['possibleSpellIds'] = {45542, 27028, 10846, 7924, 3274, 3273}
        },
    }
end

ScootsCraft.data.getSectionRewrites = function()
    return {
        [ScootsCraft.skillMap.Alchemy] = {
            ['0x4000000'] = 'Refill',
        },
        [ScootsCraft.skillMap.Blacksmithing] = {
            ['0x100'] = 'Modify',
            ['0x200'] = 'Modify',
        },
        [ScootsCraft.skillMap.Enchanting] = {
            ['0x10'] = 'Enchant Chest',
            ['0x100'] = 'Enchant Bracer',
            ['0x1000000'] = 'Enchant Weapon (2H)',
            ['0x200'] = 'Enchant Gloves',
            ['0x2000000'] = 'Enchant Shield',
            ['0x400'] = 'Enchant Ring',
            ['0x4000'] = 'Enchant Cloak',
            ['0x4000000'] = 'Enchanting',
            ['0x80'] = 'Enchant Boots',
            ['0x800000'] = 'Enchant Weapon',
        },
        [ScootsCraft.skillMap.Engineering] = {
            ['0x1'] = 'Tinker',
            ['0x20'] = 'Tinker',
            ['0x200'] = 'Tinker',
            ['0x4000'] = 'Tinker',
            ['0x80'] = 'Tinker',
        },
        [ScootsCraft.skillMap.Inscription] = {
            ['0x4'] = 'Inscribe',
            ['0x4000000'] = 'Inscribe',
        },
        [ScootsCraft.skillMap.Jewelcrafting] = {},
        [ScootsCraft.skillMap.Leatherworking] = {
            ['0x100'] = 'Emboss',
            ['0x40'] = 'Emboss',
        },
        [ScootsCraft.skillMap.Smelting] = {},
        [ScootsCraft.skillMap.Tailoring] = {
            ['0x40'] = 'Embroider',
            ['0x4000'] = 'Embroider',
        },
        [ScootsCraft.skillMap.Cooking] = {},
        [ScootsCraft.skillMap.FirstAid] = {},
    }
end

ScootsCraft.data.getSectionsPushedToTop = function()
    if(ScootsCraft.data.sectionsPushedToTop == nil) then
        local headerRewrites = ScootsCraft.data.getSectionRewrites()
        ScootsCraft.data.sectionsPushedToTop = {}
    
        local categoriesToPush = {
            [ScootsCraft.skillMap.Alchemy] = {
                [(select(7, Custom_GetProfessionRecipeInfo(60893)))] = 1, -- Refill
            },
            [ScootsCraft.skillMap.Blacksmithing] = {
                [(select(7, Custom_GetProfessionRecipeInfo(55628)))] = 1, -- Modify
                [(select(7, Custom_GetProfessionRecipeInfo(62202)))] = 2, -- Item Enhancement
            },
            [ScootsCraft.skillMap.Enchanting] = {},
            [ScootsCraft.skillMap.Engineering] = {
                [(select(7, Custom_GetProfessionRecipeInfo(55016)))] = 1, -- Tinker
            },
            [ScootsCraft.skillMap.Inscription] = {
                [(select(7, Custom_GetProfessionRecipeInfo(61288)))] = 1, -- Inscribe
            },
            [ScootsCraft.skillMap.Jewelcrafting] = {
                [(select(7, Custom_GetProfessionRecipeInfo(62242)))] = 1, -- Consumable
            },
            [ScootsCraft.skillMap.Leatherworking] = {
                [(select(7, Custom_GetProfessionRecipeInfo(57683)))] = 1, -- Emboss
                [(select(7, Custom_GetProfessionRecipeInfo(62448)))] = 2, -- Item Enhancement
            },
            [ScootsCraft.skillMap.Smelting] = {
                [(select(7, Custom_GetProfessionRecipeInfo(35750)))] = 1, -- Elemental
            },
            [ScootsCraft.skillMap.Tailoring] = {
                [(select(7, Custom_GetProfessionRecipeInfo(55769)))] = 1, -- Embroider
                [(select(7, Custom_GetProfessionRecipeInfo(56011)))] = 2, -- Item Enhancement
            },
            [ScootsCraft.skillMap.Cooking] = {},
            [ScootsCraft.skillMap.FirstAid] = {},
        }
        
        for skillId, pushedSections in pairs(categoriesToPush) do
            ScootsCraft.data.sectionsPushedToTop[skillId] = {}
        
            for sectionName, pushLevel in pairs(pushedSections) do
                local pushSectionName = sectionName
            
                if(headerRewrites[skillId][sectionName] ~= nil) then
                    pushSectionName = headerRewrites[skillId][sectionName]
                end
                
                ScootsCraft.data.sectionsPushedToTop[skillId][pushSectionName] = pushLevel
            end
        end
    end
    
    return ScootsCraft.data.sectionsPushedToTop
end

ScootsCraft.data.getSpellSectionRewrites = function()
    return {
        [ScootsCraft.skillMap.Alchemy] = {
            [32765] = 'Gem', -- Transmute: Earthstorm Diamond
            [32766] = 'Gem', -- Transmute: Skyfire Diamond
            [57425] = 'Gem', -- Transmute: Skyflare Diamond
            [57427] = 'Gem', -- Transmute: Earthsiege Diamond
            [66658] = 'Gem', -- Transmute: Ametrine
            [66659] = 'Gem', -- Transmute: Cardinal Ruby
            [66660] = 'Gem', -- Transmute: King's Amber
            [66662] = 'Gem', -- Transmute: Dreadstone
            [66663] = 'Gem', -- Transmute: Majestic Zircon
            [66664] = 'Gem', -- Transmute: Eye of Zul
        },
        [ScootsCraft.skillMap.Blacksmithing] = {},
        [ScootsCraft.skillMap.Enchanting] = {},
        [ScootsCraft.skillMap.Engineering] = {},
        [ScootsCraft.skillMap.Inscription] = {},
        [ScootsCraft.skillMap.Jewelcrafting] = {},
        [ScootsCraft.skillMap.Leatherworking] = {
            [2881] = 'Leather Trade Goods', -- Light Leather
            [20648] = 'Leather Trade Goods', -- Medium Leather
            [20649] = 'Leather Trade Goods', -- Heavy Leather
            [20650] = 'Leather Trade Goods', -- Thick Leather
            [22331] = 'Leather Trade Goods', -- Rugged Leather
            [32454] = 'Leather Trade Goods', -- Knothide Leather
            [32455] = 'Leather Trade Goods', -- Heavy Knothide Leather
            [50936] = 'Leather Trade Goods', -- Heavy Borean Leather
            [64661] = 'Leather Trade Goods', -- Borean Leather
        },
        [ScootsCraft.skillMap.Smelting] = {},
        [ScootsCraft.skillMap.Tailoring] = {
            [2963] = 'Cloth Trade Goods', -- Bolt of Linen Cloth
            [2964] = 'Cloth Trade Goods', -- Bolt of Woolen Cloth
            [3839] = 'Cloth Trade Goods', -- Bolt of Silk Cloth
            [3865] = 'Cloth Trade Goods', -- Bolt of Mageweave
            [18401] = 'Cloth Trade Goods', -- Bolt of Runecloth
            [18560] = 'Cloth Trade Goods', -- Mooncloth
            [26745] = 'Cloth Trade Goods', -- Bolt of Netherweave
            [26747] = 'Cloth Trade Goods', -- Bolt of Imbued Netherweave
            [26750] = 'Cloth Trade Goods', -- Bolt of Soulcloth
            [26751] = 'Cloth Trade Goods', -- Primal Mooncloth
            [31373] = 'Cloth Trade Goods', -- Spellcloth
            [36686] = 'Cloth Trade Goods', -- Shadowcloth
            [55899] = 'Cloth Trade Goods', -- Bolt of Frostweave
            [55900] = 'Cloth Trade Goods', -- Bolt of Imbued Frostweave
            [56001] = 'Cloth Trade Goods', -- Moonshroud
            [56002] = 'Cloth Trade Goods', -- Ebonweave
            [56003] = 'Cloth Trade Goods', -- Spellweave
        },
        [ScootsCraft.skillMap.Cooking] = {},
        [ScootsCraft.skillMap.FirstAid] = {},
    }
end

ScootsCraft.data.getSummaryReductionExclusions = function()
    return {
        [7076] = true,  -- Essence of Earth
        [7078] = true,  -- Essence of Fire
        [7080] = true,  -- Essence of Water
        [7082] = true,  -- Essence of Air
        [12803] = true, -- Living Essence
        [12808] = true, -- Essence of Undeath
        
        [22573] = true, -- Mote of Earth
        [22574] = true, -- Mote of Fire
        [21884] = true, -- Primal Fire
        [21885] = true, -- Primal Water
        [21886] = true, -- Primal Life
        [22451] = true, -- Primal Air
        [22452] = true, -- Primal Earth
        [22457] = true, -- Primal Mana
        [22456] = true, -- Primal Shadow
        
        [35623] = true, -- Eternal Air
        [35624] = true, -- Eternal Earth
        [36860] = true, -- Eternal Fire
        [35625] = true, -- Eternal Life
        [25627] = true, -- Eternal Shadow
        [35622] = true, -- Eternal Water
        
        [2840] = true,  -- Copper Bar
        [2842] = true,  -- Silver Bar
        [3575] = true,  -- Iron Bar
        [3576] = true,  -- Tin Bar
        [3577] = true,  -- Gold Bar
        [3860] = true,  -- Mithril Bar
        [6037] = true,  -- Truesilver Bar
        [11371] = true, -- Dark Iron Bar
        [12359] = true, -- Thorium Bar
        [17771] = true, -- Elementium Bar
        [23445] = true, -- Fel Iron Bar
        [23446] = true, -- Adamantite Bar
        [23447] = true, -- Eternium Bar
        [23449] = true, -- Khorium Bar
        [36913] = true, -- Saronite Bar
        [36916] = true, -- Cobalt Bar
        [41163] = true, -- Titanium Bar
        
        [2318] = true, -- Light Leather
        [2319] = true, -- Medium Leather
        [4234] = true, -- Heavy Leather
        [4304] = true, -- Thick Leather
        [8170] = true, -- Rugged Leather
        [21887] = true, -- Knothide Leather
        [33568] = true, -- Borean Leather
    }
end

ScootsCraft.data.getRecipeReagents = function(spellId)
    local reagents = {}
    local requiredReagents = Custom_GetProfessionRecipeReagents(spellId)
    
    Custom_CacheHaveItems()
    local bagItems = Custom_GetHaveItems()
    local reagentsInBags = {}
    
    for itemId, requiredCount in pairs(requiredReagents) do
        local reagentDetail = {
            ['itemId'] = itemId,
            ['required'] = requiredCount,
            ['owned'] = GetCustomGameData(13, itemId)
        }
    
        for _, cachedBagItemId in pairs(bagItems) do
            if(itemId == cachedBagItemId) then
                for bagIndex = 0, 4 do
                    local bagSlots = GetContainerNumSlots(bagIndex)
                    
                    for slotIndex = 1, bagSlots do
                        local _, bagItemCount, _, _, _, _, bagItemLink = GetContainerItemInfo(bagIndex, slotIndex)
                        
                        if(bagItemLink ~= nil) then
                            local bagItemId = CustomExtractItemId(bagItemLink)
                            
                            if(bagItemId == itemId) then
                                reagentDetail.owned = reagentDetail.owned + bagItemCount
                            end
                        end
                    end
                end
                
                break
            end
        end
        
        table.insert(reagents, reagentDetail)
    end
    
    return reagents
end

ScootsCraft.data.getBagContents = function()
    local bagContents = {}

    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        
        for slotIndex = 1, bagSlots do
            local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bagIndex, slotIndex)
            
            if(itemLink ~= nil) then
                local itemId = CustomExtractItemId(itemLink)
                
                if(bagContents[itemId] == nil) then
                    bagContents[itemId] = itemCount
                else
                    bagContents[itemId] = bagContents[itemId] + itemCount
                end
            end
        end
    end
    
    return bagContents
end

ScootsCraft.data.getItemClasses = function()
    return {
        {
            ['id'] = 0,
            ['name'] = 'Consumable',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Consumable',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Potion',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Elixir',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Flask',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Scroll',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Food & Drink',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Item Enhancement',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Bandage',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Other',
                },
            },
        },
        {
            ['id'] = 1,
            ['name'] = 'Container',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Bag',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Soul Bag',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Herb Bag',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Enchanting Bag',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Engineering Bag',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Gem Bag',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Mining Bag',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Leatherworking Bag',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Inscription Bag',
                },
            },
        },
        {
            ['id'] = 2,
            ['name'] = 'Weapon',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Axe (1H)',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Axe (2H)',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Bow',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Gun',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Mace (1H)',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Mace (2H)',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Polearm',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Sword (1H)',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Sword (2H)',
                },
                {
                    ['id'] = 10,
                    ['name'] = 'Staff',
                },
                {
                    ['id'] = 11,
                    ['name'] = 'Exotic (1H)',
                },
                {
                    ['id'] = 12,
                    ['name'] = 'Exotic (2H)',
                },
                {
                    ['id'] = 13,
                    ['name'] = 'Fist Weapon',
                },
                {
                    ['id'] = 14,
                    ['name'] = 'Miscellaneous',
                },
                {
                    ['id'] = 15,
                    ['name'] = 'Dagger',
                },
                {
                    ['id'] = 16,
                    ['name'] = 'Thrown',
                },
                {
                    ['id'] = 17,
                    ['name'] = 'Spear',
                },
                {
                    ['id'] = 18,
                    ['name'] = 'Crossbow',
                },
                {
                    ['id'] = 19,
                    ['name'] = 'Wand',
                },
                {
                    ['id'] = 20,
                    ['name'] = 'Fishing Pole',
                },
            },
        },
        {
            ['id'] = 3,
            ['name'] = 'Gem',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Red',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Blue',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Yellow',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Purple',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Green',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Orange',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Meta',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Simple',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Prismatic',
                },
            },
        },
        {
            ['id'] = 4,
            ['name'] = 'Armor',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Miscellaneous',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Cloth',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Leather',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Mail',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Plate',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Shield',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Libram',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Idol',
                },
                {
                    ['id'] = 9,
                    ['name'] = 'Totem',
                },
                {
                    ['id'] = 10,
                    ['name'] = 'Sigil',
                },
            },
        },
        {
            ['id'] = 5,
            ['name'] = 'Reagent',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Reagent',
                },
            },
        },
        {
            ['id'] = 6,
            ['name'] = 'Projectile',
            ['subclasses'] = {
                {
                    ['id'] = 2,
                    ['name'] = 'Arrow',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Bullet',
                },
            },
        },
        {
            ['id'] = 7,
            ['name'] = 'Trade Goods',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Trade Goods',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Parts',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Explosives',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Devices',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Jewelcrafting',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Cloth',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Leather',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Metal & Stone',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Meat',
                },
                {
                    ['id'] = 9,
                    ['name'] = 'Herb',
                },
                {
                    ['id'] = 10,
                    ['name'] = 'Elemental',
                },
                {
                    ['id'] = 11,
                    ['name'] = 'Other',
                },
                {
                    ['id'] = 12,
                    ['name'] = 'Enchanting',
                },
                {
                    ['id'] = 13,
                    ['name'] = 'Materials',
                },
                {
                    ['id'] = 14,
                    ['name'] = 'Armor Enchantment',
                },
                {
                    ['id'] = 15,
                    ['name'] = 'Weapon Enchantment',
                },
            },
        },
        {
            ['id'] = 9,
            ['name'] = 'Recipe',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Book',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Leatherworking',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Tailoring',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Engineering',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Blacksmithing',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Cooking',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Alchemy',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'First Aid',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Enchanting',
                },
                {
                    ['id'] = 9,
                    ['name'] = 'Fishing',
                },
                {
                    ['id'] = 10,
                    ['name'] = 'Jewelcrafting',
                },
            },
        },
        {
            ['id'] = 11,
            ['name'] = 'Quiver',
            ['subclasses'] = {
                {
                    ['id'] = 2,
                    ['name'] = 'Quiver',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Ammo Pouch',
                },
            },
        },
        {
            ['id'] = 12,
            ['name'] = 'Quest',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Quest',
                },
            },
        },
        {
            ['id'] = 13,
            ['name'] = 'Key',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Key',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Lockpick',
                },
            },
        },
        {
            ['id'] = 15,
            ['name'] = 'Miscellaneous',
            ['subclasses'] = {
                {
                    ['id'] = 0,
                    ['name'] = 'Junk',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Reagent',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Pet',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Holiday',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Other',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Mount',
                },
            },
        },
        {
            ['id'] = 16,
            ['name'] = 'Glyph',
            ['subclasses'] = {
                {
                    ['id'] = 1,
                    ['name'] = 'Warrior',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Paladin',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Hunter',
                },
                {
                    ['id'] = 4,
                    ['name'] = 'Rogue',
                },
                {
                    ['id'] = 5,
                    ['name'] = 'Priest',
                },
                {
                    ['id'] = 6,
                    ['name'] = 'Death Knight',
                },
                {
                    ['id'] = 7,
                    ['name'] = 'Shaman',
                },
                {
                    ['id'] = 8,
                    ['name'] = 'Mage',
                },
                {
                    ['id'] = 9,
                    ['name'] = 'Warlock',
                },
                {
                    ['id'] = 11,
                    ['name'] = 'Druid',
                },
            },
        },
    }
end

ScootsCraft.data.getItemInvSlots = function()
    return {
        ['INVTYPE_HEAD'] = 1,
        ['INVTYPE_NECK'] = 2,
        ['INVTYPE_SHOULDER'] = 3,
        ['INVTYPE_BODY'] = 4,
        ['INVTYPE_CHEST'] = 5,
        ['INVTYPE_WAIST'] = 6,
        ['INVTYPE_LEGS'] = 7,
        ['INVTYPE_FEET'] = 8,
        ['INVTYPE_WRIST'] = 9,
        ['INVTYPE_HAND'] = 10,
        ['INVTYPE_FINGER'] = 11,
        ['INVTYPE_TRINKET'] = 12,
        ['INVTYPE_WEAPON'] = 13,
        ['INVTYPE_SHIELD'] = 14,
        ['INVTYPE_CLOAK'] = 16,
        ['INVTYPE_2HWEAPON'] = 17,
        ['INVTYPE_BAG'] = 18,
        ['INVTYPE_WEAPONMAINHAND'] = 21,
        ['INVTYPE_HOLDABLE'] = 23,
        ['INVTYPE_AMMO'] = 24,
        ['INVTYPE_THROWN'] = 25,
        ['INVTYPE_RANGEDRIGHT'] = 26,
    }
end