# PerlMailingList
This is a simple service which receives a post request with an email address,
validates the address, saves it into a database and then redirects the user to
a predefined page

## Mailgun
You need to store the mailgun configuration in the following environment
variables:
- MAILGUN_DOMAIN
- MAILGUN_API_KEY
- MAILGUN_FILES - comma separated list of files with the absolute path to them
