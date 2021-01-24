package Acceptessa2::Mail;
use strict;
use warnings;

use Try::Tiny;
use Scalar::Util 'reftype';

use Paws;
use Text::Xslate;
use Email::MIME;

my $TEMPLATE_BUCKET   = 'acceptessa2-mail-template';
my $ATTACHMENT_BUCKET = 'acceptessa2-mail-attachment';

sub run {
    my ( $class, $payload ) = @_;

    ## param check
    if ( ( reftype($payload) || '' ) ne 'HASH' ) {
        return { error => 'invalid parameter' };
    }

    my $template = $payload->{template};
    my $data     = $payload->{data};

    if ( !$template || reftype($template) ) {
        return { error => 'template is invalid' };
    }

    if ( ( reftype($data) || '' ) ne 'HASH' ) {
        return { error => 'data is invalid' };
    }

    my $s3 = Paws->service( 'S3', region => 'ap-northeast-1' );
    my $object;
    my @body;

    ## fetch template
    my $ret = try {
        $object = $s3->GetObject( Bucket => $TEMPLATE_BUCKET, Key => $template );
        return;
    }
    catch {
        return { error => sprintf "error on get template: %s %s", $_->http_status, $_->code };
    };

    return $ret if $ret;

    ## render template
    my $tx       = Text::Xslate->new();
    my $rendered = $tx->render_string( $object->Body, $data );

    push @body,
      Email::MIME->create(
        'attributes' => {
            'content_type' => 'text/html',
            'charset'      => 'utf-8',
            'encoding'     => 'base64',
        },
        'body' => encode( 'utf-8', $rendered ),
      );

    my $parent = Email::MIME->create(
        header => [
            'From'    => encode( 'MIME-Header-ISO_2022_JP', sprintf "%s <%s>", $ex->exhibition_name, $from ),
            'To'      => encode( 'MIME-Header-ISO_2022_JP', $to ),
            'Subject' => encode( 'MIME-Header-ISO_2022_JP', $subject ),
            $cc ? ( 'Cc' => $cc ) : (),
        ],
        parts => \@body,
    );

    ## send mail

    return 1;
}

1;
