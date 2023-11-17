#===============================================================================
#
#   Sample external MethodScript include. To use these functions, uncomment them.
#
#===============================================================================

proc _teleportPlayer(@user) {
	set_entity_loc(@user, array(-66, 90, 39))
}

proc _slowMove(@entities, @locarray) {
	// for(@i = 0, @i < 11, @i++) {
	// 	msg(@locarray)
	// 	@oldloc = array_get(@loc, 0)
	// 	msg(@oldloc)
	// 	@oldloc = @oldloc + 0.1
	// 	msg(@oldloc)
	// 	array_set(@loc, 0, @oldloc)
	// 	msg(@loc)
	// 	set_entity_loc(@entities[2], array(array_get(@loc, 0), array_get(@loc, 1), array_get(@loc, 2), array_get(@loc, 3), array_get(@loc, 4), array_get(@loc, 5)))
	// 	msg('a')
	// }

	@loc = @locarray[2]
	@loc1 = @locarray[1]
	@loc2 = @locarray[0]

	@moving = _isMoving(@entities[2]);

	int @n = 10;

	int @delay = 10; // The delay between runs, in MS

	if(@moving) {
		return false;
	}

	set_metadata(@entities[2], 'moving', true)
	@selected = _isSelected(@entities[2]);
    
   	double @counterName = rand(); // Prevents overlapping counter names
    
    export('counter' . @counterName, @n);
    set_interval(@delay, closure(){
        @n = import('counter' . @counterName);
		@oldlocs = array()
		if(@selected) {
			array_push(@oldlocs, array_get(@loc, 0) - 0.1)
			array_push(@oldlocs, array_get(@loc1, 0) - 0.1)
			array_push(@oldlocs, array_get(@loc2, 0) - 0.1)
		} else {
			array_push(@oldlocs, array_get(@loc, 0) + 0.1)
			array_push(@oldlocs, array_get(@loc1, 0) + 0.1)
			array_push(@oldlocs, array_get(@loc2, 0) + 0.1)
		}
		array_set(@loc, 0, @oldlocs[0])
		array_set(@loc1, 0, @oldlocs[1])
		array_set(@loc2, 0, @oldlocs[2])
		set_entity_loc(@entities[2], array(array_get(@loc, 0), array_get(@loc, 1), array_get(@loc, 2), array_get(@loc, 3), array_get(@loc, 4), array_get(@loc, 5)))
		set_entity_loc(@entities[1], array(array_get(@loc1, 0), array_get(@loc1, 1), array_get(@loc1, 2), array_get(@loc1, 3), array_get(@loc1, 4), array_get(@loc1, 5)))
		set_entity_loc(@entities[0], array(array_get(@loc2, 0), array_get(@loc2, 1), array_get(@loc2, 2), array_get(@loc2, 3), array_get(@loc2, 4), array_get(@loc2, 5)))

        dec(@n);
        if(@n <= 0){
            clear_task();
			remove_metadata(@entities[2], 'moving')
        }
        export('counter' . @counterName, @n);
    });
}

boolean proc _isSelected(@entity) {
	if(!has_metadata(@entity, 'selected')) {
		set_metadata(@entity, 'selected', true)
		return true;
	} else {
		remove_metadata(@entity, 'selected')
		return false;
	}
}

boolean proc _isMoving(@entity) {
	if(has_metadata(@entity, 'moving')) {
		return true;
	} else {
		return false;
	}
	// if(!has_metadata(@entities[2], 'moving')) {
	// 	msg(get_metadata(@entities[2], 'moving'))
	// 	return true;
	// } else {
	// 	remove_metadata(@entities[2], 'moving')
	// 	msg(get_metadata(@entities[2], 'moving'))
	// 	return false;
	// }
}

/**
 * Returns the distance between two blocks, or any other 3d points, for that matter.
 * @param array @arr1 The first point, expects an array of x, y, z
 * @param array @arr2 The second point, expects an array of x, y, z
 */
/*proc _3d_distance(array @arr1, array @arr2){
	return(
		floor(
			sqrt(
				  ((@arr2[0] - @arr1[0]) ** 2)
				+ ((@arr2[1] - @arr1[1]) ** 2)
				+ ((@arr2[2] - @arr1[2]) ** 2)
			)
		)
	);
}*/

/**
 * Given two blocks, iterates through all the blocks inside the cuboid, and calls the 
 * user defined closure on them. The used defined closure should accept 3 parameters,
 * the x, y, and z coordinates of the block.
 */
/*proc _iterate_cuboid(array @b1, array @b2, closure @callback){
	for(@x = min(@b1[0], @b2[0]), @x <= max(@b1[0], @b2[0]), @x++){
		for(@y = min(@b1[1], @b2[1]), @y <= max(@b1[1], @b2[1]), @y++){
			for(@z = min(@b1[2], @b2[2]), @z <= max(@b1[2], @b2[2]), @z++){
				execute(@x, @y, @z, @callback);
			}
		}
	}
}*/
