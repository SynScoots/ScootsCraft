local core = ScootsCraft.core
local storage = ScootsCraft.storage
local options = ScootsCraft.options
local frames = ScootsCraft.frames
local interface = ScootsCraft.interface
local utility = ScootsCraft.utility
local lookup

lookup = {
    ['professionMap'] = {
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
    },
    ['summaryReductionExclusions'] = {
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
    },
    ['itemInvSlots'] = {
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
    },
    ['getSectionRewrites'] = function()
        if(lookup.sectionRewrites == nil) then
            lookup.sectionRewrites = {
                [core.skillMap.Alchemy] = {
                    ['0x4000000'] = 'Refill',
                },
                [core.skillMap.Blacksmithing] = {
                    ['0x100'] = 'Modify',
                    ['0x200'] = 'Modify',
                },
                [core.skillMap.Enchanting] = {
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
                [core.skillMap.Engineering] = {
                    ['0x1'] = 'Tinker',
                    ['0x20'] = 'Tinker',
                    ['0x200'] = 'Tinker',
                    ['0x4000'] = 'Tinker',
                    ['0x80'] = 'Tinker',
                },
                [core.skillMap.Inscription] = {
                    ['0x4'] = 'Inscribe',
                    ['0x4000000'] = 'Inscribe',
                },
                [core.skillMap.Jewelcrafting] = {},
                [core.skillMap.Leatherworking] = {
                    ['0x100'] = 'Emboss',
                    ['0x40'] = 'Emboss',
                },
                [core.skillMap.Smelting] = {},
                [core.skillMap.Tailoring] = {
                    ['0x40'] = 'Embroider',
                    ['0x4000'] = 'Embroider',
                },
                [core.skillMap.Cooking] = {},
                [core.skillMap.FirstAid] = {},
            }
        end
        
        return lookup.sectionRewrites
    end,
    ['getSectionsPushedToTop'] = function()
        if(lookup.sectionsPushedToTop == nil) then
            local headerRewrites = lookup.getSectionRewrites()
            lookup.sectionsPushedToTop = {}
        
            local categoriesToPush = {
                [core.skillMap.Alchemy] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(60893)))] = 1, -- Refill
                },
                [core.skillMap.Blacksmithing] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(55628)))] = 1, -- Modify
                    [(select(7, Custom_GetProfessionRecipeInfo(62202)))] = 2, -- Item Enhancement
                },
                [core.skillMap.Enchanting] = {},
                [core.skillMap.Engineering] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(55016)))] = 1, -- Tinker
                },
                [core.skillMap.Inscription] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(61288)))] = 1, -- Inscribe
                },
                [core.skillMap.Jewelcrafting] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(62242)))] = 1, -- Consumable
                },
                [core.skillMap.Leatherworking] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(57683)))] = 1, -- Emboss
                    [(select(7, Custom_GetProfessionRecipeInfo(62448)))] = 2, -- Item Enhancement
                },
                [core.skillMap.Smelting] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(35750)))] = 1, -- Elemental
                },
                [core.skillMap.Tailoring] = {
                    [(select(7, Custom_GetProfessionRecipeInfo(55769)))] = 1, -- Embroider
                    [(select(7, Custom_GetProfessionRecipeInfo(56011)))] = 2, -- Item Enhancement
                },
                [core.skillMap.Cooking] = {},
                [core.skillMap.FirstAid] = {},
            }
            
            for skillId, pushedSections in pairs(categoriesToPush) do
                lookup.sectionsPushedToTop[skillId] = {}
            
                for sectionName, pushLevel in pairs(pushedSections) do
                    local pushSectionName = sectionName
                
                    if(headerRewrites[skillId][sectionName] ~= nil) then
                        pushSectionName = headerRewrites[skillId][sectionName]
                    end
                    
                    lookup.sectionsPushedToTop[skillId][pushSectionName] = pushLevel
                end
            end
        end
        
        return lookup.sectionsPushedToTop
    end,
    ['getSpellSectionRewrites'] = function()
        if(lookup.spellSectionRewrites == nil) then
            lookup.spellSectionRewrites = {
                [core.skillMap.Alchemy] = {
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
                [core.skillMap.Blacksmithing] = {},
                [core.skillMap.Enchanting] = {},
                [core.skillMap.Engineering] = {},
                [core.skillMap.Inscription] = {},
                [core.skillMap.Jewelcrafting] = {},
                [core.skillMap.Leatherworking] = {
                    [2881] = 'Leather Trade Goods', -- Light Leather
                    [3816] = 'Leather Trade Goods', -- Cured Light Hide
                    [3817] = 'Leather Trade Goods', -- Cured Medium Hide
                    [3818] = 'Leather Trade Goods', -- Cured Heavy Hide
                    [10482] = 'Leather Trade Goods', -- Cured Thick Hide
                    [19047] = 'Leather Trade Goods', -- Cured Rugged Hide
                    [20648] = 'Leather Trade Goods', -- Medium Leather
                    [20649] = 'Leather Trade Goods', -- Heavy Leather
                    [20650] = 'Leather Trade Goods', -- Thick Leather
                    [22331] = 'Leather Trade Goods', -- Rugged Leather
                    [32454] = 'Leather Trade Goods', -- Knothide Leather
                    [32455] = 'Leather Trade Goods', -- Heavy Knothide Leather
                    [50936] = 'Leather Trade Goods', -- Heavy Borean Leather
                    [64661] = 'Leather Trade Goods', -- Borean Leather
                },
                [core.skillMap.Smelting] = {},
                [core.skillMap.Tailoring] = {
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
                [core.skillMap.Cooking] = {},
                [core.skillMap.FirstAid] = {},
            }
        end
        
        return lookup.spellSectionRewrites
    end,
}

for funcName, func in pairs(lookup) do
    ScootsCraft.lookup[funcName] = func
end

lookup = ScootsCraft.lookup