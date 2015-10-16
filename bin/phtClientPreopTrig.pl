#!/usr/bin/perl
##use strict ;
use XML::Simple ;
use Data::Dumper ;

my $osname = $^O;
if( $osname eq 'MSWin32' ) {
   $logDir = "c:/temp" ;
} else {
   $logDir = "/tmp" ;
}

my $logFile = "$logDir/accurevTrigLog.txt" ;
my $dateTime = localtime() ;

# vars used to parse param file
my ($file, $xmlinput_raw, $xmlinput);

# vars to store parsed param values
my ($hook, $output_file, $action, $option_I, $depot, $stream1, $stream2, $changePackages,
    $comment, $elemType, $topDir, $principal, $elem_name, @elems,) ;

##################################
sub debugInfo {
# check parsed variables
    print LOGFILE "DEBUG INFO\n" ;
    print LOGFILE "hook = $hook\n" ;
    print LOGFILE "output_file = $output_file\n" ;
    print LOGFILE "action = $action\n" ;
    print LOGFILE "option_I = $option_I\n" ;
    print LOGFILE "depot = $depot\n" ;
    print LOGFILE "stream1 = $stream1\n" ;
    print LOGFILE "stream2 = $stream2\n" ;
    print LOGFILE "changePackages = $changePackages\n" ;
    print LOGFILE "comment = $comment\n" ;
    print LOGFILE "elemnType = $elemType\n" ;
    print LOGFILE "topDir = $topDir\n" ;
    print LOGFILE "principal = $principal\n" ;
    print LOGFILE "\nelems:\n  ", join("\n  ", @elems), "\n" ;
}
##################################
sub trigDie {
  print LOGFILE @_ , "\n" ;
  print @_ , "\n" ;
  close LOGFILE ;
  exit 1 ;
}
##################################
sub preCreate {
} # end preCreate
##################################
sub preKeep {
} # end preKeep
##################################
#
# Policy : Promote is only allowed from up-to-date workspaces.
#
##################################
sub prePromote {

my ($cmd, @cmdOut, $exitStatus, $isWorkspaceStream, $updateMsg, $wsNeedsUpdate) ;

# No need to perform preview update if triggered by purge on dynamic stream
  return 0 if ($action =~ /purge/) ;
  return 0 if ($ENV{FORCE_UPDATE}) ;

# No need to perform preview update unless source stream is a workspace
  $cmd = "accurev show -s \"$stream1\" -fx streams" ;
  @cmdOut = `$cmd` ;
  $exitStatus = $? ;
  die "Non-zero exit status ($exitStatus) from cmd: $cmd" if ($exitStatus) ;
  $isWorkspaceStream = grep(/^\s+type="workspace"/, @cmdOut) ;
  return 0 unless ($isWorkspaceStream) ;

  $updateMsg = <<EOM
This project requires that code be promoted from an up-to-date workspace.
Your workspace is not up-to-date.  Please update your workspace, and rebuild
any code being promoted (if required). Then, try to promote again.
EOM
;
  chdir $topDir;
  use Cwd;
  $dir = getcwd();    # Where am I?
  print LOGFILE $dir."\n";

  $cmd = "accurev update -i" ;
  @cmdOut = `$cmd` ;
  $exitStatus = $? ;
  if ($exitStatus) {

    $updateMsg = <<EOM
Preview update returned non-zero ($exitStatus).  Please check the output below and correct the problem.
Output from "accurev update -i" :
EOM
;
    $updateMsg .= join("", @cmdOut) ;
    trigDie ($updateMsg) ;
  }
  print LOGFILE @cmdOut ;
  $wsNeedsUpdate = grep(/^(Would make|Making)\s+\d+\s+change/, @cmdOut) ;  # grep returns num matches for scalar context
  trigDie($updateMsg) if ($wsNeedsUpdate) ;

} # end prePromote
##################################
sub parseInput {

    # read trigger input file, xml is passed second
    $file = $ARGV[1];
    open PARAMS, "<$file" or die "Can't open $file";
    while (<PARAMS>){
        $xmlinput_raw = ${xmlinput_raw}.$_;
    }
    close PARAMS;

    # populate array using XML::Simple routine
    $xmlinput = XMLin($xmlinput_raw, forcearray => 1, suppressempty => '');

    # set variables
    $hook = $$xmlinput{'hook'}[0];
    $output_file = $$xmlinput{'output_file'}[0];
    $action = $$xmlinput{'action'}[0];
    $option_I = $$xmlinput{'option_I'}[0];
    $depot = $$xmlinput{'depot'}[0];
    $stream1 = $$xmlinput{'stream1'}[0];
    $stream2 = $$xmlinput{'stream2'}[0];
    $changePackages = $$xmlinput{'changePackages'}[0];
    $comment = $$xmlinput{'comment'}[0];
    $elemType = $$xmlinput{'elemType'}[0];
    $topDir = $$xmlinput{'topDir'}[0];
    $principal = $$xmlinput{'principal'}[0];
    foreach $elem_name (@{$$xmlinput{'elemList'}[0]{'elem'}}) { push (@elems, $elem_name); }
} # end parseInput
##################################
##############
#  main()    #
##############
if (not -d $logDir) {
  mkdir($logDir) || die "ERROR: Could not create directory $logDir" ;
}
open(LOGFILE, ">>$logFile") or die "Could not open $logFile for append." ;
parseInput() ;

# Print the parameters input to the trigger log
print LOGFILE "$xmlinput_raw\n" ;

#debugInfo() if $ENV{DEBUG} ;
debugInfo();

# There are only 3 client-side preop triggers.  This script serves as a single entry point for all three.
if ($hook =~ /pre-create/) {
  preCreate() ;
} elsif ($hook =~ /pre-keep/) {
  preKeep() ;
} elsif ($hook =~ /pre-promote/) {
  prePromote() ;
} # end if/else

close(LOGFILE) ;
