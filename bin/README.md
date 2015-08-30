#RailsLite (+ ActiveRecord Lite)

RailsLite is a lightweight version of Ruby-on-Rails built from scratch, featuring
some of the basic functionality from Rails.

It also implements ActiveRecordLite a lightweight version of ActiveRecord including
fully featured associations.

The goal of this project was to gain a thorough understanding of Ruby-onRails,
ActiveRecord, and backend frameworks in general.

##Features

###RailsLite
- HTTPSServer via WEBrick ruby server module
- Replicates ActionController::Base with ControllerBase class, including
  render and redirect methods
- Reads, evaluates, and renders ERB templates
- Stores serialized session data in WEBrick cookie
- Evaluates and stores params through URL, request body, and query string
- Includes a router that tracks multiple routes, and matches them to their
  respective controller methods for execution.

###ActiveRecordLite
- Automated table naming based on ActiveRecord conventions
- Getter and setter methods for table columns
- Table modification methods: #add, #insert, #save, #update
- Table Lookup methods: #all, #find, ::where
- Fully featured associations: belongs_to, has_many, has_one_through,
  has_many_through
