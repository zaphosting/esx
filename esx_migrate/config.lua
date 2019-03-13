Config = {}

-- specifies how many vehicles to migrate at the same time. A high value will cause deadlocks on the database, but will process faster, set to a decent value depending on the hardware
Config.MaxMigrates = 6

-- looks like this: 'LLL NNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters = 3
Config.PlateNumbers = 3
Config.PlateUseSpace = true