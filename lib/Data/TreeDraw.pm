package Data::TreeDraw;
use strict;
use warnings;
use Scalar::Util qw/reftype blessed/;
use Class::MOP;
use Text::SimpleTable;
use Carp;

use version; our $VERSION = qv('0.0.1');

require Exporter ;
our @ISA = qw(Exporter) ;
our @EXPORT = qw(draw);

# for printig number of times hash key is found it should say 1 time if once...

#=fs POD

=head1 NAME

Data::TreeDraw - Graphical representation of nested data structures.

=cut

=head1 VERSION

This document describes Data::TreeDraw version 0.0.1

=cut

=head1 DESCRIPTION

While there are a number of great programs out there for Dumping and visualising heavily nested data structures these can
often be over-whelming and hard to read. Additionally, often in order to access a particular data entry you often
have to back-trace over a Dumped structure to find the specific code appropriate to dereference that particular
value. This module aims to address these issues and several others by providing number of different features with a
very simple interface that is particularly aimed at helping to visualise data-rich heavily-nested structures - see
OVERVIEW. 

This module exports a single sub-routine call C<draw>. Simply call this routine with the data structure you wish to
print along with a HASH reference of any options you wish to pass - see OPTIONS and OVERVIEW. 

This module was written by me, for me and so internally may be a bit esoteric. If there is significant
interest I will improve and expand it.

=cut

=head1 SYNOPSIS

Create suitable structure.

    # Create a Code Reference.
    my $c_ref = sub { print q{blah}; $_->[0] };
    # Create a heavily nested set of references.
    my $r_ref = \\\\\[q{pink},321];
    # Create an object of type HASH;
    my $pca->{g} = 4;
    bless $pca, q{Some::Class}; 
    # Create a GLOB.
    *f = *g;

    # Create a nested data structure with various typed of nested data e.g. defined and undefined SCALAR, ARRAY, HASH and REFs
    my $a = [ q{hi}, q{there}, [ q{i}, q{am} ], 1, { r => \\q{} }, { r => { y => 3 }, t => [ { r => *g } ] }, $c_ref, *f, $r_ref, q{nine}, [ [ 3,q{----3-----}, 3 ], 
    [3, 3, 3, 3, ], [ 3, 3, 3, ] ], 1, \\\{ r => \[] }, \\\q{foo}, { g => 2, t => 2, y => q{------2-------}, r => [3], step => { the => q{blah} }, o => [ [4] 
    ] }, [ [ [q{--4--}]] , [ [ 4, 4, q{-4-}, q{--4--} ] ], 2, [3] ], \\\q{}, 1, [ [3 , 3], 2, $pca] , 1, { g => [ 3, 3, q{blah}, 3, 3, 3 ] } ,[ [ 3 ] ], $a, undef ];
    
    # Create cyclic references.
    my $b = [$a]; 
    my $c = [$b];
    $a->[2][3] = $c;
    $a->[2][2] = $a;
    # Make our nested data structure an object
    bless $a, q{Other::Class};

Use module and call C<draw> routine on structure.
    
    use Data::TreeDraw;

    draw($a);

Prints:

    Method called from Package 'main' on Blessed Object of type 'ARRAY' and Class 'Other::Class'.

    ARRAY REFERENCE (0)
      |  
      |__SCALAR = 'hi' (1)  [ '->[0]' ]
      |  
      |__SCALAR = 'there' (1)  [ '->[1]' ]
      |  
      |__ARRAY REFERENCE (1) [ '->[2]' ]
      |    |  
      |    |__SCALAR = 'i' (2)  [ '->[2][0]' ]
      |    |  
      |    |__SCALAR = 'am' (2)  [ '->[2][1]' ]
      |    |  
      |    |__CYCLIC REFERENCE (2) [ '->[2][2]' ]
      |    |  
      |    |__ARRAY REFERENCE (2) [ '->[2][3]' ]
      |         |  
      |         |__ARRAY REFERENCE (3) [ '->[2][3][0]' ]
      |              |  
      |              |__CYCLIC REFERENCE (4) [ '->[2][3][0][0]' ]
      |  
      |__SCALAR = '1' (1)  [ '->[3]' ]
      |  
      |__HASH REFERENCE (1) [ '->[4]' ]
      |    |  
      |    |__'r'=>REFERENCE-TO-REFERENCE (2)
      |         |  
      |         |__SCALAR REFERENCE (3)
      |              |  
      |              |__SCALAR = '' [EMPTY STRING] (4) 
      |  
      |__HASH REFERENCE (1) [ '->[5]' ]
      |    |  
      |    |__'r'=>HASH REFERENCE (2) [ '->[5]{r}' ]
      |    |    |  
      |    |    |__'y'=>SCALAR = '3' (3)  [ '->[5]{r}{y}' ]
      |    |  
      |    |__'t'=>ARRAY REFERENCE (2) [ '->[5]{t}' ]
      |         |  
      |         |__HASH REFERENCE (3) [ '->[5]{t}[0]' ]
      |              |  
      |              |__'r'=>GLOB = '*main::g' (4)  [ '->[5]{t}[0]{r}' ]
      |  

      etc.

=cut

=head1 OVERVIEW

=head2 Tree Structure

All structures are displayed as a "clear" Tree-structure branching from a single root. 

     ARRAY REFERENCE (0)
     |  
     |__SCALAR = 'hi' (1)  [ '->[0]' ]
     |  
     |__SCALAR = 'there' (1)  [ '->[1]' ]
     |  
     |__ARRAY REFERENCE (1) [ '->[2]' ]
     |    |  
     |    |__SCALAR = 'i' (2)  [ '->[2][0]' ]
     |    |  
     |    |__SCALAR = 'am' (2)  [ '->[2][1]' ]
     |    |  
     |    |__CYCLIC REFERENCE (2) [ '->[2][2]' ]
     |    |  
     |    |__ARRAY REFERENCE (2) [ '->[2][3]' ]
     |         |  
     |         |__ARRAY REFERENCE (3) [ '->[2][3][0]' ]
    
     etc.

=head2 Notation

The C<notation> option (defaults to on - with "1") results in the printing along side (in square-brackets) the specific REFERENCE or SCALAR
value of the particular arrow-notation required to access/dereference that REFERENCE or SCALAR value e.g. "[ '->[4]{hash_key}[12]' ]" next to an ARRAY reference means that to dereference 
that particular value within the passed structure simply append "->[4]{hash_key}[12] " to the originally passed reference.

     e.g. To access the above ARRAY reference printed as: "ARRAY REFERENCE (2) [ '->[2][3][0]' ]" 
     Simply use: $original_data_passed->[2][3][0];

=head2 Spacing

For a more compressed version of the print disable the C<spaces> options by setting it to "0" (this option is enabled by default). The above Tree is printed as:

     ARRAY REFERENCE (0)
       |__SCALAR = 'hi' (1)  [ '->[0]' ]
       |__SCALAR = 'there' (1)  [ '->[1]' ]
       |__ARRAY REFERENCE (1) [ '->[2]' ]
       |    |__SCALAR = 'i' (2)  [ '->[2][0]' ]
       |    |__SCALAR = 'am' (2)  [ '->[2][1]' ]
       |    |__CYCLIC REFERENCE (2) [ '->[2][2]' ]
       |    |__ARRAY REFERENCE (2) [ '->[2][3]' ]
       |         |__ARRAY REFERENCE (3) [ '->[2][3][0]' ]
       |              |__CYCLIC REFERENCE (4) [ '->[2][3][0][0]' ]

       etc.

=head2 Indentation Level

The nesting/indentation level of ALL structures is printed along-side of the REFERENCE/SCALAR value in parenthesis:

     e.g. SCALAR = 'some_value' (nesting_level/e.g.4) 

=head2 EMPTY STRINGS

Any SCALAR value containing an empty string is printed as that e.g. '', but to ease distinguishing it from ' ' it additionally prints [EMPTY STRING] along-side. 

     e.g. SCALAR = '' [EMPTY STRING]

=head2 Long Arrays

With data-rich structures arrays may often have many elements. In such cases printing each SCALAR value within the array on a separate line makes reading the structure difficult:

     ARRAY REFERENCE (2) [ '->[20]{g}' ]
       |  
       |__SCALAR = 'val1' (3)  [ '->[20]{g}[0]' ]
       |  
       |__SCALAR = 'val2' (3)  [ '->[20]{g}[1]' ]
       |  
       |__SCALAR = 'val3' (3)  [ '->[20]{g}[2]' ]
       |  
       |__SCALAR = 'val4' (3)  [ '->[20]{g}[3]' ]

       etc.

The C<long_array> option (defaults to off - "0") over-rides this behaviour and instead arrays consisting of "just" SCALAR values are printed on a single-line. With this
setting relatively short arrays are printed in full on a single line along with their length:

     ARRAY REFERENCE (3) ---LONG_LIST_OF_SCALARS--- [ length = 4 ]: val1, val2, val3, val4 [ '->[20]{g}' 

Longer arrays are printed in a similar fashion except that only the length and first 3 elements are printed (just to
indicate the nature of the values stored by the array). 

     ARRAY REFERENCE (2) ---LONG_LIST_OF_SCALARS--- [ length = 4 ] e.g. 0..2:  val1, val2, val3 [ '->[20]{g}' ]

You can switch the length of array that triggers these two behaviours using the C<array_length> option (defaults to 3). See OPTIONS for further info.

=head2 Lists-of-Lists. 

In cases of Lists-of-lists the readability may suffer further - especially as these structures often
correspond to 2-dim tables. Thus in cases of ARRAYS consisting uniquely of ARRAYS of SCALARS: 

     |__ARRAY REFERENCE (2) [ '->[10][0]' ]
     |    |  
     |    |__SCALAR = '2' (3)  [ '->[10][0][0]' ]
     |    |  
     |    |__SCALAR = '3' (3)  [ '->[10][0][1]' ]
     |    |  
     |    |__SCALAR = '3' (3)  [ '->[10][0][2]' ]
     |  
     |__ARRAY REFERENCE (2) [ '->[10][1]' ]
     |    |  
     |    |__SCALAR = '3' (3)  [ '->[10][1][0]' ]
     |    |  
     |    |__SCALAR = '3' (3)  [ '->[10][1][1]' ]
     |    |  
     |    |__SCALAR = '3' (3)  [ '->[10][1][2]' ]
     |    |  
     |    |__SCALAR = '3' (3)  [ '->[10][1][3]' ]
     |  
     |__ARRAY REFERENCE (2) [ '->[10][2]' ]
          |  
          |__SCALAR = '3' (3)  [ '->[10][2][0]' ]
          |  
          |__SCALAR = '3' (3)  [ '->[10][2][1]' ]
          |  
          |__SCALAR = '3' (3)  [ '->[10][2][2]' ]

The C<lol> option when set to "1" will replace these structures with (this option defaults to "0"):

    ARRAY REFERENCE (1) ---LIST OF LISTS--- [ rows = 3 and longest nested list length = 4 ] [ '->[10]' ]

You may be interested in the particular values within these structures. In this case C<lol> set to "2" creates a
temporary break in the tree-structure with a table of the values and their access values and an extension of their root:

     ARRAY REFERENCE (1) ---LIST OF LISTS--- [ rows = 3 and longest nested list length = 4 ] [ '->[10]' ]
       |  
      --- 

 .----------+-------+-------+-------+-------.
 |          | ..[0] | ..[1] | ..[2] | ..[3] |
 +----------+-------+-------+-------+-------+
 | ..[0]..  | '3'   | '3'   | '3'   | ---   |
 | ..[1]..  | '3'   | '3'   | '3'   | '3'   |
 | ..[2]..  | '3'   | '3'   | '3'   | ---   |
 '----------+-------+-------+-------+-------'

      --- 
       |  


This option may be used with the C<long_arrays> option in which case the C<lol> option takes precedence and above
structure would be printed as above instead of:

     |__ARRAY REFERENCE (1) [ '->[10]' ]
        |  
        |__ARRAY REFERENCE (2) ---LONG_LIST_OF_SCALARS--- [ length = 3 ]: 3, 3, 3 [ '->[10][0]' ]
        |  
        |__ARRAY REFERENCE (2) ---LONG_LIST_OF_SCALARS--- [ length = 4 ]: 3, 3, 3, 3 [ '->[10][1]' ]
        |  
        |__ARRAY REFERENCE (2) ---LONG_LIST_OF_SCALARS--- [ length = 3 ]: 3, 3, 3 [ '->[10][2]' ]

=head2 HASH keys. 

As HASHES are simply unordered LISTs using a look up key HASH references are displayed just ARRAY
references only with the hash key appended e.g.

     |__HASH REFERENCE (1) [ '->[20]' ]
          |  
          |__'hash_key'=>ARRAY REFERENCE (2) [ '->[20]{g}' ]
               |  
               |__SCALAR = '3' (3)  [ '->[20]{g}[0]' ]

=head2 HASH key lookup

You may be interested in just the values of a particular HASH entry. In this case using the C<hash_key> option you can
start Tree printing from that particular HASH key. See OPTIONS for usage.

    HASH key 'given_key' found and indentation level '5':

                    |__'given_key'=>REFERENCE-TO-REFERENCE (5)
                         |    |  
                         |__UNDEFINED ARRAY REFERENCE (6) 
      
                    etc.

    HASH key 'given_key' found 2 times in nested data structure.

=head2 Minimum printing depth

You may not be interested in values near the root of the structure. In which case you can set the C<min_depth> option
(defaults to 0).

     Starting print at depth 2.
 
     |    |__SCALAR = 'i' (2)  [ '->[2][0]' ]
     |    |  
     |    |__SCALAR = 'am' (2)  [ '->[2][1]' ]
     |    |  
     |    |__CYCLIC REFERENCE (2) [ '->[2][2]' ]
     |    |  
     |    |__ARRAY REFERENCE (2) [ '->[2][3]' ]
     |         |  
     |         |__ARRAY REFERENCE (3) [ '->[2][3][0]' ]
     |              |  
     |              |__CYCLIC REFERENCE (4) [ '->[2][3][0][0]' ]
     |  

     Indent decrementing to '1' below min_depth level of '2'

     |    |__'r'=>REFERENCE-TO-REFERENCE (2)
     |         |  
     |         |__SCALAR REFERENCE (3)
     |              |  
     |              |__SCALAR = '' [EMPTY STRING] (4) 
     |  


=head2 Maximum printing depth

If you do not wish to view deeply nested structures you can set the C<max_depth> option (defaults to 10):

     ARRAY REFERENCE (0)
     |  
     |__SCALAR = 'hi' (1)  [ '->[0]' ]
     |  
     |__SCALAR = 'there' (1)  [ '->[1]' ]
     |  
     |__ARRAY REFERENCE (1) [ '->[2]' ]
     |    |  
     |    |__SCALAR EXCEEDS MAX NESTING DEPTH (2)
     |    |  
     |    |__SCALAR EXCEEDS MAX NESTING DEPTH (2)
     |    |  

     etc.

=head2 Object recursion.

In cases where an object reference is pointed within the structure its class will be printed:

     |__BLESSED OBJECT BELONGING TO CLASS: Statistics::PCA (2)  [ '->[18][2]' ]

However, you may be wish to continue the recursion into the object. This can be done by setting the C<unwrap_object>
option to "1" (defaults to "0"):     

     |  
     |__BLESSED OBJECT BELONGING TO CLASS: Statistics::PCA (3) ---RECURSING-INTO-OBJECT--- 
          |  
          |  
          |__HASH REFERENCE (3)
               |  

               etc.

Note: while the structure is indented further - the actual indentation level in parenthesis does not change - this is
just aids the identification of the type of data-type of the object within the structure. Also as yet, the C<notation>
option is not supported with the C<object_unwrap> option.

=head2 Method introspection for objects

You may additionally wish to introspect either the root structure or lower-level objects for their methods. This module
can use the introspection facility of Class::MOP and print a formated table by setting the C<object_methods> option to
"1" (as with C<lol> this temporarily breaks the tree structure):

     |__BLESSED OBJECT BELONGING TO CLASS: Statistics::PCA (3) ---RECURSING-INTO-OBJECT--- 
          |  
         --- 

 .-----------------------------------------------------.
 | Methods                                             |
 +-----------------------------------------------------+
 | Statistics::PCA::_deep_copy_references              |
 | Statistics::PCA::print_eigenvectors                 |
 | Statistics::PCA::_calculate_eigens_cephes           |
 | ...                                                 |
 '-----------------------------------------------------'

         --- 
          |  
          |__HASH REFERENCE (3)
               |  

               etc.

=cut

=head1 OPTIONS

All options are passed by hash reference:

    draw($data, {max_depth => 3, unwrap_objects => 1, object_methods => 1} );

=head2 array_limit

    Name:           array_limit
    Description:    Used in conjunction with long_array option. Specifies the cutoff point for printing an entire array of SCALARS and just first few example elements.
    Usage:          draw($data, {array_limit => 6});
    Values:         3-10.
    Default:        5.    

=head2 hash_key

    Name:           hash_key
    Description:    Allows printing of just those elements within a HASH of interest within a structure.
    Usage:          draw($data, {hash_key => q{a_key_name});
    Values:         String.     
    Default:        undef.

=head2 lol

    Name:           lol
    Description:    This option suppresses long-outputs given from Lists-of-Lists - see OVERVIEW.
    Usage:          draw($data, {lol => 2});
    Values:         0, 1, 2.
    Default:        0.

=head2 long_array

    Name:           long_array
    Description:    This option suppresses long-output from long arrays of SCALARS - see OVERVIEW.
    Usage:          draw($data, {long_array => 2});
    Values:         0, 1.
    Default:        0.


=head2 max_depth

    Name:           max_depth
    Description:    Specifies the maximum indentation/nesting depth to proceed to - see OVERVIEW.
    Usage:          draw($data, {max_depth => 6});
    Values:         0-10.
    Default:        10.

=head2 max_methods

    Name:           max_methods 
    Description:    Used in conjunction with the object_methods option. Specifies the maximum number of object methods to print.
    Usage:          draw($data, {max_methods => 6});
    Values:         1-100.
    Default:        50.    

=head2 min_depth

    Name:           min_depth
    Description:    Specifies the minimum indentation depth to start printing at - see OVERVIEW.
    Usage:          draw($data, {array_limit => 6});
    Values:         0-9.
    Default:        0.

=head2 notation

    Name:           notation
    Description:    This option enables or disables the automatic arrow "->" notation printing specifying how to dereference a particular entity within the structure.
    Usage:          draw($data, {notation => 0});
    Values:         0, 1.
    Default:        1.

=head2 object_methods

    Name:           object_methods
    Description:    Turns on object method introspection using the Class::MOP module.
    Usage:          draw($data, {object_methods => 1});
    Values:         0, 1.
    Default:        0.

=head2 spaces

    Name:           spaces
    Description:    This option enables and disables the printing of extra "branch" lines in the Tree structure for easier visualisation.
    Usage:          draw($data, {spaces => 0});
    Values:         0, 1.
    Default:        1.

=head2 unwrap_objects

    Name:           unwrap_objects
    Description:    This option causes the program to recurse into objects that fall within a data structure.
    Usage:          draw($data, {unwrap_objects => 1});
    Values:         0, 1.
    Default:        1.

=head2 borders

    Name:           borders - This option is not yet fully implemented.
    Description:
    Usage:          Disabled atm as not yet fully implemented.
    Values:         "0", "1".
    Default:        "0" (off).    

=cut

#=fe

#=fs Default Options HASH
my %options = ( _dev_1 => 0, # prints lots of per iteration info relating to previous iteration - i.e. print is called after - can´t recall the reason why?
                _dev_2 => 0, 
                _dev_3 => 0, 
                notation => 1,
                long_array => 0,
                array_limit => 5,
                lol => 0,
                hash_key => undef,
                spaces => 1,
                #y not quite done
                borders => 0,
                max_depth => 10,
                min_depth => 0,
                unwrap_objects => 0,
                object_methods => 0,
                max_methods => 50,
);
#=fe

#r purge all OLD and uncecessary vars!!!
#=fs Package Scoped Lexicals 
#y due to sheer lazyness rather than pass variables directly to subs or via object attributes i have used multiple lexcial variables with full package-scope. 
my $flag_hash_key = 0;
my $flag_hash_key_found = 0;
my $flag_max_exceeed = 0;
my $flag_recursion = 0;
my $flag_ref2ref = 0;
my $flag_root_object;
my @flag_HowTo;
my $flag_root = q{};
my $flag_lol = 0;
my $flag_object = 0;
my $flag_class;
my $flag_when = q{new};
my $last_thing;
my $flag_inc =0;
my $count = 1;
my %id;
my $last_name = q{};
my %ind;
my $indent = 0;
my $current_name; 
my $next_element = 0;
my $flag_ind_last = 0;
my $flag_ind_now = 0;
my @hor = ();
my $unit1 = q{     };
my $unit2 = q{  |__};
my $unit3 = q{  |  };
my $unit4 = q{ --- };
my $basic;
my $basic_plus;
my @flag_indent_record;
my $flag_dec = 0;
my $flag_all_scl_and_long;
my $scl_add;
my $flag_new_id;
my $flag_ind_next_iter;
my $flag_ind_current_iter;
my @IndArray;
my $lol;
my $current_struc;
my @root;
my $current;
my $flag_is_last;
my $flag_last = 0;
my $flag_long_struc;
my $flag_now;
my $flag_long_array = 0;
#=fe

#r atm objects are copied to new location to shield them...
sub draw {

    my $ref = shift;
   
    #y needs to be actual hash passed and not ref - otherwise you over-write the address and then loose everything in default
    my $options_h_ref = shift if $_[0]; # can use if @_ or do it before unpacking the rest... blah

    croak qq{\nArguments must be passed as HASH reference.} if ( ( $options_h_ref ) && ( ref $options_h_ref ne q{HASH} ) );

    &_check_options($options_h_ref) if $options_h_ref;

    #y THIS PUTS THE ORIGINAL VALUES IN AND THEN OVER-WRITES ONLY SPECIFICALLY PASSED VALUES - otherwise just have new passed values
    %options = (%options, %{$options_h_ref}) if $options_h_ref;

    #y $flag_ref2ref is actually disable notation printing flag!!!
    $flag_hash_key = 1 if (defined $options{hash_key});
    
    my ($package, $x, $line ) = caller;
    if (my $class = blessed $ref) { $ref = &_object_unwrap($ref, $class, $package); } # this needs to return the ref afterwards    

    $flag_recursion = 1;
   
    print qq{\nStarting print at depth $options{min_depth}.\n} if $options{min_depth} > 0;

    #y the recursion process
    &_recurse($ref);

    push @root, $unit1 if ( ( $flag_inc == 1 ) && ( $count != 2 ) );
    
    $flag_last = 1;
    
    #y last print message corresponding to last data recursion
    &_print if ($flag_ind_current_iter >= $options{min_depth} && $flag_hash_key == 0);

    #y print message if hash key given but not found
    print qq{\nHASH key \x27$options{hash_key}\x27 not found in nested data structure.} if ($flag_hash_key == 1 && $flag_hash_key_found == 0);
    print qq{\n\nHASH key \x27$options{hash_key}\x27 found $flag_hash_key_found times in nested data structure.} if ($flag_hash_key == 1 && $flag_hash_key_found != 0);
    
    &_clean;
}

sub _check_options {

    my $options_h_ref = shift;
    
    croak qq{\nOption \x27notation\x27 accepts values \x270\x27 and \x271\x27 only} 
      if ( ( exists $options_h_ref->{notation} ) && ( $options_h_ref->{notation} !~ /\A[01]\z/xms ) );

    croak qq{\nOption \x27long_array\x27 accepts values \x270\x27 and \x271\x27 only} 
      if ( ( exists $options_h_ref->{long_array} ) && ( $options_h_ref->{long_array} !~ /\A[01]\z/xms ) );

    croak qq{\nOption \x27array_limit\x27 accepts values numeric values between 3 and 10 only} 
      if ( ( exists $options_h_ref->{array_limit} ) && ( ( $options_h_ref->{array_limit} !~ /\A\d{1,2}\z/xms ) 
      || ($options_h_ref->{array_limit} < 3) || ($options_h_ref->{array_limit} > 10) ) );

    croak qq{\nOption \x27lol\x27 accepts values \x270\x27, \x271\x27 and \x272\x27 only} 
      if ( ( exists $options_h_ref->{lol} ) && ( $options_h_ref->{lol} !~ /\A[012]\z/xms ) );

    croak qq{\nOption \x27hash_key\x27 accepts values valid alphanumeric strings without spaces only (can include \x27_\x27)} 
      if ( ( exists $options_h_ref->{hash_key} ) && ( $options_h_ref->{hash_key} !~ /\A\w+\z/xms ) );

    croak qq{\nOption \x27min_depth\x27 accepts values numeric values between 0 and 10 only} 
      if ( ( exists $options_h_ref->{min_depth} ) && ( ( $options_h_ref->{min_depth} !~ /\A\d{1,2}\z/xms ) 
      || ($options_h_ref->{min_depth} < 0) || ($options_h_ref->{min_depth} > 9) ) );

    croak qq{\nOption \x27max_depth\x27 accepts values numeric values between 0 and 15 only} 
      if ( ( exists $options_h_ref->{max_depth} ) && ( ( $options_h_ref->{max_depth} !~ /\A\d{1,2}\z/xms ) 
      || ($options_h_ref->{max_depth} < 0) || ($options_h_ref->{max_depth} > 10) ) );
    
    croak qq{\nOption \x27borders\x27 has not yet been fully implemented - email dsth\@cantab.net if you would like it implemented} if (exists $options_h_ref->{borders});
    
    croak qq{\nOption \x27unwrap_objects\x27 accepts values \x270\x27 and \x271\x27 only} 
      if ( ( exists $options_h_ref->{unwrap_objects} ) && ( $options_h_ref->{unwrap_objects} !~ /\A[01]\z/xms ) );

    croak qq{\nOption \x27object_methods\x27 accepts values \x270\x27 and \x271\x27 only} 
      if ( ( exists $options_h_ref->{objects_methods} ) && ( $options_h_ref->{object_methods} !~ /\A[01]\z/xms ) );

    croak qq{\nOption \x27max_methods\x27 accepts values between \x271\x27 and \x27100\x27 only} 
      if ( ( exists $options_h_ref->{max_methods} ) && ( ( $options_h_ref->{max_methods} !~ /\A\d{1,3}\z/xms ) 
      || ($options_h_ref->{max_methods} < 1) || ($options_h_ref->{max_methods} > 100) ) );

}

sub _object_unwrap {

    my ($ref, $class, $package) = @_;
    
    my $reftype = reftype($ref);
    #y done in hurry - check?!? #\do { my $foo } and do { \my $foo },i #my $ref = \do{my $some_scalar};
    $flag_root_object = q{}.$ref;
    
    if ($reftype eq q{SCALAR}) { $ref = \do { my $ref} } 
    elsif ($reftype eq q{ARRAY}) { $ref = [@{$ref}] } 
    elsif ($reftype eq q{HASH}) { $ref = {%{$ref}} } 
    else { croak qq{\nWhat the heck are you giving me? } }
    
    print qq{\nMethod called from Package \x27$package\x27 on Blessed Object of type \x27$reftype\x27 and Class \x27$class\x27.\n} if $flag_recursion == 0;

    &_object_methods($class) if ($options{object_methods} == 1 && $flag_recursion == 0);

    # simplest way to find object data-type #e.g. poo=ARRAY(0x9ca92c8).
    return $ref;

}

sub _object_methods {

        my $class = shift;
        my $meta_obj = Class::MOP::Class->initialize($class);
        
        if ($meta_obj->get_all_methods) {
            
            my @methods = $meta_obj->get_all_methods;
            if (scalar @methods < $options{max_methods}) {
            # [ map { $_->fully_qualified_name } @methods]
            
            #y no point in doing this twice...
            my @method_names = map { $_->fully_qualified_name } @methods;
                
                my $t2 = Text::SimpleTable->new([&_array_max_length(\@method_names), qq{Methods}]);

                for my $method (@method_names) {

                    $t2->row($method);
                }
                
                #$t2->draw;
                print qq{\n}, $t2->draw;
            } 
            else { print qq{\nClass \x27$class\x27 has more than $options{max_methods} methods.\n} }
        }
        else { print qq{\nClass \x27$class\x27 has no methods.\n} }         
}

#r this is where we have the issues with notation - with BOTH ref and object recursion
sub _recurse { 
 

    my ($ref, $key) = @_;
    
    if ($count > 1)  {for my $i (0..$#flag_indent_record) { $root[$i] = $flag_indent_record[$i] > 0 ? $unit3 : $unit1; }}

    # min depth and hash_key
    #&_print if ( ( $count != 1 ) && ( $current ) );
    &_print if ( ( $count != 1 ) && ( $current ) && ($flag_ind_current_iter >= $options{min_depth}) && ($flag_hash_key == 0) );
    
    # rather than use an initialiser as in next line OR use exists in place of defined simply ADD extra conditions in if - i.e. if defined $key and $options{hash_key} to avoid useless use
    #$key ||= q{}; # key is used in string contect ´eq´ so give it false string - an initialiser to stop warning complaints
    #if ( ($key eq $options{hash_key}) && ($flag_hash_key == 1) ) {
    if ( (defined $key) && (defined $options{hash_key}) && ($key eq $options{hash_key}) && ($flag_hash_key == 1) ) {
        print qq{\n} if ($flag_hash_key_found > 0);
        print qq{\nHASH key \x27$key\x27 found and indentation level \x27$next_element\x27:\n};
        $flag_hash_key_found++;
        $flag_hash_key = 0;
    }
    
    if ( ($flag_dec == 1) && ($next_element < $options{min_depth}) && ($flag_hash_key == 0)) {
        print qq{\n\nIndent decrementing to \x27$next_element\x27 below min_depth level of \x27$options{min_depth}\x27};
        print qq{\n} if ($flag_hash_key_found == 0);
    }

    #r hash incrementation //////////////////////////////////////////////////////////////
    if ($key) { $flag_HowTo[$flag_ind_next_iter-1] = qq{\{$key\}} if $count > 1;    }

    #b REF incrementation ///////////////////////////////////////////////////////////////
    #   elsif (ref $ref eq q{REF}) {
    #    $flag_HowTo[$flag_ind_next_iter-1]++ if $count > 1;    
    #    print qq{\nreference};
    #    $flag_HowTo[$flag_ind_current_iter] = q{burpy} if $count > 1; }
    #r array incrementation /////////////////////////////////////////////////////////////
    else { $flag_HowTo[$flag_ind_next_iter-1]++ if $count > 1;    }
    
    &_adjust_indent;

    #y check reference type etc.
    &_if_elsif_ref($ref, $key);

}

#/ ANYHTING THAT RECURSES - whether over an array, a hash, or just a single step into a ref - NEEDS TO PASS THE KEY IN CASE OF HIGHER LEVEL HASHES - put in element?!?
sub _if_elsif_ref {
    
    my ($ref, $key) = @_;

    #y (1) max dpeth
    if ($next_element >= $options{max_depth}+1) { &_exceeds_depth($ref, $key) }
    
    #y (2) undefined ref - i.e. not a reference...
    #if (!ref $ref) { 
    elsif (!ref $ref) { &_type_ref_undef($ref, $key); } 

    #y (3) stupid handling - handing empty structure 
    #elsif ($current = _undefined($ref)) {}
    elsif (my $message = _undefined($ref)) {$current = qq{$message ($next_element) } }

    #y (4) check for cyclic references - i.e. having same value as root
    #elsif ( ( ref $ref eq q{ARRAY} || ref $ref eq q{HASH} ) && ( $ref eq $flag_root ) ) { $current = qq{CYCLIC REFERENCE: $ref} }
    elsif ( ( ( ref $ref eq q{ARRAY} || ref $ref eq q{HASH} ) && ( $ref eq $flag_root ) ) || $ref eq $flag_root_object ) { $current = qq{CYCLIC REFERENCE ($next_element)} }

    #y (5) LOLs
    # making lol and long_array separate
    #elsif ( ( ref $ref eq q{ARRAY} ) && ( $options{long_array} < 0 ) && ( scalar @{$ref} > 1 ) && ( &array_lol_test($ref) == 1 ) ) {
    elsif ( ( ref $ref eq q{ARRAY} ) && ( $options{lol} > 0 ) && ( scalar @{$ref} > 1 ) && ( &_array_lol_test($ref) == 1 ) ) { &_type_ref_lol($ref, $key); }

    #y (6) Scalar only arrays
    # do everything as usual with an array - EXCEPT we don´t recurse
    # making lol and long_array separate
    #elsif ( ( ref $ref eq q{ARRAY} ) && ( &array_all_scl_test($ref) ) && ( scalar @{$ref} > 1 ) && ( $options{long_array} > 0) ) {
    elsif ( ( ref $ref eq q{ARRAY} ) && ( &_array_all_scl_test($ref) ) && ( scalar @{$ref} > 1 ) && ($options{long_array} == 1) ) { &_type_ref_array_of_scalars($ref, $key); }

    #y (7) standard arrays
    elsif (ref $ref eq q{ARRAY} ) { 
        #/ atm using for to loop through array instead of map that re-allocates memory - only the last statement is relevant for recursion
        for my $i (@$ref) { 
            &_type_array($ref, $key);
            &_recurse($i)}; 
    } 

    #y (8) hash
    elsif (ref $ref eq q{HASH} )  { 
        for my $i (keys %{$ref}) { 
            #/ need to account for nested hashes - i.e. must always pass key if it exists
            #&_type_hash($ref);
            &_type_array($ref, $key);
            &_recurse($ref->{$i}, $i)
        }; 
            #$_ => recurse($ref->{$_}) } (keys %{$ref})    }; 
            #$_ => _deep_copy_references($ref->{$_}) } @keys  }; 
    } 
    
    #y (9) object
    elsif (my $class = blessed $ref) { 
        if ($options{unwrap_objects} == 0) { $current = qq{BLESSED OBJECT BELONGING TO CLASS: $class ($next_element) }; }
        #/ here we need to return the unwrapped object and give recursion
        else { &_object_recursion($ref, $key, $class) }
    }

    #y (10) REF
    elsif (ref $ref eq q{REF}) {
        &_type_ref2ref($ref, $key);
        &_recurse(${$ref});
    }

    #y (11) code ref
    elsif (ref $ref eq q{CODE}) { $current = qq{CODE REFERENCE: $ref ($next_element) } }

    #y (12) glob
    elsif (ref $ref eq q{GLOB}) { $current = qq{GLOB REFERENCE: $ref ($next_element) } }
   

    #y (13) stupid handling - handling ref2refs to scalars will need the same treatement as references i.e. need to recurse
    # this only happens if you´ve been handled a ref2ref with sclar wrapped inside - don´t need the undef part - was done in stupidity 1 
    elsif (ref $ref eq q{SCALAR}){
        &_type_array($ref, $key);
        &_recurse(${$ref});
    }

    #y (14) kill routine
    else { die "what type is $ref?" }
}

sub _exceeds_depth {
    # doesn´t actually use $key - is this an f´up?!?
    my ($ref, $key) = @_;
    $flag_ref2ref = 1;
    my $message = qq{EXCEEDS MAX NESTING DEPTH ($next_element)};

    my $thing ; #   = blessed $ref      ?    qq{OBJECT}
    
    #my $thing    = blessed $ref      ?    qq{OBJECT}
    #             : ref $ref          ?    ref $ref, q{ REFERENCE}
    #            : ref \$ref         ?    ref \$ref
    #            :                        q{};
    
    if (my $class = blessed $ref) { $thing = qq{OBJECT OF CLASS \x27$class\x27} }
    elsif (ref $ref eq q{REF}) { $thing = qq{REFERENCE-TO-REFERENCE} }
    elsif (my $ref_type = ref $ref) { $thing = qq{$ref_type REFERENCE} }
    else { my $data_type = ref \$ref; $thing = qq{$data_type} }

    $current  = qq{$thing $message};
}  

sub _type_ref_undef {

    my ($ref, $key) = @_;

    $flag_now = q{s};

            #y we know its a scalar...
    my $ref_type = ref \$ref;
    if ($key) { $current = qq{\x27$key\x27=>$ref_type = \x27$ref\x27 ($next_element) }; }
    elsif (!defined $ref) { $current = qq{$ref_type = \x27undefined value\x27 ($next_element) }; }
    elsif ($ref eq q{}) { $current = qq{$ref_type = \x27$ref\x27 [EMPTY STRING] ($next_element) }; }
    else { $current = qq{$ref_type = \x27$ref\x27 ($next_element) }; }

    $last_thing = $ref;

    my $len = scalar @flag_HowTo;

    # twat len won´t change as its not part of loop
    #while ($len > $next_element) { pop @flag_HowTo }
    while (scalar @flag_HowTo  > $next_element) { pop @flag_HowTo }

}

sub _type_ref_lol {
    
            my ($ref, $key) = @_;
            
            &_flags($ref); 
            #y can´t be bothered to pass long as an arguement - just flick a flag
            $flag_lol = 1;
            &_new_detection($ref, $key);
            &_more_flags($ref);
            #/ probably ought to copy it
            $lol = [@{$ref}];

}

sub _type_ref_array_of_scalars {

            my ($ref, $key) = @_;
            &_flags($ref); 
            $flag_long_array = 1;
            &_new_detection($ref, $key);
            &_more_flags($ref);
}

sub _type_array {

    my ($ref, $key) = @_;
    &_flags($ref); 
    &_new_detection($ref, $key);
    &_more_flags($ref);
}

# only diff with _type_ref2ref is that is turns a flag to turn off notation - until fixed
sub _type_ref2ref {

    my ($ref, $key) = @_;
    $flag_ref2ref = 1;
    &_flags($ref); 
    &_new_detection($ref,$key);
    &_more_flags($ref);
}

sub _object_recursion { 

    my ($ref, $key, $class) = @_;
    &_type_array($ref, $key);
    $current = qq{BLESSED OBJECT BELONGING TO CLASS: $class ($next_element) ---RECURSING-INTO-OBJECT--- };
    #y use the ref2ref thing to also turn off notation here
    $flag_ref2ref = 1;
    $flag_object = 1;
    &_flags($ref); 
    &_new_detection($ref,$key);
    &_more_flags($ref);
    my ($package, $x, $line ) = caller;
    $flag_class = $class;    
    &_recurse(&_object_unwrap($ref, $class, $package));

}

sub _print {

    #r TWAT modification of globals w/o localising!!!
    #$" = undef;
    #local $, = undef; # not used - in no case is a list out of interpolation context
    # we give it a value to stop warnings complaining about use of unitialised variable
    local $" = q{};
    
    print qq{\n@IndArray$current};
    
    if ( $flag_now eq q{a} && $options{borders} == 1 ) {
        print qq{\n@{root}} if $options{spaces} == 1 ;
        print qq{\n@{root}[} 
    }

    if ($options{_dev_2} == 1) { local $" = q{--}; print qq{ (array: @flag_indent_record - last ele $#flag_indent_record current ind $flag_ind_current_iter)}; }

    if ($options{notation} == 1 && $count > 2 && $flag_ref2ref == 0) { 
        my $stringify = join q{][}, @flag_HowTo;
        #my $stringify = qq{\x27->[$stringify]\x27 };
        $stringify = qq{\x27->[$stringify]\x27 };
        $stringify =~ s/\[-1\]\'\s\z/\' /xms;
        #y need to recusre for this one - i.e. either return a list of use while with g? y no, no, no - this is a substitution - just use g flag
        #$stringify =~ s/\[\{(.+)\}\]/\{\1\}/xms;
        
        # change to hash notation
        #y what it needs to be is NONE-greedy!!!
        #$stringify =~ s/\[\{(.+?)\}\]/\{\1\}/xmsg;
        $stringify =~ s/\[\{(.+?)\}\]/\{$1\}/xmsg;
        
            #while ($stringify =~ s/(.*?)\[burpy\]/\$ \1\2/msg);
            #y don´t use while with global ´g´ twat
            #while ($stringify =~ s/\[burpy\]//xmsg) { $stringify = q{$}.$stringify };

            #while ($stringify =~ s/\[burpy\]//xms) { $stringify = q{$}.$stringify };
            #$stringify =~ s/(\$.*)\'->(.+)/\'\1\' and \'->\2/ms;

        print qq{ [ $stringify]}; }
    
    print qq{ - flag_inc = $flag_inc, flag_dec = $flag_dec, flag_new_id = $flag_new_id, }
    . qq{flag_ind_current_iter = $flag_ind_current_iter, flag_ind_next_iter = $flag_ind_next_iter, }
    . qq{count = $count} if ( $options{_dev_1} == 1);

    if ($flag_dec == 1) { 
        for my $n ($flag_ind_next_iter+1..$flag_ind_current_iter) { 
            #b make it easier to visualise - this will be activated by an option
            if ($options{borders} == 1) {
                print qq{\n@{root}} if $options{spaces} == 1;
                print qq{\n@{root}]} if $flag_dec == 1;
            }
            pop @root ;
        } 
    }

    #/ making lol and long_array separate
    #&_print_lol if ( ( $flag_lol == 1 ) && ( $options{long_array} == -2 ) );
    &_print_lol if ( ( $flag_lol == 1 ) && ( $options{lol} == 2 ) );

    if ($options{object_methods} == 1 && $flag_object == 1) {
        my @copy = @root;
        if ( ($options{spaces} == 1) && (!$flag_last) ) {
            print qq{\n@{root}};
            for (@copy) { $_ = $unit4 if $_ eq $unit3 }
            print qq{\n@copy\n};
        }
        &_object_methods($flag_class); 
        print qq{\n@copy};
    }
    
    #b make it easier to visualise - this will be activated by an option
    print qq{\n@{root}} if ( ($options{spaces} == 1) && (!$flag_last) );
    
    $current = 0;
}

sub _print_lol {
    my $rows = scalar @{$lol};
    my $col_max = &_lol_max_columns($lol);
    my $length_max = &_lol_max_length($lol);
    
    my @config_full = ( [8, q{}] );
    #y column calculations...
    my @config = map { [ $length_max+2, qq{..[$_]} ] } (0..$col_max-1);
    push @config_full, @config;

    my $t2 = Text::SimpleTable->new(@config_full);
    
    #y don´t want annoying text-simple error messages so we give values to all!
    #for my $r (0..$#{$lol}) { 
    for my $r (0..$rows-1) { 
        #y this must be lexical and within first loop...
        my @row;
        #for my $c (0..$#{$lol->[$r]}) { 
        for my $c (0..$col_max-1) { 
            #$lol->[$r][$c] ||= q{---};
            if ( $lol->[$r][$c] ) { push @row, qq{\x27$lol->[$r][$c]\x27} }
            else { push @row, q{---} }
        } 
        $t2->row( qq{..[$r]..} , @row );
    } 
    my @copy = @root;
    if ( ($options{spaces} == 1) && (!$flag_last) ) {
        print qq{\n@{root}};
        for (@copy) { $_ = $unit4 if $_ eq $unit3 }
        print qq{\n@copy};

    }
    print qq{\n\n}, $t2->draw;
    print qq{\n@copy};
}

sub _undefined {
    my $ref = shift;
    if      ( (ref $ref eq q{SCALAR} ) && ( !defined ${$ref} ) ) { return q{UNDEFINED SCALAR REFERENCE}; } 
    elsif   ( (ref $ref eq q{ARRAY}  ) && ( !defined @{$ref} ) ) { return q{UNDEFINED ARRAY REFERENCE};  } 
    elsif   ( (ref $ref eq q{HASH}   ) && ( !defined %{$ref} ) ) { return q{UNDEFINED HASH REFERENCE};   }
    else                                                         { return 0; }
}

sub _flags {
    
    my  $ref  = shift;

    # current iteration indent flag: flag_ind_current_iter - just set it to next_element
    $flag_ind_current_iter = $next_element;

    $current_name = q{}.$ref;
    $current_struc = $ref;

    #y INCREMENT: new ref-id AND different to last iteration: flag_inc
    # set flag back to proper state
    $flag_inc = 0;
    if ( ( $last_name ne $current_name) && (  !exists $id{$ref} ) ) {
        $flag_inc = 1;
        $indent++;
    };

    #y DECREMENT: old ref-id AND different to last iteraction: flag_dec
    $flag_dec = 0;
    if ( ( $last_name ne $current_name) && (  exists $id{$ref} ) ) {
        $indent--;
        $flag_dec = 1;
    };

    #y new ref-id -  create flag and set: flag_new_id
    $flag_new_id = 0;
    if ( !exists $id{$ref} ) {
    $ind{$ref} = $indent ;
    $flag_new_id = 1;
        }

    #y RESET ON DESCEND - i.e. may drop more than one level - this means re-setting the value?!? if seen before need to reset the level to that - i.e. 
    # we set values as we climb - then as we descend we get them back out
    if (exists $ind{$ref}) { $indent = $ind{$ref} }
    $flag_ind_now = $indent;

}

#r this is second place of notation issues
sub _new_detection {

    my ($ref, $key) = @_;

    #y HERE WE HAVE NEW ARRAY DETECTION - we actually use increment to detect it and not new array!?!
    $flag_long_struc = 0;
    if ( $flag_inc == 1 && $flag_when eq q{new} ) {
        if (ref $ref eq q{ARRAY}) {
            $flag_long_struc = 1 if (scalar @{$ref} > 1);
            $flag_indent_record[$flag_ind_current_iter] = scalar @{$ref};
        }
        elsif (ref $ref eq q{HASH}) {
            $flag_long_struc = 1 if (scalar (keys %{$ref}) > 1);
            $flag_indent_record[$flag_ind_current_iter] = scalar (keys %{$ref});
        }
        elsif (ref $ref eq q{REF} || ref $ref eq q{SCALAR} || blessed $ref) {
            #$flag_long_struc = 1 if (scalar (keys %{$ref}) > 1);
            #$flag_length{$ref} = scalar (keys %{$ref});
            $flag_indent_record[$flag_ind_current_iter] = 1;
            #$flag_max_exceeed = 0;
        }

    #/ will abolish by using $element?!? - as with $key
    #y initialise a structure: -1 is ignored on printing but also means that y by incrementing we have 0... with all subdata entries
    $flag_HowTo[$flag_ind_current_iter] = -1;
    #$flag_HowTo[$flag_ind_current_iter] = -1 if (!(blessed $ref));
    #$flag_HowTo[$flag_ind_current_iter] = -1 if (ref $ref ne q{REF});

    my $ref_type = ref $ref;

    #y if hash prepend key
    my $start = ($key) ? qq{\x27$key\x27=>} : qq{}; # this always gets put in - just is generally empty

    #y if list-of-scalars of list-of-lists append appropriate info
    
    #y making lol and long_array seaparate
    #my $end         =  ($flag_lol == 1 && $options{long_array} < 0 )           ?   &_array_ending($ref,1)       # $ending($ref,1) #$end_c_ref->($ref, 1) 
    my $end         =  ($flag_lol == 1 && $options{lol} > 0 )                   ?   &_array_ending($ref,1)       # $ending($ref,1) #$end_c_ref->($ref, 1) 
                    :  ($flag_long_array == 1 && $options{long_array} == 1)     ?   &_array_ending($ref,0)
                    :                                                               q{};
                    
    #y the basic info for all but REF
    my $middle = ($ref_type eq q{REF}) ? q{REFERENCE-TO-REFERENCE} : qq{$ref_type REFERENCE};
    $current = qq{${start}$middle ($next_element)$end}; 

    #b set here as the sub iterates multiple times through an array - we only change it back under these circumstances
    $flag_now = q{a} ;
    
    $flag_root = q{}.$ref if $count <= 2;

    }
}

sub _array_ending { 

    my ($ref, $which) = @_;
    my $rows = scalar @{$ref};
    my $end;
    #y this is a LoL
    if ($which) {
        my $col_max = &_lol_max_columns($ref);
        $end = qq{ ---LIST OF LISTS--- [ rows = $rows and longest nested list length = $col_max ]};
    }
    #y this is a long Array of scalars
    else {
        local $" = q{, }; 
        $end = $rows < $options{array_limit}+1 ? qq{ ---LONG_LIST_OF_SCALARS--- [ length = $rows ]: @{$ref}} : qq{ ---LONG_LIST_OF_SCALARS--- [ length = $rows ] e.g. 0..2:  @{$ref}[0..2]};
    }    
    return $end;
}

# incrementation of indent happens here - with $next_element = $ind{$ref}; - $flag_ind_current_iter is simply this value for ease of use
# however they are updated in different places!!! so for short periods are different. $flag_ind_next_iter also same again update at different point
sub _more_flags {

    my  $ref  = shift;
    $id{q{}.$ref} = 1;
    #y set next_element to the next iterations value
    $next_element = $ind{$ref};
    $flag_ind_next_iter = $next_element;
    $flag_ind_last = $indent;
    $last_name = q{}.$ref; 

}

# just the same lengh for all atm - should really iterate through columns - i.e. reverse r and c or take transpose...
sub _lol_max_length {
    my $max = 0;
    my $temp = shift;
    for my $r (@{$lol}) { 
        for my $val (@{$r}) {
            $max = length $val if ( length $val > $max) 
        }
    }
    return $max;
}

sub _array_max_length {
    my $max = 0;
    my $temp = shift;
    for my $i (@{$temp}) { 
        $max = length $i if ( length $i > $max) 
    }
    return $max;
}

sub _lol_max_columns {
    my $temp = shift;
    my @lol_lengths = map { scalar @{$_} } @{$temp};
    my $max = shift @lol_lengths;
    for (@lol_lengths) { $max = $_ if ($_ > $max) }
    return $max;
}

sub _adjust_indent {
    
    #y HACK TO FIX LONG ARRAY ALIGNMENT BUG - just removed -1 for each element index
    if ( ( $count > 2 ) && ( ( $flag_long_array == 1 ) || ( $flag_lol == 1 ) ) ) {
        for my $i (0..$#flag_indent_record) { $IndArray[$i] = $flag_indent_record[$i] > 0 ? $unit3 : $unit1; }
        $IndArray[$flag_ind_next_iter] = $unit2;
    }
    #y moved here to allow us to use it to fix the strange indent problem - without recursion?!?
    $flag_long_array = 0;
    #y wipe used vars
    $lol = undef;
    $flag_lol = 0;
    $flag_class = undef;
    $flag_object = 0;

    #y decrement the actual array holding the branch numbers 
    $flag_indent_record[$flag_ind_next_iter-1]-- if $count > 1;    

    $count++;
    $current = 0;

    #b remove old excess parts of the array - i.e. it should never have more entries than the current indent level
    # this is where we use decrement to reset things - i.e. ref2ref -i.e. printing!?!
    if ($count > 2 && $flag_dec == 1 ) {
            local $" = q{-};
        while( scalar @flag_indent_record > $flag_ind_next_iter) { pop @flag_indent_record; }
        #while (scalar @flag_HowTo  > $next_element) { pop @flag_HowTo }
        # while( $#flag_HowTo > $flag_ind_next_iter) { 
        while( scalar @flag_HowTo > $flag_ind_next_iter) { pop @flag_HowTo; }

        #y turn notation back on
        $flag_ref2ref = 0;
        #y turn printing back off
        $flag_hash_key = 1 if (defined $options{hash_key});
    }

    if ($count > 2) {for my $i (0..$#flag_indent_record-1) { $IndArray[$i] = $flag_indent_record[$i] > 0 ? $unit3 : $unit1; } }

    #y this is the thing chnaging - i.e. indenting so we have the hook - root/branch together
    $IndArray[$flag_ind_next_iter-1] = $unit2 if $count > 2;

    #y when decrementing we remove old extra levels of indentation in the printing array
    if ($flag_dec == 1) { for my $n ($flag_ind_next_iter+1..$flag_ind_current_iter) { pop @IndArray  } }

}

sub _array_lol_test {
    my $ref = shift;
    for my $i (@{$ref}) { return 0 if ( ( ref $i ne q{ARRAY} ) || ( !_array_all_scl_test($i) ) ); }
    return 1;
}

sub _array_all_scl_test {
    my $ref = shift;
    return 0 if scalar (@{$ref}) < 2;
    for my $i (@{$ref}) { return 0 if ( ref \$i ne q{SCALAR} ); }
    return 1;
}

sub _clean {

    my @list = ($flag_root_object, $flag_class, $last_thing, $current_name, $basic, $basic_plus, $flag_all_scl_and_long, $scl_add,
    $flag_new_id, $flag_ind_next_iter, $flag_ind_current_iter, $lol, $current_struc, $current, $flag_is_last, $flag_long_struc, $flag_now);

    for (@list) { undef $_ }

    undef %id;
    undef %ind;
    undef @flag_HowTo;
    undef @hor;
    undef @flag_indent_record;
    undef @IndArray;
    undef @root;

    $flag_hash_key = 0;
    $flag_hash_key_found = 0;
    $flag_max_exceeed = 0;
    $flag_recursion = 0;
    $flag_ref2ref = 0;
    $flag_root = q{};
    $flag_lol = 0;
    $flag_object = 0;
    $flag_when = q{new};
    $flag_inc = 0;
    $count = 1;
    $last_name = q{};
    $indent = 0;
    $next_element = 0;
    $flag_ind_last = 0;
    $flag_ind_now = 0;
    $flag_dec = 0;
    $flag_last = 0;
    $flag_long_array = 0;

    return;
}

1; # Magic true value required at end of module

#=fs notes/todo
#/ $next_element is indentation from last iteration - it is cached at next and current for comparison and $contents is the print from the last iteration

#r/ finish border printing option - should only be active with arrays and hashes and should detect the type

#/ the incrementer - shoouldn´t increment - as with key it should put the atual element position in e.g. pass on $element value

#/ with object recursion - the number () doesn´t change as the first round it is simply the object type - possibly change this?!? so put it on the first line with type...

#/ any change based on if flag_dec == 1 should really specify a requirement on the next iteration depth - e.g. if min_depth >0 AND if decrementing to below it put in break

#/ eventually pass $element with key - and use that to assign array position - instead of incrementing - probably always gives same result, but anyway is a extra check

#r put in an option for max table printing length?!? with lol == 2

#y (1) [ map 
#y (2) ( map 
#y (3) for my $i (@{$ref})                              { stuff; _deep_copy_references($i) }

#y (1) _deep_copy_references($_) } @{$ref} ]; 
#y (2) _deep_copy_references($i)}; 
#=fe

__END__

=head1 DEPENDENCIES

Scalar::Util        => "1.22", 
Class::MOP          => "0.95",
Text::SimpleTable   => "2.0",
Carp                => "1.08",

=cut

=head1 AUTHOR

Daniel S. T. Hughes  C<< <dsth@cantab.net> >>

=cut

=head1 SEE ASLO

L<Data::Dumper>, L<Data::TreeDumper>.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Daniel S. T. Hughes C<< <dsth@cantab.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

=head1 DISCLAIMER OF WARRANTY

because this software is licensed free of charge, there is no warranty
for the software, to the extent permitted by applicable law. Except when
otherwise stated in writing the copyright holders and/or other parties
provide the software "as is" without warranty of any kind, either
expressed or implied, including, but not limited to, the implied
warranties of merchantability and fitness for a particular purpose. The
entire risk as to the quality and performance of the software is with
you. Should the software prove defective, you assume the cost of all
necessary servicing, repair, or correction.

In no event unless required by applicable law or agreed to in writing
will any copyright holder, or any other party who may modify and/or
redistribute the software as permitted by the above licence, be
liable to you for damages, including any general, special, incidental,
or consequential damages arising out of the use or inability to use
the software (including but not limited to loss of data or data being
rendered inaccurate or losses sustained by you or third parties or a
failure of the software to operate with any other software), even if
such holder or other party has been advised of the possibility of
such damages.

=cut

