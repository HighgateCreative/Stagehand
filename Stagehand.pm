package Stagehand::Stagehand;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);

$VERSION = 1.00;
@ISA = qw(Exporter);
@EXPORT = qw(model fillinform upload_file combine_errors);

use Dancer ':syntax';
use Dancer::Plugin::DBIC 'schema';
use Data::Dumper;

sub model {
   return schema->resultset( shift );
}

# ===== Helper Functions =====
sub fillinform {
   my $template = shift;
   my $fifvalues = shift;
   my $aux = shift;
   my $html = template $template, $fifvalues, $aux;
   return HTML::FillInForm->fill( \$html, $fifvalues );
}

sub upload_file {
   $| = 1;

   my ($upload, $max, $upload_dir, $sub_dir, $filename, $overwrite) = @_; #upload is the $query->param

   if (not defined $overwrite) { # Set default to 0
      $overwrite = 1;
   }
                                                              #upload_is the main path, $sub_dir is an option new directory that will 
                                                              # that will be created below and appended to $updir                                                            
   $filename =~ s/ /_/g;
   $filename =~ s/^.*[\/ | \\](.*)$/$1/; #strip off path

   if (! -e $upload_dir) { return( undef, "$upload_dir does not exist", undef) };

   #my $upload_filehandle = $self->query->upload($upload);
   if (!$upload) { return ($filename,'Bad file handle. Check form enctype.',$upload); }

   if ($upload->size > $max) {
      return ($filename,'File is too large to upload.',$upload->size);
   }

   if( $sub_dir && ! -e "$upload_dir/$sub_dir") {
      mkdir ("$upload_dir/$sub_dir") or return ($sub_dir, $!, undef);
      my $mode = 0770;   chmod $mode, "$upload_dir/$sub_dir";
      chown 33, 1001, "$upload_dir/$sub_dir";
   }

   $upload_dir = ( $sub_dir ) ? $upload_dir .'/'.$sub_dir : $upload_dir;

   if ( ( not $overwrite ) and -e "$upload_dir/$filename") {
      return ($filename,'File already exists. Rename and try again.',$upload->size);
   } elsif ($overwrite and -e "$upload_dir/$filename") {  #delete file first if one by same name exists
      unlink "$upload_dir/$filename";
   }

   if (not $upload->copy_to($upload_dir."/".$filename)) {
      return ($filename, 'File failed to copy to '.$upload_dir, $upload->size);
   }

   #my $mode = ($upload_dir =~ /client_documents|client_images/) ? 0770 : 0777;   
   #chmod 0770, "$upload_dir/$filename" or return ($filename, 'chmod failed', $upload->size);
   #chown 33, 1001, "$upload_dir/$sub_dir" or return ($filename, 'chown failed', $upload->size);

   return ($filename, '', $upload->size);
}

# Function for combining error returns
sub combine_errors {
   my $msg1 = shift;
   my $msg2 = shift;

   my $msg;
   
   if ($msg1->{errors} and $msg2->{errors}) {
      my @errors = ( @{$msg1->{errors}}, @{$msg2->{errors}} );
      $msg->{errors} = \@errors;
   } elsif ($msg1->{errors}) {
      $msg = $msg1;
   } else {
      $msg = $msg2;
   }
   return $msg;

}

 1;
