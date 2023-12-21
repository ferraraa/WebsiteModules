package filesystem;

use strict;
#use warnings;
use Class::Struct;
use lib '/users/anferrar/perl534i/bin/perl';
use File::Find::Rule;
use File::Basename;
use Data::Dumper;
use Storable;
my $LEVEL = 1;

## Input: Directory Path
## Output: Array of Strings
## This function returns the contents of a directory
sub getDirectoryContents {

	# Function Input
	my $directorypath = shift;

	# Open Directory, Read Contents, Close Directory
	opendir( my $directory, $directorypath );
	my @allcontents = readdir $directory;
	closedir $directory;

	# Remove the '.' '..' Points to 'Current Directory' and 'Parent Directory'
	my $contentslen = @allcontents . length;
	$contentslen = $contentslen;
	my @contents = @allcontents[ 2 .. $contentslen ];

	# Output the Contents
	return @contents;
}

## Input: Directory Path
## Output: Array of Strings
## This function returns the contents of a directory. It filters out any filename that has a '.' in it, assuming it to be a file.
sub getDirectoryContentsOnlyDirectories {

	# Function Input
	my $directorypath = shift;

	# Get entire contents of the directory
	my @contents = getDirectoryContents( $directorypath );

	# Filter out everything with a '.' character
	my @contents_dironly;
	my $j = 0;
	my $i = 0;
	my $charinstring;

	for ( $i = 0 ; $i < @contents . length ; $i++ ) {
		$charinstring = index( $contents[ $i ], '.' );
		if ( $charinstring == -1 ) {    # Assume it is not a file
			$contents_dironly[ $j ] = $contents[ $i ];
			$j++;
		}
	}

	# Output only Directories
	return @contents_dironly[ 0 .. $j - 2 ];
}

## Input: Directory Path
## Output: Array of Strings
## This function returns the contents of a directory. It keeps any filename that has a '.txt' in it, assuming it to be a txt file.
sub getDirectoryContentsTxtOnly {

	# Function Input
	my $directorypath = shift;

	# Get entire contents of the directory
	my @contents = getDirectoryContents( $directorypath );

	# Filter out everything with a '.' character
	my @contents_txtonly;
	my $j = 0;
	my $i = 0;
	my $charinstring;

	for ( $i = 0 ; $i < @contents . length ; $i++ ) {
		$charinstring = index( $contents[ $i ], '.txt' );
		if ( $charinstring > 0 ) {    # Assume it is not a file
			$contents_txtonly[ $j ] = $contents[ $i ];
			$j++;
		}
	}

	# Output only .txt files
	return @contents_txtonly[ 0 .. $j - 2 ];
}

## Input: A Directory containing data files of the following format: (Most common DUT will be a DDS)
# DUT_MeasurementType_InputFreq_OutputFreq.txt
# or
# DUT_MeasurementType_InputFreq_OutputFreq_OutputPower.txt
## Output: A Struct containing all relevant information to the data in the directory.
## This function looks inside a directory and parses the text file
sub hashEveryDDSTextFile {

	# Function Input
	my $directorypath = shift;

	# Get List of Text Files
	my @textfileswithpaths = File::Find::Rule->file->name( '*.txt' )->in( $directorypath );
	my @textfiles          = map { basename $_ } @textfileswithpaths;

	# Parse Each Text File Name for Information
	my @DataHashes;
	my $DDS;
	my $MeasurementType;
	my $InFreq;
	my $OutFreq;
	my $InPower;
	my $OutPower;

	for ( my $filecount = 0 ; $filecount < scalar( @textfiles ) ; $filecount++ ) {
		my $DataFile     = $textfileswithpaths[ $filecount ];
		my @ParsedString = split( /_/, $textfiles[ $filecount ] );

		if ( scalar( @ParsedString ) == 4 ) {    # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq.txt
			$DDS             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$InFreq          = $ParsedString[ 2 ];
			$OutFreq         = substr( $ParsedString[ 3 ], 0, -4 );    # Delete the '.txt' file extension
			$InPower         = 'NA';
			$OutPower        = 'NA';
		} elsif ( scalar( @ParsedString ) == 5 ) {                     # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq_OutputPower.txt
			$DDS             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$InFreq          = $ParsedString[ 3 ];
			$OutFreq         = substr( $ParsedString[ 4 ], 0, -4 );    # Delete the '.txt' file extension
			$InPower         = 'NA';
			$OutPower        = $ParsedString[ 2 ];
		}

		# Make Hash of the Information
		my %SingleHash = (
			'FileName' => substr( $DataFile, 0, -4 ),
						   'DataFile'    => $DataFile,
						   'DUT'         => $DDS,
						   'MeasType'    => $MeasurementType,
						   'InputFreq'   => $InFreq,
						   'OutputFreq'  => $OutFreq,
						   'InputPower'  => $InPower,
						   'OutputPower' => $OutPower
		);

		# Make Array of Hashes
		push( @DataHashes, \%SingleHash );

	}

	return @DataHashes;
}

sub hashEveryDivTextFile {

	# Function Input
	my $directorypath = shift;

	# Get List of Text Files
	my @textfileswithpaths = File::Find::Rule->file->name( '*.txt' )->in( $directorypath );
	my @textfiles          = map { basename $_ } @textfileswithpaths;

	# Parse Each Text File Name for Information
	my @DataHashes;
	my $DDS;
	my $MeasurementType;
	my $InFreq;
	my $OutFreq;
	my $InPower;
	my $OutPower;

	for ( my $filecount = 0 ; $filecount < scalar( @textfiles ) ; $filecount++ ) {
		my $DataFile     = $textfileswithpaths[ $filecount ];
		my @ParsedString = split( /_/, $textfiles[ $filecount ] );

		if ( scalar( @ParsedString ) == 5 ) {    # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq.txt
			$DDS             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$InFreq          = $ParsedString[ 2 ];
			$OutFreq         = $ParsedString[ 3 ];
			$InPower         = substr( $ParsedString[ 4 ], 0, -4 );    # Delete the '.txt' file extension
			$OutPower        = 'NA';
		} elsif ( scalar( @ParsedString ) == 6 ) {                     # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq_OutputPower.txt
			$DDS             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$InFreq          = $ParsedString[ 2 ];
			$OutFreq         = $ParsedString[ 3 ];
			$InPower         = $ParsedString[ 4 ];
			$OutPower        = substr( $ParsedString[ 5 ], 0, -4 );    # Delete the '.txt' file extension
		}

		# Make Hash of the Information
		my %SingleHash = (
			'FileName' => substr( $DataFile, 0, -4 ),
						   'DataFile'    => $DataFile,
						   'DUT'         => $DDS,
						   'MeasType'    => $MeasurementType,
						   'InputFreq'   => $InFreq,
						   'OutputFreq'  => $OutFreq,
						   'InputPower'  => $InPower,
						   'OutputPower' => $OutPower
		);

		# Make Array of Hashes
		push( @DataHashes, \%SingleHash );

	}

	return @DataHashes;
}


sub hashEveryAmpTextFile {

	# Function Input
	my $directorypath = shift;

	# Get List of Text Files
	my @textfileswithpaths = File::Find::Rule->file->name( '*.txt' )->in( $directorypath );
	my @textfiles          = map { basename $_ } @textfileswithpaths;

	# Parse Each Text File Name for Information
	my @DataHashes;
	my $Amp;
	my $MeasurementType;
	my $InFreq;
	my $InPower;
	my $OutPower;
	my $Note;

	for ( my $filecount = 0 ; $filecount < scalar( @textfiles ) ; $filecount++ ) {
		my $DataFile     = $textfileswithpaths[ $filecount ];
		my @ParsedString = split( /_/, $textfiles[ $filecount ] );

		if ( scalar( @ParsedString ) == 5 ) {    # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq.txt
			$Amp             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$InFreq          = $ParsedString[ 2 ];
			$InPower         = $ParsedString[ 3 ];
			$OutPower        = substr( $ParsedString[ 4 ], 0, -4 );


			# Make Hash of the Information
			my %SingleHash = (
							'FileName' => substr( $DataFile, 0, -4 ),
							   'DataFile'    => $DataFile,
							   'DUT'         => $Amp,
							   'MeasType'    => $MeasurementType,
							   'InputFreq'   => $InFreq,
							   'InputPower'  => $InPower,
							   'OutputPower' => $OutPower
			);

			# Make Array of Hashes
			push( @DataHashes, \%SingleHash );
		} elsif ( scalar( @ParsedString ) == 6 ) {    # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq.txt
			$Amp             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$InFreq          = $ParsedString[ 2 ];
			$InPower         = $ParsedString[ 3 ];
			$OutPower        = $ParsedString[ 4 ];
			$Note = substr( $ParsedString[ 5 ], 0, -4 );


			# Make Hash of the Information
			my %SingleHash = (
							'FileName' => substr( $DataFile, 0, -4 ),
							   'DataFile'    => $DataFile,
							   'DUT'         => ($Amp . '-' . $Note),
							   'MeasType'    => $MeasurementType,
							   'InputFreq'   => $InFreq,
							   'InputPower'  => $InPower,
							   'OutputPower' => $OutPower
			);

			# Make Array of Hashes
			push( @DataHashes, \%SingleHash );
		}

	}

	return @DataHashes;
}

sub hashEveryRefTextFile {

	# Function Input
	my $directorypath = shift;

	# Get List of Text Files
	my @textfileswithpaths = File::Find::Rule->file->name( '*.txt' )->in( $directorypath );
	my @textfiles          = map { basename $_ } @textfileswithpaths;

	# Parse Each Text File Name for Information
	my @DataHashes;
	my $DUT;
	my $MeasurementType;
	my $Freq;
	my $LockBW;

	for ( my $filecount = 0 ; $filecount < scalar( @textfiles ) ; $filecount++ ) {
		my $DataFile     = $textfileswithpaths[ $filecount ];
		my @ParsedString = split( /_/, $textfiles[ $filecount ] );

		if ( scalar( @ParsedString ) == 3 ) {    # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq.txt
			$DUT             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$Freq          = substr( $ParsedString[ 2 ], 0, -4 );# Delete the '.txt' file extension
			$LockBW         = 'NA';
		} elsif ( scalar( @ParsedString ) == 4 ) {                     # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq_OutputPower.txt
			$DUT             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$Freq          = $ParsedString[ 2 ];
			$LockBW         = substr( $ParsedString[ 3 ], 0, -4 );# Delete the '.txt' file extension;
		}

		# Make Hash of the Information
		my %SingleHash = (
			'FileName' => substr( $DataFile, 0, -4 ),
						   'DataFile'    => $DataFile,
						   'DUT'         => $DUT,
						   'MeasType'    => $MeasurementType,
						   'Freq'   => $Freq,
						   'LockBW'  => $LockBW
		);

		# Make Array of Hashes
		push( @DataHashes, \%SingleHash );

	}

	return @DataHashes;
}

sub hashEverySrcTextFile {

	# Function Input
	my $directorypath = shift;

	# Get List of Text Files
	my @textfileswithpaths = File::Find::Rule->file->name( '*.txt' )->in( $directorypath );
	my @textfiles          = map { basename $_ } @textfileswithpaths;

	# Parse Each Text File Name for Information
	my @DataHashes;
	my $DUT;
	my $MeasurementType;
	my $Freq;
	my $Power;

	for ( my $filecount = 0 ; $filecount < scalar( @textfiles ) ; $filecount++ ) {
		my $DataFile     = $textfileswithpaths[ $filecount ];
		my @ParsedString = split( /_/, $textfiles[ $filecount ] );

		if ( scalar( @ParsedString ) == 3 ) {    # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq.txt
			$DUT             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$Freq          = substr( $ParsedString[ 2 ], 0, -4 );# Delete the '.txt' file extension
			$Power        = 'NA';
		} elsif ( scalar( @ParsedString ) == 4 ) {                     # Assume file name structure is: DUT_MeasurementType_InputFreq_OutputFreq_OutputPower.txt
			$DUT             = $ParsedString[ 0 ];
			$MeasurementType = $ParsedString[ 1 ];
			$Freq          = $ParsedString[ 2 ];
			$Power         = substr( $ParsedString[ 3 ], 0, -4 );# Delete the '.txt' file extension;
		}

		# Make Hash of the Information
		my %SingleHash = (
			'FileName' => substr( $DataFile, 0, -4 ),
						   'DataFile'    => $DataFile,
						   'DUT'         => $DUT,
						   'MeasType'    => $MeasurementType,
						   'Freq'   => $Freq,
						   'Power'  => $Power
		);

		# Make Array of Hashes
		push( @DataHashes, \%SingleHash );

	}

	return @DataHashes;
}

sub searchHashArrayForUnique {
	my $HashArray = shift;
	my $HashParam = shift;
	my $tempstr;
	my @ArrayOfUniques;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr = $HashArray->[ $hashcount ]->{ $HashParam };

		if ( $tempstr ~~ @ArrayOfUniques ) {

		} else {
			push( @ArrayOfUniques, $tempstr );
		}

	}

	return @ArrayOfUniques;

}

sub searchHashArrayGivenParam {
	my ( $HashArray, $HashParam, $HashParamVal ) = @_;
	my @DataFiles;
	my @DataHashes;
	my $DataFileCount = 0;

	for ( my $hashparamcount = 0 ; $hashparamcount < scalar @{ $HashParamVal } ; $hashparamcount++ ) {
		for ( my $hasharraycount = 0 ; $hasharraycount < scalar @{ $HashArray } ; $hasharraycount++ ) {
			if ( $HashArray->[ $hasharraycount ]->{ $HashParam } eq $HashParamVal->[ $hashparamcount ] ) {
				my $SingleHash = $HashArray->[ $hasharraycount ];
				
				#for (my $datafilecount = 0; $datafilecount < scalar(@DataFiles); $datafilecount++){
					if ($SingleHash->{FileName} ~~ @DataFiles) {
						
						
					} else {
						push (@DataFiles, $SingleHash->{FileName});
						push( @DataHashes, $SingleHash );
					}
					
					
				#}

				
			}
		}


	}

	return ( \@DataHashes, \@DataFiles );

}

sub searchHashArrayGiven2Params {
	my ( $HashArray, $HashParam1, $HashParamVal1, $HashParam2, $HashParamVal2 ) = @_;
	my @DataFiles;
	my @DataHashes;
	my $DataFileCount = 0;

	for ( my $hashparamcount1 = 0 ; $hashparamcount1 < scalar @{ $HashParamVal1 } ; $hashparamcount1++ ) {
		for ( my $hashparamcount2 = 0 ; $hashparamcount2 < scalar @{ $HashParamVal2 } ; $hashparamcount2++ ) {
		for ( my $hasharraycount = 0 ; $hasharraycount < scalar @{ $HashArray } ; $hasharraycount++ ) {
			if ( $HashArray->[ $hasharraycount ]->{ $HashParam1 } eq $HashParamVal1->[ $hashparamcount1 ] &&
				$HashArray->[ $hasharraycount ]->{ $HashParam2 } eq $HashParamVal2->[ $hashparamcount2 ]) {
				my $SingleHash = $HashArray->[ $hasharraycount ];
				
				#for (my $datafilecount = 0; $datafilecount < scalar(@DataFiles); $datafilecount++){
					if ($SingleHash->{FileName} ~~ @DataFiles) {
						
						
					} else {
						push (@DataFiles, $SingleHash->{FileName});
						push( @DataHashes, $SingleHash );
					}
					
					
				#}
			}
		}
		}


	}

	return ( \@DataHashes, \@DataFiles );
	

}

sub searchHashArrayGiven3Params {
	my ( $HashArray, $HashParam1, $HashParamVal1, $HashParam2, $HashParamVal2, $HashParam3, $HashParamVal3 ) = @_;
	my @DataFiles;
	my @DataHashes;
	my $DataFileCount = 0;

	for ( my $hashparamcount1 = 0 ; $hashparamcount1 < scalar @{ $HashParamVal1 } ; $hashparamcount1++ ) {
		for ( my $hashparamcount2 = 0 ; $hashparamcount2 < scalar @{ $HashParamVal2 } ; $hashparamcount2++ ) {
		for ( my $hashparamcount3 = 0 ; $hashparamcount3 < scalar @{ $HashParamVal3 } ; $hashparamcount3++ ) {
		for ( my $hasharraycount = 0 ; $hasharraycount < scalar @{ $HashArray } ; $hasharraycount++ ) {
			if ( $HashArray->[ $hasharraycount ]->{ $HashParam1 } eq $HashParamVal1->[ $hashparamcount1 ] &&
				$HashArray->[ $hasharraycount ]->{ $HashParam2 } eq $HashParamVal2->[ $hashparamcount2 ] &&
				$HashArray->[ $hasharraycount ]->{ $HashParam3 } eq $HashParamVal3->[ $hashparamcount3 ]) {
				my $SingleHash = $HashArray->[ $hasharraycount ];
				#for (my $datafilecount = 0; $datafilecount < scalar(@DataFiles); $datafilecount++){
					if ($SingleHash->{FileName} ~~ @DataFiles) {
						
						
					} else {
						push (@DataFiles, $SingleHash->{FileName});
						push( @DataHashes, $SingleHash );
					}
					
					
				#}
			}
		}
		}
		}


	}

	return ( \@DataHashes, \@DataFiles );
	

}


sub makeLegendArray_InputOutputPowerPairs {
	my $HashArray = shift;
	my $tempstr1;
	my $tempstr2;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr1 = $HashArray->[ $hashcount ]->{ InputPower };
		$tempstr2 = $HashArray->[ $hashcount ]->{ OutputPower };

		push( @LegendArray, $tempstr1 . ', ' . $tempstr2 );
	}

	return @LegendArray;


}

sub makeLegendArray_DUTFreqPowerPairs {
	my $HashArray = shift;
	my $tempstr1;
	my $tempstr2;
	my $tempstr3;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr1 = $HashArray->[ $hashcount ]->{ DUT };
		$tempstr2 = $HashArray->[ $hashcount ]->{ Freq };
		$tempstr3 = $HashArray->[ $hashcount ]->{ Power };

		push( @LegendArray, $tempstr1 . ', ' . $tempstr2 . ', ' . $tempstr3 );
	}

	return @LegendArray;


}

sub makeLegendArray_InputPowerDUTPairs {
	my $HashArray = shift;
	my $tempstr1;
	my $tempstr2;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr1 = $HashArray->[ $hashcount ]->{ InputPower };
		$tempstr2 = $HashArray->[ $hashcount ]->{ DUT };

		push( @LegendArray, $tempstr1 . ', ' . $tempstr2 );
	}

	return @LegendArray;


}
sub makeLegendArray_DUTInputOutputPowerPairs {
	my $HashArray = shift;
	my $tempstr1;
	my $tempstr2;
	my $tempstr3;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr1 = $HashArray->[ $hashcount ]->{ DUT };
		$tempstr2 = $HashArray->[ $hashcount ]->{ InputPower };
		$tempstr3 = $HashArray->[ $hashcount ]->{ OutputPower };
		push( @LegendArray, $tempstr1 . ': ' . $tempstr2 . ', ' . $tempstr3 );
	}

	return @LegendArray;


}
sub makeLegendArray_OutputFreqInputPowerPairs {
	my $HashArray = shift;
	my $tempstr2;
	my $tempstr3;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr2 = $HashArray->[ $hashcount ]->{ OutputFreq };
		$tempstr3 = $HashArray->[ $hashcount ]->{ InputPower };
		push( @LegendArray, $tempstr2 . ', ' . $tempstr3 );
	}

	return @LegendArray;


}
sub makeLegendArray_InputFreqInputPowerPairs {
	my $HashArray = shift;
	my $tempstr2;
	my $tempstr3;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr2 = $HashArray->[ $hashcount ]->{ InputFreq };
		$tempstr3 = $HashArray->[ $hashcount ]->{ InputPower };
		push( @LegendArray, $tempstr2 . ', ' . $tempstr3 );
	}

	return @LegendArray;


}
sub makeLegendArray_DUTInputFreqInputPowerPairs {
	my $HashArray = shift;
	my $tempstr1;
	my $tempstr2;
	my $tempstr3;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr1 = $HashArray->[ $hashcount ]->{ DUT };
		$tempstr2 = $HashArray->[ $hashcount ]->{ InputFreq };
		$tempstr3 = $HashArray->[ $hashcount ]->{ InputPower };
		push( @LegendArray, $tempstr1 . ', ' . $tempstr2 . ', ' . $tempstr3 );
	}

	return @LegendArray;


}


sub makeLegendArray_RefFreqRefPairs {
	my $HashArray = shift;
	my $tempstr2;
	my $tempstr3;
	my @LegendArray;

	for ( my $hashcount = 0 ; $hashcount < scalar @{ $HashArray } ; $hashcount++ ) {
		$tempstr2 = $HashArray->[ $hashcount ]->{ Freq };
		$tempstr3 = $HashArray->[ $hashcount ]->{ DUT };
		push( @LegendArray, $tempstr2 . ', ' . $tempstr3 );
	}

	return @LegendArray;


}

1;
