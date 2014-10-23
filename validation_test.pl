#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @missings;

# define data validation structures ...
my $stock_data = {
  'suppliers' => [
    '214'
  ],
  'colours' => [
    '3',
    '4'
  ],
  'other_fields' => {
    'department' => '1',
    'on_cost' => undef,
    'uoms' => '',
    'uomb_s_conversion' => undef,
    'sell_price_uoms' => undef,
    'latest_cost_uomb' => undef,
    'uomb' => ''
  },
  'stockitem' => {
    'plu_desc' => '',
    'persnl_size_id' => 'Y',
    'manufr_colour_id' => '2',
    'vat_desc_id' => 'Y',
    'stock_item_code' => undef,
    'zero_stock_held_yn' => undef,
    'goods_or_expense_ge' => '',
    'stock_desc2' => '',
    'weighted_item' => 'N',
    'size_id' => undef,
    'short_code' => undef,
    'web_relevant_change' => 'Y',
    'weight_kg' => undef,
    'persnl_name_number_yn' => 'Y',
    'persnl_shirt_patch_yn' => 'Y',
    'style_code' => 'St! yle',
    'stock_desc1' => 'Stock',
    'persnl_colour_id' => 'Y',
    'size_pattern_id' => undef,
    'lead_time_days' => undef,
    'class_id' => '1',
    'persnl_number_only_yn' => 'Y'
  },
  'sizes' => [
    '282',
    '283'
  ],
  'name' => 'Richar d2010',
};

# define my validation profile ...
my $main_profile = {
	constraints => {
		colours => [ Test_Validation::value_duplicates(), ],
		sizes   => [ Test_Validation::value_duplicates(), ],
		name    => [ Test_Validation::value_is_alphanumeric(), ],
	}	
};	
my $stock_profile = {
	constraints => {
		stock_desc1 => [ Test_Validation::value_is_alphanumeric(), ],
		style_code  => [ Test_Validation::value_is_alphanumeric(), ],
	}	
};	

# execute the validation ...
my $results = Test_Validation->check($main_profile, $stock_data);
if ( $results->{constraints}->[0] ) {
	print "The main dv results are : \n";
	print Dumper($results);
}	
$results = Test_Validation->check($stock_profile, $stock_data->{stockitem});
if ( $results->{constraints}->[0] ) {
	print "The stockitems dv results are : \n";
	print Dumper($results);
	print Dumper($results->{constraints}->[0][0]);
}	
if ( $results->{constraints}->[0]) { print "an error has been found \n"; } else { print "all okay \n"; }
exit;

package Test_Validation;
use Data::Dumper;
use List::MoreUtils qw(distinct);

#-------------------------------------------------------------------------------
sub check {
	my ($self, $profile, $data) = @_;
	my $results;
	
	# check required fields ...
	my @required;
	foreach ( @{$profile->{required}} ) {
		unless ( $data->{$_} ) { push(@required, $_); }
	}
	$results->{required} = \@required;
	
	# process constraints ...
	my @constraints;
	foreach ( keys %{$profile->{constraints}} ) {
		if ( ref($profile->{constraints}->{$_}) eq "ARRAY" ) {		
			my $counter = 0;	
			my $length = $#{$profile->{constraints}->{$_}};
			while ( $counter <= $length ) {
				if ( my $constraint = $profile->{constraints}->{$_}->[$counter]->($data->{$_}) ) {
					push(@constraints, [$_, $constraint]);
					last;
				}
				$counter++;
			}		
		}	
		else {
			if ( my $constraint = $profile->{constraints}->{$_}->( $data->{$_} ) ) { 
				push(@constraints, [$_, $constraint]); 
			}
		}		
	}
	$results->{constraints} = \@constraints;
	
	return $results;	
}

#-------------------------------------------------------------------------------
sub value_duplicates {
	return sub {
		my $array = shift;

		my $array_elements = @{$array};
		my $array_distinct = distinct(@{$array});
		if ( $array_elements == $array_distinct ) {
			return 0;
		}
		else {
			return 'Duplicate values found';
		}
	}	   
}

#-------------------------------------------------------------------------------
sub value_in {
	my ($array) = @_;
	if (not (defined $array)) {
		print "a data array (ref) is required\n\n";
	}
	return sub {
		my ($value) = @_;
		my $matched_value  = grep { uc($_) eq uc($value) } @{$array};
		if ( $matched_value ) {  
			return 0;
		}
		else {
			return 'Invalid value';
		}
	}	
}

#-------------------------------------------------------------------------------
sub value_between {
	my ($min, $max) = @_;
	if (not (defined $min and defined $max)) {
		print "max and min values are required\n\n";
	}
	return sub {
		my ($value) = @_;
		print "passed value : $value\n";
		if ( ( $value > $max ) || ( $value < $min) ) {
			return 'Value outside range' 
		}
		else {
			return 0;
		}
	}
}

#-------------------------------------------------------------------------------
sub value_is_number {
	return sub {
		my ($number) = @_;
		if ( $number =~ /^-?\d+\.?\d*$/ ) {  
			return 0;
		}
		else {
			return 'Not a Number';
		}
	}    
}

#-------------------------------------------------------------------------------
sub value_is_alphanumeric {
	return sub {
		my $string = shift;
		if ( $string =~ m/[^a-zA-Z0-9\s]/ ) {  
			return 'Contains non alpha / numeric values';
		}
		else {
			return 0;
		}
	}    
}

1;
