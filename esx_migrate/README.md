# esx_migrate
This script migrates the 'old' `owned_vehicles` database to an improved system. Very basic script and does the job.

When starting this migrate, make sure you have manually added the database column `plate`, the database should look exactly like this:

```sql
CREATE TABLE `owned_vehicles` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`owner` VARCHAR(30) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`vehicle` LONGTEXT NULL COLLATE 'utf8mb4_bin',
	`plate` VARCHAR(8) NOT NULL COLLATE 'utf8mb4_bin',

	PRIMARY KEY (`id`)
);
```

After migrating the database you can safly remove the `id` column and set the primary key to `plate`

### What's so good with this anyways?
Currently with all official esx scripts getting a registered vehicle and its owner is not optimized at all.
Let's compare two functions from.... esx_vehicleshop:

#### Before
```lua
function RemoveOwnedVehicle (plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function (result)
		for i=1, #result, 1 do
			local vehicleProps = json.decode(result[i].vehicle)

			if vehicleProps.plate == plate then
				MySQL.Async.execute('DELETE FROM owned_vehicles WHERE id = @id',
				{
					['@id'] = result[i].id
				})
			end
		end
	end)
end
```

#### After
```lua
function RemoveOwnedVehicle (plate)
	MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate',
	{
		['@plate'] = plate
	})
end
```

Since this script replaces vehicle plates you can also configure the template for them over at `config.lua`, remember that scripts using the database `owned_vehicles` will have to be updated aswell in order to take advantage of the db change.

# Legal
### License
esx_migrate - migrate tool for ESX

Copyright (C) 2015-2018 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
