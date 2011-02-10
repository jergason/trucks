##Some gotchas in the code

The Price model has fields for pricer_per_mile and price_per_mile_after_cutoff. Due
to concerns with the legacy database and data migration, the field names don't 
match up too well with what they actually represent.

If the mileage on the truck is below the mileage_cutoff,
price_per_mile is the amount per mile below the mileage_cutoff that will be
_added_ to the base price of the truck. If the mileage on the truck is above
the mileage_cutoff, price_per_mile_after_cutoff is the amount that will be
deducted from the base price of the truck.
