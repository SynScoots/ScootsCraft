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
    ['getPossibleSummaryReductionExclusions'] = function()
        if(not lookup.possibleSummaryReductionExclusions) then
            lookup.possibleSummaryReductionExclusions = {
                [core.skillMap.Alchemy] = {
                    118, -- Minor Healing Potion
                    929, -- Healing Potion
                    2457, -- Elixir of Minor Agility
                    2459, -- Swiftness Potion
                    3383, -- Elixir of Wisdom
                    3389, -- Elixir of Defense
                    3390, -- Elixir of Lesser Agility
                    3391, -- Elixir of Ogre's Strength
                    3823, -- Lesser Invisibility Potion
                    3824, -- Shadow Oil
                    3827, -- Mana Potion
                    3829, -- Frost Oil
                    5633, -- Great Rage Potion
                    6048, -- Shadow Protection Potion
                    6149, -- Greater Mana Potion
                    6370, -- Blackmouth Oil
                    6371, -- Fire Oil
                    7068, -- Elemental Fire
                    8949, -- Elixir of Agility
                    8951, -- Elixir of Greater Defense
                    9061, -- Goblin Rocket Fuel
                    9210, -- Ghost Dye
                    9224, -- Elixir of Demonslaying
                    10592, -- Catseye Elixir
                    12360, -- Arcanite Bar
                    13423, -- Stonescale Oil
                    13444, -- Major Mana Potion
                    13446, -- Major Healing Potion
                    13510, -- Flask of the Titans
                    13512, -- Flask of Supreme Power
                    22824, -- Elixir of Major Strength
                    22829, -- Super Healing Potion
                    22831, -- Elixir of Major Agility
                    22832, -- Super Mana Potion
                    23571, -- Primal Might
                    25867, -- Earthstorm Diamond
                    25868, -- Skyfire Diamond
                    33447, -- Runic Healing Potion
                    33448, -- Runic Mana Potion
                    36919, -- Cardinal Ruby
                    36922, -- King's Amber
                    36925, -- Majestic Zircon
                    36928, -- Dreadstone
                    36931, -- Ametrine
                    36934, -- Eye of Zul
                    40195, -- Pygmy Oil
                    41266, -- Skyflare Diamond
                    41334, -- Earthsiege Diamond
                    44958, -- Ethereal Oil
                },
                [core.skillMap.Blacksmithing] = {
                    3470, -- Rough Grinding Stone
                    3478, -- Coarse Grinding Stone
                    3486, -- Heavy Grinding Stone
                    6338, -- Silver Rod
                    7071, -- Iron Buckle
                    7966, -- Solid Grinding Stone
                    9060, -- Inlaid Mithril Cylinder
                    11128, -- Golden Rod
                    11144, -- Truesilver Rod
                    12644, -- Dense Grinding Stone
                    16206, -- Arcanite Rod
                    25843, -- Fel Iron Rod
                    25844, -- Adamantite Rod
                    25845, -- Eternium Rod
                    41745, -- Titanium Rod
                },
                [core.skillMap.Enchanting] = {
                    12655, -- Enchanted Thorium Bar
                    12810, -- Enchanted Leather
                },
                [core.skillMap.Engineering] = {
                    4357, -- Rough Blasting Powder
                    4359, -- Handful of Copper Bolts
                    4361, -- Copper Tube
                    4363, -- Copper Modulator
                    4364, -- Coarse Blasting Powder
                    4371, -- Bronze Tube
                    4375, -- Whirring Bronze Gizmo
                    4377, -- Heavy Blasting Powder
                    4382, -- Bronze Framework
                    4387, -- Iron Strut
                    4389, -- Gyrochronatom
                    4394, -- Big Iron Bomb
                    4404, -- Silver Contact
                    4407, -- Accurate Scope
                    7191, -- Fused Wiring
                    10505, -- Solid Blasting Powder
                    10507, -- Solid Dynamite
                    10546, -- Deadly Scope
                    10558, -- Gold Power Core
                    10559, -- Mithril Tube
                    10560, -- Unstable Trigger
                    10561, -- Mithril Casing
                    10576, -- Mithril Mechanical Dragonling
                    10577, -- Goblin Mortar
                    15992, -- Dense Blasting Powder
                    15994, -- Thorium Widget
                    16000, -- Thorium Tube
                    16006, -- Delicate Arcanite Converter
                    18232, -- Field Repair Bot 74A
                    18631, -- Truesilver Transformer
                    23781, -- Elemental Blasting Powder
                    23782, -- Fel Iron Casing
                    23783, -- Handful of Fel Iron Bolts
                    23784, -- Adamantite Frame
                    23785, -- Hardened Adamantite Tube
                    23786, -- Khorium Power Core
                    23787, -- Felsteel Stabilizer
                    32423, -- Icy Blasting Primers
                    34113, -- Field Repair Bot 110G
                    39681, -- Handful of Cobalt Bolts
                    39682, -- Overcharged Capacitor
                    39683, -- Froststeel Tube
                    39690, -- Volatile Blasting Trigger
                    40769, -- Scrapbot Construction Kit
                    41146, -- Sun Scope
                },
                [core.skillMap.Inscription] = {
                    27503, -- Scroll of Strength V
                    37101, -- Ivory Ink
                    39469, -- Moonglow Ink
                    39774, -- Midnight Ink
                    43115, -- Hunter's Ink
                    43116, -- Lion's Ink
                    43117, -- Dawnstar Ink
                    43118, -- Jadefire Ink
                    43119, -- Royal Ink
                    43120, -- Celestial Ink
                    43121, -- Fiery Ink
                    43122, -- Shimmering Ink
                    43123, -- Ink of the Sky
                    43124, -- Ethereal Ink
                    43125, -- Darkflame Ink
                    43126, -- Ink of the Sea
                    43127, -- Snowfall Ink
                },
                [core.skillMap.Jewelcrafting] = {
                    20816, -- Delicate Copper Wire
                    20817, -- Bronze Setting
                    20963, -- Mithril Filigree
                    21752, -- Thorium Setting
                    31079, -- Mercurial Adamantite
                },
                [core.skillMap.Leatherworking] = {
                    2318, -- Light Leather
                    2319, -- Medium Leather
                    4231, -- Cured Light Hide
                    4233, -- Cured Medium Hide
                    4234, -- Heavy Leather
                    4236, -- Cured Heavy Hide
                    4304, -- Thick Leather
                    8170, -- Rugged Leather
                    8172, -- Cured Thick Hide
                    15407, -- Cured Rugged Hide
                    21887, -- Knothide Leather
                    23793, -- Heavy Knothide Leather
                    33568, -- Borean Leather
                    38425, -- Heavy Borean Leather
                },
                [core.skillMap.Smelting] = {
                    2840, -- Copper Bar
                    2841, -- Bronze Bar
                    2842, -- Silver Bar
                    3575, -- Iron Bar
                    3576, -- Tin Bar
                    3577, -- Gold Bar
                    3859, -- Steel Bar
                    3860, -- Mithril Bar
                    6037, -- Truesilver Bar
                    11371, -- Dark Iron Bar
                    12359, -- Thorium Bar
                    23445, -- Fel Iron Bar
                    23446, -- Adamantite Bar
                    23447, -- Eternium Bar
                    23448, -- Felsteel Bar
                    23449, -- Khorium Bar
                    23573, -- Hardened Adamantite Bar
                    35128, -- Hardened Khorium
                    36913, -- Saronite Bar
                    36916, -- Cobalt Bar
                    37663, -- Titansteel Bar
                    41163, -- Titanium Bar
                },
                [core.skillMap.Tailoring] = {
                    2996, -- Bolt of Linen Cloth
                    2997, -- Bolt of Woolen Cloth
                    4305, -- Bolt of Silk Cloth
                    4339, -- Bolt of Mageweave
                    14048, -- Bolt of Runecloth
                    14342, -- Mooncloth
                    21840, -- Bolt of Netherweave
                    21842, -- Bolt of Imbued Netherweave
                    21844, -- Bolt of Soulcloth
                    21845, -- Primal Mooncloth
                    24271, -- Spellcloth
                    24272, -- Shadowcloth
                    41510, -- Bolt of Frostweave
                    41511, -- Bolt of Imbued Frostweave
                    41593, -- Ebonweave
                    41594, -- Moonshroud
                    41595, -- Spellweave
                },
            }
            
            for skillId, _ in pairs(lookup.possibleSummaryReductionExclusions) do
                table.sort(lookup.possibleSummaryReductionExclusions[skillId], function(itemIdA, itemIdB)
                    return (GetItemInfoCustom(itemIdA)) < (GetItemInfoCustom(itemIdB))
                end)
            end
        end
        
        return lookup.possibleSummaryReductionExclusions
    end,
    ['summaryReductionExclusions'] = {
        -- These can't be options to prevent infinite loop
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
    ['filterKeys'] = {
        'search',
        'search-include-reagents',
        'search-include-tooltip',
        'minimum-quantity',
        'exclude-items-in-bags',
        'attuneable',
        'attuned-level',
        'section',
        'inv-slot',
    },
    ['masteries'] = {
        [28672] = { -- Transmutation Master
            11479, -- Transmute: Iron to Gold
            11480, -- Transmute: Mithril to Truesilver
            17187, -- Transmute: Arcanite
            17559, -- Transmute: Air to Fire
            17560, -- Transmute: Fire to Earth
            17561, -- Transmute: Earth to Water
            17562, -- Transmute: Water to Air
            17563, -- Transmute: Undeath to Water
            17564, -- Transmute: Water to Undeath
            17565, -- Transmute: Life to Earth
            17566, -- Transmute: Earth to Life
            25146, -- Transmute: Elemental Fire
            28566, -- Transmute: Primal Air to Fire
            28567, -- Transmute: Primal Earth to Water
            28568, -- Transmute: Primal Fire to Earth
            28569, -- Transmute: Primal Water to Air
            28580, -- Transmute: Primal Shadow to Water
            28581, -- Transmute: Primal Water to Shadow
            28582, -- Transmute: Primal Mana to Fire
            28583, -- Transmute: Primal Fire to Mana
            28584, -- Transmute: Primal Life to Earth
            28585, -- Transmute: Primal Earth to Life
            28664, -- Transmute - Primal Shadow to Water
            28665, -- Transmute - Primal Water to Shadow
            28666, -- Transmute - Primal Mana to Fire
            28667, -- Transmute - Primal Fire to Mana
            28668, -- Transmute - Primal Life to Earth
            28669, -- Transmute - Primal Earth to Life
            29688, -- Transmute: Primal Might
            32765, -- Transmute: Earthstorm Diamond
            32766, -- Transmute: Skyfire Diamond
            53771, -- Transmute: Eternal Life to Shadow
            53773, -- Transmute: Eternal Life to Fire
            53774, -- Transmute: Eternal Fire to Water
            53775, -- Transmute: Eternal Fire to Life
            53776, -- Transmute: Eternal Air to Water
            53777, -- Transmute: Eternal Air to Earth
            53779, -- Transmute: Eternal Shadow to Earth
            53780, -- Transmute: Eternal Shadow to Life
            53781, -- Transmute: Eternal Earth to Air
            53782, -- Transmute: Eternal Earth to Shadow
            53783, -- Transmute: Eternal Water to Air
            53784, -- Transmute: Eternal Water to Fire
            54020, -- Transmute: Eternal Might
            57425, -- Transmute: Skyflare Diamond
            57427, -- Transmute: Earthsiege Diamond
            60350, -- Transmute: Titanium
            66658, -- Transmute: Ametrine
            66659, -- Transmute: Cardinal Ruby
            66660, -- Transmute: King's Amber
            66662, -- Transmute: Dreadstone
            66663, -- Transmute: Majestic Zircon
            66664, -- Transmute: Eye of Zul
            66887, -- Transmute: Cardinal Ruby
            66888, -- Transmute: Majestic Zircon
            66890, -- Transmute: Dreadstone
            66891, -- Transmute: Ametrine
            66892, -- Transmute: King's Amber
        },
    },
    ['doubleMasteries'] = {
        [26797] = { -- Spellfire Tailoring
            31373, -- Spellcloth
            56003, -- Spellweave
        },
        [26798] = { -- Mooncloth Tailoring
            18560, -- Mooncloth
            26751, -- Primal Mooncloth
            56001, -- Moonshroud
        },
        [26801] = { -- Shadoweave Tailoring
            36686, -- Shadowcloth
            56002, -- Ebonweave
        },
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

lookup.masteryMap = {}
for masterySpellId, craftSpellIdList in pairs(lookup.masteries) do
    for _, craftSpellId in ipairs(craftSpellIdList) do
        lookup.masteryMap[craftSpellId] = masterySpellId
    end
end

lookup.doubleMasteryMap = {}
for masterySpellId, craftSpellIdList in pairs(lookup.doubleMasteries) do
    for _, craftSpellId in ipairs(craftSpellIdList) do
        lookup.masteryMap[craftSpellId] = masterySpellId
        lookup.doubleMasteryMap[craftSpellId] = masterySpellId
    end
end

for funcName, func in pairs(lookup) do
    ScootsCraft.lookup[funcName] = func
end

lookup = ScootsCraft.lookup