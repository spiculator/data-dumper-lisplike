sub dumplisp_scalar($) {
	1 == @_ or die;
	my $scalar = shift;
	check_defined_scalar $scalar;
	return( $scalar =~ /^[\w\-%:,\!=]+$/ ? $scalar : "'$scalar'" );
}
sub dumplisp_iter($;$$);
sub dumplisp_iter($;$$) {
	1 == @_ or 2 == @_ or 3 == @_ or die;
	my ($lisp, $level, $maxlength) = @_;
	$level ||= 0;
	$maxlength = 60 unless defined $maxlength;
	my $simple = ( $level < 0 );
	my $indent = "    ";
	if( not defined $lisp ) {
		die;
	} elsif( not ref $lisp ) {
		my $out = $simple ? "" : "\n" . ( $indent x $level );
		$out .= dumplisp_scalar $lisp;
		die if length $out > $maxlength;
		return $out;
	} elsif( 'ARRAY' eq ref $lisp ) {
		my $out = $simple ? "" : "\n" . ( $indent x $level );
		die if $simple and length $out > $maxlength;
		my @l = @$lisp;
		my $first = 1;
		if( not @l ) {
			$out .= "(";
		} elsif( $simple ) {
			$out .= "(";
			foreach my $current ( @l ) {
				$out .= " " unless $first;
				undef $first;
				$out .= dumplisp_iter( $current, -1, $maxlength - length $out );
				die if $simple and length $out > $maxlength;
			}
		} else { # not $simple and @l not empty
			my $try_add = eval {
				dumplisp_iter( $lisp, -1, $maxlength - length $out );
			};
			if( defined $try_add ) {
				my $try_out = $out . $try_add;
				return $try_out if length $try_out <= $maxlength;
			}
			$out .= "(" . dumplisp_scalar shift @l;
			$out .= dumplisp_iter( $_, $level + 1 ) foreach @l;
		}
		$out .= ")";
		die if $simple and length $out > $maxlength;
		return $out;
	} else {
		die;
	}
}
sub dumplisp($) {
	my $out = dumplisp_iter shift;
	chomp $out;
	$out =~ s/^\n//;
	return "$out\n";
}

