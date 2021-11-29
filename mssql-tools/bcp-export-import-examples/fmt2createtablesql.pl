#!/usr/bin/perl

# example file format
# 14.0
# 14
# 1       SQLNCHAR            8       0       ""   1     PolicyKey                                                                            SQL_Latin1_General_CP1_CI_AS
# 2       SQLDATETIME         1       8       ""   2     StartDate                                                                            ""
# 3       SQLDATETIME         1       8       ""   3     LoadDate                                                                             ""
# 4       SQLNCHAR            8       0       ""   4     PartyKey                                                                             SQL_Latin1_General_CP1_CI_AS
# 5       SQLNCHAR            8       0       ""   5     FullName                                                                             SQL_Latin1_General_CP1_CI_AS
# 6       SQLNCHAR            8       0       ""   6     Phone                                                                                SQL_Latin1_General_CP1_CI_AS
# 7       SQLNCHAR            8       0       ""   7     BrokerCode                                                                           SQL_Latin1_General_CP1_CI_AS
# 8       SQLNCHAR            8       0       ""   8     BrokerUAGCode                                                                        SQL_Latin1_General_CP1_CI_AS
# 9       SQLNCHAR            8       0       ""   9     HASH_CODE_DeltaLake                                                                  SQL_Latin1_General_CP1_CI_AS
# 10      SQLDATETIME         1       8       ""   10    LOAD_ID_DeltaLake                                                                    ""
# 11      SQLBIT              1       1       ""   11    IS_CURRENT_DeltaLake                                                                 ""
# 12      SQLDATETIME         1       8       ""   12    VALID_FROM_DeltaLake                                                                 ""
# 13      SQLDATETIME         1       8       ""   13    VALID_TO_DeltaLake                                                                   ""
# 14      SQLNCHAR            8       0       ""   14    BK_DeltaLake                                                                         SQL_Latin1_General_CP1_CI_AS

my $file = shift;

open(HIN, "<$file") || die "couldn't open $file: $!";
my @contents = <HIN>;
close(HIN);

# discard the first 2 lines
shift @contents;
shift @contents;

my @rowDefs = ();

foreach my $line (@contents)
{
    chomp($line);
    #print "[$line]\n";
    my ($row, $type, $prelen, $na, $na2, $row2, $name) = split(' ', $line);
    if (($type eq "SQLNCHAR")&&($prelen == 8))
    {
        push(@rowDefs, "$name nvarchar(max)");
    }
    elsif ($type eq "SQLDATETIME")
    {
        push(@rowDefs, "$name DATETIME");
    }
    elsif ($type eq "SQLBIT")
    {
        push(@rowDefs, "$name BIT");
    }
    else
    {
        die "unknown type for this row [$row][$type][$prelen][$name]\n";
    }
}

my $table = substr($file, 0, length($file)-4);
print "create table $table (\n";
my $numDefs = $#rowDefs;
foreach my $rowDef (@rowDefs)
{
    if ($numDefs-- > 0)
    {
        print "$rowDef,\n";
    }
    else
    {
        print "$rowDef\n";
    }
}
print ");\n";