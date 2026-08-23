ScootsCraft = {
    ['title'] = 'ScootsCraft',
    ['version'] = '2.0.0',
    ['frames'] = {
        ['events'] = CreateFrame('Frame', 'ScootsCraft-EventsFrame', UIParent),
    },
    ['storage'] = {},
    ['core'] = {
        ['triggeredEvents'] = {},
    },
    ['options'] = {},
    ['interface'] = {},
    ['utility'] = {},
    ['lookup'] = {},
}

SLASH_SCOOTSCRAFT1 = '/scootscraft'
SlashCmdList['SCOOTSCRAFT'] = function(...)
    ScootsCraft.interface.toggle()
end

-- TODO:
--  Forgehelper post-forge destroy/vendor unforged fix
--  Options to add [Ebonweave/Moonshroud/Spellweave] / [Shadowcloth/Primal Mooncloth/Spellcloth] / [Primal Might] to summary reduction exclusions
--  Option to auto-select next recipe if current recipe gets hidden
--  Shuffle filter ordering to be consistent
--  Steal reset button from Vendor
--  Apply options resizing/texturing to frontend filters
--  Make reset filters work with options