name             'fake'
version          '0.1.0'

depends 'dns'

recipe 'fake::create_zone', 'Creates a DNS zone'
recipe 'fake::first_update', 'Updates a DNS entry'
recipe 'fake::last_update', 'Updates a DNS entry'
