package webpage;

use strict;
use warnings;
use CGI::Easy::SendFile;
my $LEVEL = 1;

## Input: Dropdown Section Name, Label, and Contents
## This function creates a dropdown menu for a webform
sub makeDropDownMenu {
	my ( $cgi, $dropdownname, $dropdowntitle, $dropdownoptions ) = @_;
	print $cgi ->div(
					  $cgi->label( { -for => $dropdownname }, $dropdowntitle ),
					  $cgi->popup_menu(
										-name     => $dropdownname,
										-id       => $dropdownname,
										-values   => $dropdownoptions,
										-onchange => 'this.form.submit()'
					  ),
	);
}

## Input: Button Section Name, Label, and Contents, and Button Types
## This function creates a group of buttons for a webform
sub makeButtons {

	my ( $cgi, $buttontype, $name, $title, $buttons, $default) = @_;
	if ( $buttontype eq 'checkbox' ) {
		print $cgi ->div(
						  $cgi->label( { -for => $name }, $title ),
						  $cgi->checkbox_group(
												-name      => $name,
												-values    => $buttons,
												-onchange  => 'this.form.submit()',
												-default   => 'unchecked',
												-linebreak => 'true',
												-columns => 8
						  ),
		);
	}

	# Default is radio button
	else {
		
		print $cgi ->div(
						  $cgi->label( { -for => $name }, $title ),
						  $cgi->radio_group(
											 -name      => $name,
											 -values    => $buttons,
											 -onchange  => 'this.form.submit()',
											 -default   => $default,
											 -linebreak => 'true',
											 -columns => 8
						  ),
		);

	}

}

sub makeButtonsWithLabels {
	my ( $cgi, $name, $title, $buttons, $nextline, $labels ) = @_;
	print $cgi ->div(
						  $cgi->label( { -for => $name }, $title ),
						  $cgi->checkbox_group(
												-name      => $name,
												-values    => $buttons,
												-labels		=> $labels,
												-onchange  => 'this.form.submit()',
												-default   => 'unchecked',
												-linebreak => $nextline
						  ),
		);
}

sub makeTextBoxInput {
	my ( $cgi, $textboxname, $textboxtitle, $textboxsize, $textboxdefault ) = @_;
	print $cgi ->label( { -for => $textboxname }, $textboxtitle ),
		$cgi->textfield(
						 -name    => $textboxname,
						 -default => $textboxdefault,
						 -size    => $textboxsize
		);
}

sub makeGraphInputs {
	my ( $cgi, $smoothingoptionname ) = @_;
	print '<br>';
	print '<br>';
	print 'Hit Enter for Changes to Have Effect <br>';
	webpage::makeTextBoxInput( $cgi, 'xmin', 'Frequency Start [Hz]: ',        4, 1 );
	webpage::makeTextBoxInput( $cgi, 'xmax', '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Frequency Stop [Hz]: ', 4, 160e6 );
	print '<br>';
	webpage::makeTextBoxInput( $cgi, 'ymin', 'Low Noise Limit [dBc/Hz]: ',           4, -190 );
	webpage::makeTextBoxInput( $cgi, 'ymax', '&nbsp;&nbsp;&nbsp;&nbsp;Upper Noise Limit [dBc/Hz]: ', 4, 0 );
	webpage::makeTextBoxInput( $cgi, 'ydiv', '&nbsp;&nbsp;&nbsp;&nbsp;Noise [dB/div]: ',             4, 10 );
	print '<br>';
	webpage::makeTextBoxInput( $cgi, 'graphtitle', 'Plot Title: ', 50, 'Phase Noise' );
	print '<br>';
	print $cgi ->div(
					  $cgi->label( { -for => $smoothingoptionname }, 'Smoothing On: ' ),
					  $cgi->checkbox(
									  -name     => 'Smooth',
									  -values   => 'Smooth',
									  -onchange => 'this.form.submit()',
									  -default  => 'unchecked',
									  -disabled => 'true'
					  ),
	);
	return 1;
}

sub DownloadFiles {
	my ($cgi, $DataFiles, $htmldir) = @_;
	my $filestring = $DataFiles->[0] . '*';
	if (scalar @{$DataFiles} > 1) {
	for (my $filecount = 1; $filecount < scalar @{$DataFiles}; $filecount++) {
		$filestring = $filestring . ' ' . $DataFiles->[$filecount] . '*';
	}
	}
	my $filename = 'data' . time . '.tar';
	#system( 'rm ' . $htmldir . '/tmp/*.tar' );
	system( 'tar -cf ' . $htmldir . '/tmp/' . $filename . ' ' . $filestring);
	print '<br><br>';
	print $cgi-> a({href => ('http://www.srs.is.keysight.com/~anferrar/tmp/' . $filename)}, "Right-Click, Save Link As... To Save Data");

}

1;
