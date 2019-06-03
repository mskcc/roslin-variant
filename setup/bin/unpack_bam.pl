#!/usr/bin/env perl

# GOAL: Extract reads from a BAM into FASTQs, and generate SampleSheet and sample_mapping files,
# formats familiar to the Center for Molecular Oncology (CMO) at MSKCC
# 
# modified on May 30, 2019
# purpose: (1) Extract flowcell/lane information from first read ID of the @RG using @RG's ID; (2) Picard uses PU as fastq files's name if PU does not following the standard format. We need to consider this situation.
# modified on June 3, 2019
# purpose: (1) Re-set default path of java, samtools, and picard's jar file; (2) Added input option of "picard-jar"
# 
# AUTHOR: Cyriac Kandoth (ckandoth@gmail.com); Zuojian Tang (zuojian.tang@gmail.com)

use warnings; # Tells Perl to show warnings on anything that might not work as expected
use strict; # Tells Perl to show errors if any of our code is ambiguous
use IO::File; # Helps us read/write files in a safe way
use Getopt::Long qw( GetOptions ); # Helps parse user provided arguments
use Pod::Usage qw( pod2usage ); # Helps us generate nicely formatted help/man content
use JSON::Parse qw( parse_json_safe ); # Helps us parse JSON files
use Cwd qw( abs_path ); # Somewhat safe way to convert a relative path to an absolute path

# Use the CMO JSON to pull paths to tools and data we'll need
my $java_bin = "java";
my $samtools_bin = "samtools";
my $picard_jar = "/opt/common/CentOS_6-dev/picard/v2.13/picard.jar";

# Check for missing or crappy arguments
unless( @ARGV and $ARGV[0]=~m/^-/ ) {
    pod2usage( -verbose => 0, -message => "$0: Missing or invalid arguments!\n", -exitval => 2 );
}

# Parse options and print usage syntax on a syntax error, or if help was explicitly requested
my ( $man, $help ) = ( 0, 0 );
my ( $bam_file, $output_dir, $sample_id );
GetOptions(
    'help!' => \$help,
    'man!' => \$man,
    'input-bam=s' => \$bam_file,
    'output-dir=s' => \$output_dir,
    'sample-id=s' => \$sample_id,
    'picard-jar=s' => \$picard_jar
) or pod2usage( -verbose => 1, -input => \*DATA, -exitval => 2 );
pod2usage( -verbose => 1, -input => \*DATA, -exitval => 0 ) if( $help );
pod2usage( -verbose => 2, -input => \*DATA, -exitval => 0 ) if( $man );

# Check that the BAM exists with a non-zero size, and create the output directory if necessary
die "ERROR: Provided BAM not found or is empty!\n" unless( -s $bam_file );
mkdir $output_dir unless( -d $output_dir );

# If FASTQs were already created, warn the user. We'll skip Picard but create the @RG info files
my ( $skip_picard, $rg_tag, %fq_info ) = ( 0, "PU", ());
my @fq_files = glob( "$output_dir/rg*/*.fastq.gz" );
if( @fq_files ) {
    warn "WARNING: Will not replace existing FASTQs in $output_dir, but might rename them\n";
    $skip_picard = 1;
}

# Find out how many read-groups are defined in the BAM, and quit if none are found
warn "STATUS: Reading \@RG lines in BAM header of $bam_file\n";
my @rg_lines = grep {chomp; s/^\@RG\t//} `$samtools_bin view -H $bam_file`;
die "ERROR: Read-group (\@RG) information could not be found in the BAM header!\n" unless( @rg_lines );

# Check FLAG 0x1 of just the first read, to find out if we're dealing with multi-segment sequencing
# ::NOTE:: We'll safely assume that multi-segment means paired-end sequencing
my ( $paired_end ) = map {chomp; ( $_ & 0x1 )} `$samtools_bin view $bam_file | head -1 | cut -f2`;

# Parse through the different read-group formats that folks use, and write out a proper SampleSheet
my $sheet_fh = IO::File->new( "$output_dir/SampleSheet.csv", ">" );
$sheet_fh->print( "#FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject,Platform,Library,InsertSize,Date,Center,PlatformUnit\n" );
foreach my $rg_line ( @rg_lines ) {

    # Parse out the easy things first
    my %rg = map{split( /:/, $_, 2 )} split( /\t/, $rg_line );
    my ( $sample_id_from_bam, $platform, $library, $insert_size, $date, $center, $description, $platform_unit ) = map{$rg{$_} ? $rg{$_} : ""} qw( SM PL LB PI DT CN DS PU );

    # Do some cleanup and standardization of terms used
    $platform = lc( $platform );
    $center = "WUSM" if( $center eq "WUGSC" );
    $center = "BCM" if( $center eq "Baylor" );
    $center = "BCGSC" if( $center eq "BCCAGSC" );

    # Figure out FCID, Lane, and Index based on the nutty formats seen in the wild...
    my ( $flowcell_id, $lane, $index );
    # Broad Institute (BI) and WashU put FCID.Lane in the PU tag, as is expected for Illumina data
    # BI appends some sort of number after the XX in the flowcell ID
    # BI appends index seq to FCID.Lane after a dot, while WashU appends it after a hyphen
    # Baylor (BCM) has their own nutty format in the PU tag, that uses an ID# for the index sequence
    # BCM may also prefix letters A or B to the flowcell ID to indicate the side it was loaded
    # MSKCC's deidentified clinical IMPACT BAMs use a deidentified alphanumeric code in the PU tag
    if(( $rg{PU} and $rg{PU} =~ m/^([A-Z0-9]{7}XX)\.(\d+)[.-]?([ACGT]*)$/i ) or
       ( $rg{PU} and $rg{PU} =~ m/^([A-Z0-9]{7}XX\d+)\.(\d+)[.-]?([ACGT-]*)$/i ) or
       ( $rg{PU} and $rg{PU} =~ m/^\w+_[AB]?([A-Z0-9]{7}XX)[_-](\d+)[_-]?(ID\d+)?$/i ) or
       ( $rg{PU} and $rg{PU} =~ m/^(\w\w\d{10}\w\w)$/i )) {
        ( $flowcell_id, $lane, $index ) = map{$_ ? $_ : ""} ( $1, $2, $3 );
    }
    # UNC hides FCID.Lane in a convoluted format within the ID tag, while the PU tag just says "barcode"
    # UNC may also prefix letters A or B to the flowcell ID to indicate the side it was loaded
    # In at least 1 BAM each, UNC prefixed the flowcell ID with FC or FC_6!
    # In at least 1 BAM, UNC used the word "trimmed" in place of the index sequence!
    elsif(( $rg{ID} and $rg{ID} =~ m/^\d+_UNC\S+_[AB]?([A-Z0-9]{7}XX)[_.](\d+)[_.]([ACGT]*)$/ ) or
          ( $rg{ID} and $rg{ID} =~ m/^\d+_UNC\S+_FC([A-Z0-9]{7}XX)[_.](\d+)[_.]([ACGT]*)$/ ) or
          ( $rg{ID} and $rg{ID} =~ m/^\d+_UNC\S+_FC_6([A-Z0-9]{7}XX)[_.](\d+)[_.]([ACGT]*)$/ ) or
          ( $rg{ID} and $rg{ID} =~ m/^\d+_UNC\S+_[AB]?([A-Z0-9]{7}XX)[_.](\d+)[_.]trimmed$/ )) {
        ( $flowcell_id, $lane, $index ) = map{$_ ? $_ : ""} ( $1, $2, $3 );
        $center = "UNC";
        $rg_tag = "ID";
    }
    # Extract FCID and Lane information from Read IDs
    elsif( $rg{ID} ) {
        ( $flowcell_id, $lane ) = map{chomp; split(":")}`samtools view -r $rg{ID} $bam_file | head -n1 | cut -d: -f3,4`;
        $index = "";
    }
    else {
        die "ERROR: Cannot parse flowcell/lane/index from \@RG line:\n$rg_line\n";
    }

    # Figure out what Picard would name this FASTQ, and retain structured info for renaming later
    my $fq_name = $flowcell_id . ( $lane ? ".$lane" : "" );
    $flowcell_id = uc( $flowcell_id ); # Saw at least 1 instance where this was lowercase
    $sample_id = $sample_id_from_bam unless( $sample_id );
    $fq_info{$fq_name} = "$flowcell_id,$lane,$sample_id,$sample_id_from_bam,$index,$description,,,,,$platform,$library,$insert_size,$date,$center,$platform_unit";

    # Write all this info into the SampleSheet
    $sheet_fh->print( $fq_info{$fq_name} . "\n" );
}
$sheet_fh->close;
warn "STATUS: Parsed " . scalar( @rg_lines ) . " \@RG lines from BAM and wrote them into $output_dir/SampleSheet.csv\n";

# Unless FASTQs already exist, use Picard to revert BQ scores, and create FASTQs; then zip em up
unless( $skip_picard ) {
    my $cmd = "$java_bin -Xmx6g -jar $picard_jar RevertSam TMP_DIR=/scratch INPUT=$bam_file OUTPUT=/dev/stdout SANITIZE=true COMPRESSION_LEVEL=0 VALIDATION_STRINGENCY=SILENT | java -Xmx6g -jar $picard_jar SamToFastq TMP_DIR=/scratch INPUT=/dev/stdin OUTPUT_PER_RG=true RG_TAG=$rg_tag OUTPUT_DIR=$output_dir VALIDATION_STRINGENCY=SILENT";
    print "RUNNING: $cmd\n";
    print `$cmd`;
    print "RUNNING: gzip $output_dir/*.fastq\n";
    print `gzip $output_dir/*.fastq`;
}

# Make sure FASTQs follow the Illumina/Casava naming scheme, and move them into per-RG subfolders
# <SAMPLE NAME>_<BARCODE SEQUENCE>_L<LANE NUMBER (0-padded to 3 digits)>_R<READ NUMBER (either 1 or 2)>_<SET NUMBER (0-padded to 3 digits)>.fastq.gz
my $rg_idx = 0;
# Create a sample-fastq mapping file, in the format that the MSK BIC pipeline expects
my $mapping_fh = IO::File->new( "$output_dir/sample_mapping.txt", ">" );
foreach my $fq_name( keys %fq_info ) {
    $rg_idx++;
    mkdir "$output_dir/rg$rg_idx" unless( -d "$output_dir/rg$rg_idx" );
    my ( $lane, $sample_id, $sample_id_from_bam, $index, $library, $platform_unit ) = (split( ",", $fq_info{$fq_name} ))[1,2,3,4,11,15];
    my $padded_lane_id = sprintf( "L%03d", ( $lane ? $lane : "0" ));
    my @fqs_to_rename = glob( "$output_dir/$fq_name*.fastq.gz $output_dir/rg$rg_idx/$fq_name*.fastq.gz $output_dir/$sample_id_from_bam*$padded_lane_id*.fastq.gz $output_dir/rg$rg_idx/$sample_id_from_bam*$padded_lane_id*.fastq.gz $output_dir/$platform_unit*.fastq.gz" );
    my $new_name = "$output_dir/rg$rg_idx/$sample_id_from_bam" . ( $index ? "_$index" : "" ) . "_$padded_lane_id";
    foreach my $fq_to_rename ( @fqs_to_rename ) {
        print `mv -f $fq_to_rename $new_name\_R1_001.fastq.gz` if(( $fq_to_rename =~ m/_1.fastq.gz$/ or $fq_to_rename =~ m/_R1_001.fastq.gz$/ ) and $fq_to_rename ne "$new_name\_R1_001.fastq.gz" );
        print `mv -f $fq_to_rename $new_name\_R2_001.fastq.gz` if(( $fq_to_rename =~ m/_2.fastq.gz$/ or $fq_to_rename =~ m/_R2_001.fastq.gz$/ ) and $fq_to_rename ne "$new_name\_R2_001.fastq.gz" );
    }
    # ::TODO:: Stop hardcoding library name as "_1" after refactoring Roslin QC
    #my $mapping_line = join( "\t", $library, $sample_id, $fq_name, abs_path( "$output_dir/rg$rg_idx" ), ( $paired_end ? "PE" : "SE" ));
    my $mapping_line = join( "\t", "_1", $sample_id, $fq_name, abs_path( "$output_dir/rg$rg_idx" ), ( $paired_end ? "PE" : "SE" ));
    $mapping_fh->print(  "$mapping_line\n" );
}
$mapping_fh->close;
warn "STATUS: Renamed FASTQs to Illumina/Casava naming scheme\n" if( keys %fq_info );
warn "STATUS: Generated FASTQs for " . $rg_idx . " readgroups and made a sample-fastq mapping file at $output_dir/sample_mapping.txt\n";

__DATA__

=head1 NAME

 unpack_bam.pl - Convert a BAM into FASTQs, and extract readgroup info into text files

=head1 SYNOPSIS

 perl unpack_bam.pl --help
 perl unpack_bam.pl --input-bam test.bam --output-dir fastqs --sample-id NM32114

=head1 OPTIONS

 --input-bam      Path to the BAM file to unpack
 --output-dir     Path to output directory where FASTQs and readgroup info files will be stored
 --sample-id      Sample ID for the BAM. Any sample ID in the readgroup data is ignored
 --picard-jar     Path to the Picard Jar file
 --help           Print a brief help message and quit
 --man            Print the detailed manual

=head1 DESCRIPTION

This script parses the readgroup info (lines starting with @RG) in a given BAM file, to generate a SampleSheet.csv and a sample_mapping.txt, formats familiar to the CMO at MSKCC. Then Picard RevertSam followed by SamToFastq, is used to generate safely sanitized FASTQ files per read-group. Note that the script will fail if over 1% of reads had oddities that needed to be sanitized. The resulting FASTQs are renamed to follow the Illumina/Casava naming scheme.

=head2 Relevant links:

 Picard RevertSam: http://broadinstitute.github.io/picard/command-line-overview.html#RevertSam
 Picard SamToFastq: http://broadinstitute.github.io/picard/command-line-overview.html#SamToFastq

=head1 AUTHORS

 Cyriac Kandoth (ckandoth@gmail.com)

=head1 LICENSE

 Apache-2.0 | Apache License, Version 2.0 | https://www.apache.org/licenses/LICENSE-2.0

=cut
