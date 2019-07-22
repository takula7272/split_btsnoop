#!/usr/bin/perl

print "Input btsnoop file name:\n";
chomp(my $file_name=<STDIN>);
print "Input byte size (MB):\n";
chomp(my $byte_size=<STDIN>);
$byte_size = $byte_size*1024*1024;

print "Start split $file_name.....\n";

my $i=0;
my $j=$byte_size;
$header_size=16;
$time_size=24;
$cmdtype="\x01";
$eventtype="\x04";
$datatype="\x02";

open(FH, "<$file_name".".cfa") or die "cannot create file $filename: $!";
binmode(FH);
read(FH, $header, $header_size);

while (!eof FH){
    $new_file="$file_name$i.cfa";
    open(OUT, ">$new_file") or die "cannot create file $filename: $!";
    binmode(OUT);
    print "Output to $new_file.....\n";
    print OUT $header;
    $j=$byte_size;
    while($j ge 0 && (!eof FH)){      
        read(FH, $time, $time_size);
        print OUT $time;
        read(FH, $type, 1);
        print OUT $type;
        $j=$j-$time_size-1;
        if ($type eq $cmdtype){
            read(FH, $opcode, 2);
            print OUT $opcode;
            $j -=2;
            read(FH, $length, 1);
            print OUT $length;
            $dec = sprintf('%d', ord($length));
        }
        if ($type eq $datatype){
            read(FH, $opcode, 2);
            print OUT $opcode;
            $j -=2;
            read(FH, $lengthlow, 1);
            read(FH, $lengthhi, 1);
            print OUT $lengthlow;
            print OUT $lengthhi;
            $dec=sprintf('%d', ord($lengthhi))*256+sprintf('%d', ord($lengthlow));
        }
        if ($type eq $eventtype){
            read(FH, $opcode, 1);
            print OUT $opcode;
            $j -=1;
            read(FH, $length, 1);
            print OUT $length;
            $dec = sprintf('%d', ord($length));
        }
        if ($dec ne 0) {
            read(FH, $data, $dec);
            print OUT $data;
            $j = $j - $dec;
        }
    }
    $i++;
    close(OUT);
}


close(FH);
close(OUT);

