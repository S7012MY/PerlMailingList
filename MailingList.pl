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
};

app->start;
