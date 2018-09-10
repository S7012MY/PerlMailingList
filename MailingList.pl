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
  my $email_text =
<<EMAIL_END
Hi there,

Thanks for subscribing to our newsletter, we promise we'll only send you
content that we believe is relevant to you. Keep an eye on our facebook page
https://facebook.com/wellcode.ro/ and on https://wellcode.com since we'll soon
be launching our starter course in computer programming!

In the meantime, I hope you enjoy those two books I personally prepared to help
you get a clear picture of your path to being a successful software engineer.
They're both attached here.

Hope to see you soon on wellcode.com!
Petru,
Co-founder of Wellcode
EMAIL_END

  my $domain = $ENV{MAILGUN_DOMAIN};
  my $api_key = $ENV{MAILGUN_API_KEY};
  my $command = "curl -s --user 'api:$api_key' " .
    "https://api.mailgun.net/v3/$domain/messages " .
    "-F from='Excited User <mailgun\@$domain>' " .
    "-F to=$email " .
    "-F subject='Here are your books for your WellCode subscription' ";
    "-F text='$email_text' ";

  my @files = split ',', $ENV{MAILGUN_FILES};
  for my $file (@files) {
    $command .= "-F attachment=\@$file ";
  }
  system $command;
  $c->redirect_to($ENV{MAILGUN_REDIRECT_TO});
};

app->start;
