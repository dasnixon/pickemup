module PreferenceConstants
  extend ActiveSupport::Concern

  LOCATIONS               = ['San Francisco, CA', 'Portland, OR', 'Seattle, WA',
                             'New York City, NY', 'Chicago, IL', 'Boston, MA',
                             'Austin, TX', 'Los Angeles, CA', 'Cincinnati, OH']

  INDUSTRIES              = ['Medical', 'Mobile', 'Education', 'Entertainment', 'Advertising', 'Scientific', 'Consumer Technology',
                             'Security', 'Transportation', 'Banking', 'Real Estate', 'Legal', 'Industrial', 'Gaming', 'Food',
                             'Fitness', 'Sports', 'Architecture', 'Agriculture', 'Art', 'Hardware', 'Non-profit']

  EXPERIENCE_LEVELS       = ['N/A', 'Intern', 'Co-op', 'Junior', 'Mid-level', 'Senior-level', 'Executive']

  POSITION_TITLES         = ['Software Engineer', 'DevOps Engineer', 'QA Engineer', 'Manager', 'Architect',
                             'Senior Director of Engineering', 'VP of Engineering', 'SVP of Engineering', 'CEO']

  COMPANY_TYPES           = ['Angel Invested', 'Crowdfunded', 'Bootstrapped', 'VC Backed', 'Small Business', 'Publicly-Owned Business']

  PERKS                   = ['Kegs', 'Ping-pong table', 'Snacks', 'Catered Meals', 'Offsites', 'Flexible Work Hours', 'Conference Travel',
                             'Work from Home', 'Lunch Stipend', 'Phone Stipend', 'Public Transit Stipend', 'Tuition Reimbursement', 'Choice of Equipment',
                             'Swag', 'Gym Membership Stipend']

  PRACTICES               = ['Test-driven Development', 'Agile Development', 'Pair Programming', 'Behavior-driven Development', 'Scrum',
                             'Cowboy Coding', 'Object Oriented Design', 'Waterfall Model', 'Service-oriented Design', 'Don\'t Repeat Yourself (DRY)',
                             'Extreme Programming', 'Continuous Integration']

  REMOTE                  = ["No", "Yes", "I'm open to remote work"]

  COMPANY_SIZE            = ["1-10 Employees", "11-50 Employees", "51-200 Employees", "201-500 Employees", "501+ Employees"]

  SPECIAL_CHARACTERISTICS = ['Entrepreneur', 'Blogger', 'Open Source Committer']

  ACCEPTABLE_LANGUAGES    = ['Ruby', 'Python', 'Javascript', 'Java', 'PHP', 'Scala', 'C', 'C++', 'C#', 'Objective C', 'Clojure']

  DEV_OPS_TOOLS           = ['Chef', 'Puppet', 'Capistrano', 'Fai', 'Kickstart', 'Preseed', 'Cobbler',
                             'Cfengine', 'bcfg2', 'Jenkins', 'Maven', 'Ant', 'Cruisecontrol', 'Hudson']

  BACK_END_LANGUAGES      = ['Ruby', 'Python', 'Javascript', 'Java', 'PHP', 'Scala',
                             'C', 'C++', 'C#', 'Objective C', 'Clojure', 'Perl',
                             'Lisp', '(Visual) Basic', 'Pascal', 'Lua', 'Go', 'D',
                             'F#', 'Ada', 'Fortran', 'Scala', 'R', 'COBOL', 'Haskell',
                             'Erlang', 'RPG', 'Groovy', 'Smalltalk', 'Visual Basic .NET',
                             'MATLAB', 'Assembly']

  FRONT_END_LANGUAGES     = ['Javascript', 'HTML', 'CSS', 'HAML', 'SASS']

  FRAMEWORKS              = ['AngularJS', 'BackboneJS', 'Rails', 'Django', 'Tornado',
                             'KnockoutJS', 'Express', 'Thrift', 'Sinatra', 'Grails',
                             'Zotonic', 'Flask', 'web2py', 'TACTIC', 'CakePHP', 'Yii',
                             'Zend Framework', 'AiryMVC Framework', 'Kajona', 'Symfony',
                             'FuelPHP', 'Drupal', 'Cyclone 3', 'Dancer', 'Catalyst',
                             'Play!', 'Lift', 'node.js', 'Meteor', 'JavaServer Faces',
                             'Java Persistence API', 'Enterprise JavaBeans', 'JSP & Servlets',
                             'Oracle ADF']

  RELATIONAL_DATABASES    = ['PostgreSQL', 'MySQL', 'Oracle', 'SQLite', 'MS SQL Server',
                             'Vertica', 'MariaDB', 'Microsoft Access', 'Amazon RDS',
                             'ADABAS', 'DB2', 'Apache Derby', 'Clustrix', 'HSQLDB',
                             'Firebird', 'H2', 'Polyhedra DBMS']

  NOSQL_DATABASES         = ['Cassandra', 'Lucene', 'Riak', 'CouchDB', 'Neo4J', 'Oracle NoSQL',
                             'MongoDB', 'Hadoop', 'BigTable', 'DynamoDB', 'Redis', 'RAVENDB',
                             'MemcacheDB', 'Perst', 'HyperGraphDB', 'Voldemort', 'Terrastore',
                             'NeoDatis', 'MyOODB', 'OrientDB', 'InfoGrid', 'Db4objects',
                             'SimpleDB', 'FoundationDB', 'FatDB', 'Hypertable', 'MarkLogic',
                             'Hibari', 'Tokyo Cabinet', 'Apache Jackrabbit', 'EJDB', 'ArangoDB',
                             'Aerospike']
end
