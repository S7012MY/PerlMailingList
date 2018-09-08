use Email::Valid;
use Mojo::Pg;
use Mojolicious::Lite;
use Time::Stamp 'gmstamp';

my $pg = Mojo::Pg->new('postgresql:///mailing_list');

post '/add-email' => sub {
  my $c = shift;
  my $email = $c->param('email');
  use v5.24;
  say $email;
  if (!Email::Valid->address(-address => $email, -mxcheck => 1)) {
    $c->render(text => "Email address is invalid");
    return;
  }
  $pg->db->insert('emails', {email => $email, date_submitted => gmstamp(time)});
  $c->render(text => "Successfully registered");
  my $domain = $ENV{MAILGUN_DOMAIN};
  my $api_key = $ENV{MAILGUN_API_KEY};
  my $command = "curl -s --user 'api:$api_key' " .
    "https://api.mailgun.net/v3/$domain/messages " .
    "-F from='Excited User <mailgun\@$domain>' " .
    "-F to=$email " .
    "-F subject='Hello' " .
    "-F text='Testing some Mailgun awesomeness!' ";

  my @files = split ',', $ENV{MAILGUN_FILES};
  for my $file (@files) {
    $command .= "-F attachment=\@$file ";
  }
  system $command;
};

app->start;
