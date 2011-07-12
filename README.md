##Some gotchas in the code

The Price model has fields for pricer_per_mile and price_per_mile_after_cutoff. Due
to concerns with the legacy database and data migration, the field names don't 
match up too well with what they actually represent.

If the mileage on the truck is below the mileage\_cutoff,
price\_per\_mile is the amount per mile below the mileage\_cutoff that will be
_added_ to the base price of the truck. If the mileage on the truck is above
the mileage\_cutoff, price\_per\_mile\_after\_cutoff is the amount that will be
_deducted_ from the base price of the truck.

###How to Run It Locally
1. Run `bundle install`
2. Start the development server with `rackup`

The Rakefile has tasks to create the database and fill it with some
default data. See it for more information.
