-- From "Sewers" mod -- Author = carlesturo

local procedural_sewers = {
	sewer_warehouse_police_muldraugh = { width=34, height=39, stairx=18, stairy=38, stairDir="" },
	sewer_perrine_st_warehouse_muldraugh = { width=30, height=100, stairx=25, stairy=39, stairDir="" },
	sewer_bar_rusty_rifle_muldraugh = { width=30, height=62, stairx=26, stairy=47, stairDir="" },
}

local procedural_sewer_spawn_locations = {
	{x=10695, y=10468, stairDir="", choices={"sewer_warehouse_police_muldraugh"}},
	{x=10736, y=10457, stairDir="", choices={"sewer_perrine_st_warehouse_muldraugh"}},
    {x=10763, y=10565, stairDir="", choices={"sewer_bar_rusty_rifle_muldraugh"}},
	--{x=99999, y=99999, z=-1, stairDir="", access="name", choices={"sewer_name"}},
}


local function addSewers()
	local api = Basements.getAPIv1()
	-- api:addAccessDefinitions('Muldraugh, KY', procedural_sewer_access)
	api:addBasementDefinitions('Muldraugh, KY', procedural_sewers)
	api:addSpawnLocations('Muldraugh, KY', procedural_sewer_spawn_locations)
end

Events.OnLoadMapZones.Add(addSewers)