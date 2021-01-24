package Acceptessa2::Mail;
use strict;
use warnings;

use Acceptessa2::Mail::Parameter;

use Try::Tiny;
use Encode;
use File::Basename;

use Paws;
use Text::Xslate;
use Email::MIME;

my $TEMPLATE_BUCKET   = 'acceptessa2-mail-template';
my $ATTACHMENT_BUCKET = 'acceptessa2-mail-attachment';

sub get_template {
    my ($self, $key) = @_;
    my $s3  = Paws->service('S3', region => 'ap-northeast-1');
    my $ret = try {
        return $s3->GetObject(Bucket => $TEMPLATE_BUCKET, Key => $key);
    }
    catch {
        warn "template not found: $key";
        return;
    };
}

sub get_attachment {
    my ($self, $key) = @_;

    # warn $key;
    return;
}

sub send_mail {
    my $ses = Paws->service('SES', region => 'us-east-1');
    return;
}

sub run {
    my ($class, $payload) = @_;
    my $p = try { Acceptessa2::Mail::Parameter->new($payload) }
      or return { error => 'invalid parameter' };

    ## fetch template
    my $tmpl = $class->get_template($p->template)
      or return { error => 'template not found' };

    ## render template
    my $tx       = Text::Xslate->new();
    my $rendered = $tx->render_string($tmpl, $p->data);

    $rendered =~ s/<!--\s*(.*?)\s+-->\r?\n//;    ## subject get from template's first comment
    my $subject = $1;
    my @mimes;

    push @mimes,
      Email::MIME->create(
        'attributes' => {
            'content_type' => 'text/html',
            'charset'      => 'utf-8',
            'encoding'     => 'base64',
        },
        'body' => encode('utf-8', $rendered),
      );

    if (my $attaches = $p->attachment) {

        # while (my ($id, $s3key) = each %{ $p->attachment }) {
        # while (my ($id, $s3key) = each %{ $p->attachment }) {
        for my $id (sort keys %$attaches) {
            my $s3key   = $attaches->{$id};
            my $content = $class->get_attachment($s3key);
            my $base    = basename($s3key);

            push @mimes,
              Email::MIME->create(
                header_str => [
                    'Content-Id' => "<$id>",
                ],
                attributes => {
                    content_type => 'image/jpeg',
                    name         => $base,
                    filename     => $base,
                    encoding     => 'base64',
                    disposition  => 'attachment',
                },
                body => $content,
              );

        }

    }

    my $parent = Email::MIME->create(
        header => [
            'From'    => encode('MIME-Header-ISO_2022_JP', $p->from),    # sprintf "%s <%s>", $ex->exhibition_name, $from,
            'To'      => encode('MIME-Header-ISO_2022_JP', $p->to),
            'Subject' => encode('MIME-Header-ISO_2022_JP', $subject),
            $p->cc ? ('Cc' => $p->cc) : (),
        ],
        parts => \@mimes,
    );

    ## send mail
    $class->send_mail($parent);

    return { success => 1 };
}

1;
