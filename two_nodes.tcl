set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 250
$cbr1 set interval_ 0.006
$cbr1 attach-agent $udp1

set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

set null1 [new Agent/Null]
$ns attach-agent $n0 $null1

$ns connect $udp0 $null0
$ns connect $udp1 $null1

$ns at 0.5 "$cbr0 start"
$ns at 2.5 "$cbr0 stop"
$ns at 2.6 "$cbr1 start"
$ns at 4.5 "$cbr1 stop"

$ns at 5.0 "finish"

$ns run
