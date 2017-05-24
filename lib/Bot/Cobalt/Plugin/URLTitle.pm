package Bot::Cobalt::Plugin::URLTitle;
# ABSTRACT: Bot::Cobalt plugin for printing the title of a URL

use strict;
use warnings;

use Bot::Cobalt;
use Bot::Cobalt::Common;

use Mojo::UserAgent;
use HTML::Entities    qw(decode_entities);
use Text::Unidecode   qw(unidecode);
use URI::Find::Simple qw(list_uris);

sub new     { bless {}, shift  }
sub ua      { shift->{useragent} }

sub Cobalt_register {
   my $self = shift;
   my $core = shift;
   my $conf = $core->get_plugin_cfg($self);

   $self->{useragent} = Mojo::UserAgent->new;

   register( $self, 'SERVER', 'public_msg' );
   logger->info("Registered");

   return PLUGIN_EAT_NONE;
}

sub Cobalt_unregister {
   my $self = shift;
   my $core = shift;

   logger->info("Unregistered");
   
   return PLUGIN_EAT_NONE;
}

sub Bot_public_msg {
   my $self = shift;
   my $core = shift;
   my $msg  = ${ shift() };

   my $context = $msg->context;
   my $channel = $msg->target;

   foreach my $uri ( list_uris($msg->message) ) {
      next if not $uri;

      my $title = $self->ua->get($uri)->result->dom->at('title')->text or next;
      my $uni   = unidecode($title);
      my $resp  = sprintf('[ %s ]', $uni ? $uni : $title);
      broadcast( 'message', $context, $channel, $resp );
   }

   return PLUGIN_EAT_NONE;
}

1;
__END__

=pod

=head1 SYNOPSIS

   ## In plugins.conf
   URLTitle:
      Module: Bot::Cobalt::Plugin::URLTitle

=head1 DESCRIPTION

A L<Bot::Cobalt> plugin.

This plugin retrieves the title of any URL in a message using 
L<Mojo::UserAgent> and prints the message to the channel. 

