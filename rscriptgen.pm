package rscriptgen;

use strict;
#use warnings;
use lib '/users/anferrar/perl5/lib/perl5/';
use File::Temp;

my $LEVEL = 1;

sub makeRGraphScriptBruteForce {
	my ( $datafiles, $htmldir, $legend, $xmin, $xmax, $ymin, $ymax, $ystep, $Title, $smooth ) = @_;
	system( 'rm ' . $htmldir . '/tmp/*.png 2> ' . $htmldir . 'tmp/text.txt' );
	my $RScriptID = File::Temp->new(
									 TEMPLATE => 'GenerateGraphXXXXX',
									 DIR      => '/users/anferrar/public_html/tmp/',
									 SUFFIX   => '.r'
	);
	my $GraphFile    = $RScriptID->filename . '.png';
	my $GraphID      = $GraphFile;
	my $scriptloc    = '/users/anferrar/public_html/tmp/';
	my $scriptstart  = $scriptloc . '/RGenerateGraphTemplateStart.txt';
	my $scriptvars   = $scriptloc . '/RGenerateGraphTemplateStartForInputs.txt';
	my $scriptmiddle = $scriptloc . '/RGenerateGraphTemplateMiddle.txt';
	my $scriptend    = $scriptloc . '/RGenerateGraphTemplateEnd.txt';
	my @colorarray   = [ "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7" ];

	open my $FILEStartID,  '<', $scriptstart;
	open my $FILEVarsID,   '<', $scriptvars;
	open my $FILEMiddleID, '<', $scriptmiddle;
	open my $FILEEndID,    '<', $scriptend;

	# Print First Block of Data

	while ( my $line = <$FILEVarsID> ) {
		print $RScriptID $line;
	}

	if ( not defined $xmin ) {
		print $RScriptID ( 'xstart = 1;' );
		print $RScriptID ( 'xstop = 160e6;' );
		print $RScriptID ( 'ystart = -190;' );
		print $RScriptID ( 'ystop = 0;' );
		print $RScriptID ( 'ystep = 10;' );
		print $RScriptID ( 'PhaseNoisePlotTitle = "Phase Noise";' );

	} else {
		print $RScriptID ( 'xstart = ' . $xmin . ';' );
		print $RScriptID ( 'xstop = ' . $xmax . ';' );
		print $RScriptID ( 'ystart = ' . $ymin . ';' );
		print $RScriptID ( 'ystop = ' . $ymax . ';' );
		print $RScriptID ( 'ystep = ' . $ystep . ';' );
		print $RScriptID ( 'PhaseNoisePlotTitle = "' . $Title . '";' );
	}
	if ( defined $smooth ) {
		print $RScriptID ( 'smooth_on = 1;' );
	} else {
		print $RScriptID ( 'smooth_on = 0;' );
	}

	while ( my $line = <$FILEStartID> ) {
		print $RScriptID $line;
	}
	if ( scalar @{ $datafiles } > 1 ) {

		for ( my $filecount = 0 ; $filecount < ( scalar @{ $datafiles } - 1 ) ; $filecount++ ) {
			print $RScriptID ( 'file.path("' . $datafiles->[ $filecount ] . '.txt"),' );
		}
	}
	print $RScriptID ( 'file.path("' . $datafiles->[ scalar @{ $datafiles } - 1 ] . '.txt")' );
	print $RScriptID ');';

	while ( my $line = <$FILEMiddleID> ) {
		print $RScriptID $line;
	}

	for ( my $filecount = 0 ; $filecount < ( scalar @{ $datafiles } ) ; $filecount++ ) {
		print $RScriptID ( 'geom_line(data = phasenoisedata[[' . ( $filecount + 1 ) . ']], aes(x = freq, y = pnoise, color="' . $legend->[ $filecount ] . '"), size=1) +' );

	}

	while ( my $line = <$FILEEndID> ) {
		print $RScriptID $line;
	}

	print $RScriptID ( '(ggsave("' . $GraphID . '", width = graphwidth, height = graphheight, dpi = graphdpi));' );

	close $FILEStartID;
	close $FILEMiddleID;
	close $FILEVarsID;
	close $FILEEndID;
	return ( $RScriptID, $GraphID );
}

sub makeRGraphScriptBruteForce_DDSandRef {
	my ( $datafiles, $htmldir, $legend, $DUTFreq, $RefFreq, $xmin, $xmax, $ymin, $ymax, $ystep, $Title, $smooth ) = @_;
	system( 'rm ' . $htmldir . '/tmp/*.png 2> ' . $htmldir . 'tmp/text.txt' );
	my $RScriptID = File::Temp->new(
									 TEMPLATE => '12XXXXX',
									 DIR      => '/users/anferrar/public_html/tmp/',
									 SUFFIX   => '.r'
	);
	my $GraphFile    = $RScriptID->filename . '.png';
	my $GraphID      = $GraphFile;
	my $scriptloc    = '/users/anferrar/public_html/tmp/';
	my $scriptstart  = $scriptloc . '/RGenerateGraphTemplateStart.txt';
	my $scriptvars   = $scriptloc . '/RGenerateGraphTemplateStartForInputs.txt';
	my $scriptmiddle = $scriptloc . '/RGenerateGraphTemplateMiddle_DDSandRef.txt';
	my $scriptend    = $scriptloc . '/RGenerateGraphTemplateEnd.txt';
	my @colorarray   = [ "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7" ];

	open my $FILEStartID,  '<', $scriptstart;
	open my $FILEVarsID,   '<', $scriptvars;
	open my $FILEMiddleID, '<', $scriptmiddle;
	open my $FILEEndID,    '<', $scriptend;

	# Print First Block of Data

	while ( my $line = <$FILEVarsID> ) {
		print $RScriptID $line;
	}


	if ( not defined $xmin ) {
		print $RScriptID ( 'xstart = 1;' );
		print $RScriptID ( 'xstop = 160e6;' );
		print $RScriptID ( 'ystart = -190;' );
		print $RScriptID ( 'ystop = 0;' );
		print $RScriptID ( 'ystep = 10;' );
		print $RScriptID ( 'PhaseNoisePlotTitle = "Phase Noise";' );
		print $RScriptID ( 'DUTFreq = ' . substr( @{$DUTFreq}[ 0 ], 0, -6 ) . ';' );
		print $RScriptID ( 'RefFreq = c(');
		if (scalar @{$RefFreq} > 1) {
		for (my $reffreqcount = 0; $reffreqcount < (scalar @{$RefFreq} - 1); $reffreqcount++) {
			my @RefString = split(/, /, $RefFreq->[$reffreqcount]);
			print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ',');		
		}
		}
		my @RefString = split(/, /, $RefFreq->[scalar @{$RefFreq}-1]);
		print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ');');

	} else {
		print $RScriptID ( 'xstart = ' . $xmin . ';' );
		print $RScriptID ( 'xstop = ' . $xmax . ';' );
		print $RScriptID ( 'ystart = ' . $ymin . ';' );
		print $RScriptID ( 'ystop = ' . $ymax . ';' );
		print $RScriptID ( 'ystep = ' . $ystep . ';' );
		print $RScriptID ( 'PhaseNoisePlotTitle = "' . $Title . '";' );
		print $RScriptID ( 'DUTFreq = ' . substr( @{$DUTFreq}[ 0 ], 0, -6 ) . ';' );
		print $RScriptID ( 'RefFreq = c(');
		if (scalar @{$RefFreq} > 1) {
		for (my $reffreqcount = 0; $reffreqcount < (scalar @{$RefFreq} - 1); $reffreqcount++) {
			my @RefString = split(/, /, $RefFreq->[$reffreqcount]);
			print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ',');		
		}
		}
		my @RefString = split(/, /, $RefFreq->[scalar @{$RefFreq}-1]);
		print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ');');

	}
	if ( defined $smooth ) {
		print $RScriptID ( 'smooth_on = 1;' );
	} else {
		print $RScriptID ( 'smooth_on = 0;' );
	}

	while ( my $line = <$FILEStartID> ) {
		print $RScriptID $line;
	}
	if ( scalar @{ $datafiles } > 1 ) {

		for ( my $filecount = 0 ; $filecount < ( scalar @{ $datafiles } - 1 ) ; $filecount++ ) {
			print $RScriptID ( 'file.path("' . $datafiles->[ $filecount ] . '.txt"),' );
		}
	}
	print $RScriptID ( 'file.path("' . $datafiles->[ scalar @{ $datafiles } - 1 ] . '.txt")' );
	print $RScriptID ');';

	while ( my $line = <$FILEMiddleID> ) {
		print $RScriptID $line;
	}

	for ( my $filecount = 0 ; $filecount < ( scalar @{ $datafiles } ) ; $filecount++ ) {
		print $RScriptID ( 'geom_line(data = phasenoisedata[[' . ( $filecount + 1 ) . ']], aes(x = freq, y = pnoise, color="' . $legend->[ $filecount ] . '"), size=1) +' );

	}

	while ( my $line = <$FILEEndID> ) {
		print $RScriptID $line;
	}

	print $RScriptID ( '(ggsave("' . $GraphID . '", width = graphwidth, height = graphheight, dpi = graphdpi));' );
	close $FILEStartID;
	close $FILEMiddleID;
	close $FILEVarsID;
	close $FILEEndID;
	return ( $RScriptID, $GraphID );
}

sub makeRGraphScriptBruteForce_ManyDDSandRef {
	my ( $datafiles, $htmldir, $legend, $DUTFreq, $RefFreq, $xmin, $xmax, $ymin, $ymax, $ystep, $Title, $smooth ) = @_;
	system( 'rm ' . $htmldir . '/tmp/*.png 2> ' . $htmldir . 'tmp/text.txt' );
	my $RScriptID = File::Temp->new(
									 TEMPLATE => '12XXXXX',
									 DIR      => '/users/anferrar/public_html/tmp/',
									 SUFFIX   => '.r'
	);
	my $GraphFile    = $RScriptID->filename . '.png';
	my $GraphID      = $GraphFile;
	my $scriptloc    = '/users/anferrar/public_html/tmp/';
	my $scriptstart  = $scriptloc . '/RGenerateGraphTemplateStart.txt';
	my $scriptvars   = $scriptloc . '/RGenerateGraphTemplateStartForInputs.txt';
	my $scriptmiddle = $scriptloc . '/RGenerateGraphTemplateMiddle_ManyDDSandRef.txt';
	my $scriptend    = $scriptloc . '/RGenerateGraphTemplateEnd.txt';
	my @colorarray   = [ "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7" ];

	open my $FILEStartID,  '<', $scriptstart;
	open my $FILEVarsID,   '<', $scriptvars;
	open my $FILEMiddleID, '<', $scriptmiddle;
	open my $FILEEndID,    '<', $scriptend;

	# Print First Block of Data
	while ( my $line = <$FILEVarsID> ) {
		print $RScriptID $line;
	}


	if ( not defined $xmin ) {
		print $RScriptID ( 'xstart = 1;' );
		print $RScriptID ( 'xstop = 160e6;' );
		print $RScriptID ( 'ystart = -190;' );
		print $RScriptID ( 'ystop = 0;' );
		print $RScriptID ( 'ystep = 10;' );
		print $RScriptID ( 'PhaseNoisePlotTitle = "Phase Noise";' );
		print $RScriptID ( 'DUTFreq = ' . substr( @{$DUTFreq}[ 0 ], 0, -6 ) . ';' );
		print $RScriptID ( 'RefFreq = ');
		if (scalar @{$RefFreq} > 1) {
		for (my $reffreqcount = 0; $reffreqcount < (scalar @{$RefFreq} - 1); $reffreqcount++) {
			my @RefString = split(/, /, $RefFreq->[$reffreqcount]);
			print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ',');		
		}
		}
		my @RefString = split(/, /, $RefFreq->[scalar @{$RefFreq}-1]);
		print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ';');

	} else {
		print $RScriptID ( 'xstart = ' . $xmin . ';' );
		print $RScriptID ( 'xstop = ' . $xmax . ';' );
		print $RScriptID ( 'ystart = ' . $ymin . ';' );
		print $RScriptID ( 'ystop = ' . $ymax . ';' );
		print $RScriptID ( 'ystep = ' . $ystep . ';' );
		print $RScriptID ( 'PhaseNoisePlotTitle = "' . $Title . '";' );
		print $RScriptID ( 'DUTFreq = ' . substr( @{$DUTFreq}[ 0 ], 0, -6 ) . ';' );
		print $RScriptID ( 'RefFreq = ');
		if (scalar @{$RefFreq} > 1) {
		for (my $reffreqcount = 0; $reffreqcount < (scalar @{$RefFreq} - 1); $reffreqcount++) {
			my @RefString = split(/, /, $RefFreq->[$reffreqcount]);
			print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ',');		
		}
		}
		my @RefString = split(/, /, $RefFreq->[scalar @{$RefFreq}-1]);
		print $RScriptID ( substr( $RefString[ 0 ], 0, -3 ) . ';');

	}
	if ( defined $smooth ) {
		print $RScriptID ( 'smooth_on = 1;' );
	} else {
		print $RScriptID ( 'smooth_on = 0;' );
	}

	while ( my $line = <$FILEStartID> ) {
		print $RScriptID $line;
	}
	if ( scalar @{ $datafiles } > 1 ) {

		for ( my $filecount = 0 ; $filecount < ( scalar @{ $datafiles } - 1 ) ; $filecount++ ) {
			print $RScriptID ( 'file.path("' . $datafiles->[ $filecount ] . '.txt"),' );
		}
	}
	print $RScriptID ( 'file.path("' . $datafiles->[ scalar @{ $datafiles } - 1 ] . '.txt")' );
	print $RScriptID ');';

	while ( my $line = <$FILEMiddleID> ) {
		print $RScriptID $line;
	}

	for ( my $filecount = 0 ; $filecount < ( scalar @{ $datafiles } ) ; $filecount++ ) {
		print $RScriptID ( 'geom_line(data = phasenoisedata[[' . ( $filecount + 1 ) . ']], aes(x = freq, y = pnoise, color="' . $legend->[ $filecount ] . '"), size=1) +' );

	}

	while ( my $line = <$FILEEndID> ) {
		print $RScriptID $line;
	}

	print $RScriptID ( '(ggsave("' . $GraphID . '", width = graphwidth, height = graphheight, dpi = graphdpi));' );
	close $FILEStartID;
	close $FILEMiddleID;
	close $FILEVarsID;
	close $FILEEndID;

	return ( $RScriptID, $GraphID );
}

1;
