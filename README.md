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


###The VIN String
The VIN is a 9-digit string that encodes the year, the make model,
the engine and some other information we don't care about. Truck Pricer
will decode the VIN to look up the correct price for that engine, model
and year in the database.

The VIN string is decoded as follows:

1. The year is the 10th digit
2. The model is the 5th digit
3. The engine is the 7th digit


##Confusion About Price Form Submission
Due to a lack of smart in my brain I have done the price creation form
submission through AJAX. As such, it is not enough to just update the
form and the server-side code to handle it. You also have to tweak the
stuff in scripts.js when you add or change fields. Yup, that was not a
smart thing to to. Live and learn.
