use Email::Valid;
use Mojo::Pg;
use Mojolicious::Lite;
use Time::Stamp 'gmstamp';

my $pg = Mojo::Pg->new('postgresql:///mailing_list');

post '/add-email' => sub {
  my $c = shift;
  my $email = $c->param('email');
  my $first_name = $c->param('firstname');
  my $last_name = $c->param('lastname');
  if (!Email::Valid->address(-address => $email, -mxcheck => 1)) {
    $c->render(text => "Email address is invalid");
    return;
  }
  my $number_existing_emails =
    $pg->db->query('select * from emails where email=?', $email)->rows;
  if ($number_existing_emails > 0) {
    # If the user has already signed up, we show a message.
    $c->render(text => "You have already registered with this email address. " .
      "If you didn't receive the books in your inbox, contact us at " .
      "wellcode\@learnhouse.ro");
    return;
  }
  $pg->db->insert('emails', {
    email => $email,
    first_name => $first_name,
    last_name => $last_name,
    date_submitted => gmstamp(time)
  });
  if (!defined $first_name) {
    $first_name = "there";
  }
  my $email_text = <<EMAIL_END;
Hi $first_name,

As promised, you can find your guide attached in this email.

Keep an eye on our facebook page https://facebook.com/wellcode.ro/ and on
https://wellcode.com since we will soon be launching our starter course in
computer programming!

In the meantime, I hope you enjoy the guide I personally prepared to help
you get a clear picture of your path to becoming a successful software engineer.

Hope to see you soon on wellcode.com!
Petru,
Co-founder of WellCode
EMAIL_END

  my $domain = $ENV{MAILGUN_DOMAIN};
  my $api_key = $ENV{MAILGUN_API_KEY};
  my $command = "curl -s --user 'api:$api_key' " .
    "https://api.mailgun.net/v3/$domain/messages " .
    "-F from='Petru from WellCode <mailgun\@$domain>' " .
    "-F to=$email " .
    "-F subject='Here is your \"How to Become a Programmer\" Guide' " .
    "-F text='" . $email_text . "' ";

  my @files = split ',', $ENV{MAILGUN_FILES};
  for my $file (@files) {
    $command .= "-F attachment=\@$file ";
  }
  system $command;
  $c->redirect_to($ENV{MAILGUN_REDIRECT_TO});
};

app->start;
