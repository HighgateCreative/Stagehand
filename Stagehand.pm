package Stagehand::Stagehand;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);

$VERSION = 1.00;
@ISA = qw(Exporter);
@EXPORT = qw(model fillinform);

use Dancer ':syntax';
use Dancer::Plugin::DBIC 'schema';

sub model {
   return schema->resultset( shift );
}

# ===== Helper Functions =====
sub fillinform {
   my $template = shift;
   my $fifvalues = shift;
   my $html = template $template, $fifvalues;
   return HTML::FillInForm->fill( \$html, $fifvalues );
}

 1;
