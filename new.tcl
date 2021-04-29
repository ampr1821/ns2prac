set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(nn)           6                        ;# number of mobilenodes
set val(rp)           AODV                     ;# routing protocol
set val(x)            800
set val(y)            800

set ns [new Simulator]
#ns-random 0

set f [open out.tr w]
$ns trace-all $f
set namtrace [open out.nam w]
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid 800 800

create-god $val(nn)

set chan_1 [new $val(chan)]

$ns node-config  -adhocRouting $val(rp) \
          -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 #-channelType $val(chan) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace OFF \
                 -channel $chan_1

proc finish {} {
    global ns namtrace
    $ns flush-trace
        close $namtrace
        exec nam -r 5m out.nam &
    exit 0
}

for {set i 0} {$i < 10} {incr i} {
	global ns
	set node($i) [$ns node]
	set sink($i) [new Agent/LossMonitor]
	set tcp($i) [new Agent/TCP]
	$ns attach-agent $node($i) $sink($i)
	$ns attach-agent $node($i) $tcp($i)
	$ns initial_node_pos $node($i) 30
}

$ns at 0.0 "$node(0) setdest 50.0 750.0 3000.0"
$ns at 0.0 "$node(1) setdest 70.0 695.0 3000.0"
$ns at 0.0 "$node(2) setdest 115.0 735.0 3000.0"
$ns at 0.0 "$node(3) setdest 135.0 675.0 3000.0"
$ns at 0.0 "$node(4) setdest 125.0 620.0 3000.0"
$ns at 0.0 "$node(5) setdest 200.0 665.0 3000.0"
$ns at 0.0 "$node(6) setdest 240.0 605.0 3000.0"
$ns at 0.0 "$node(7) setdest 260.0 545.0 3000.0"
$ns at 0.0 "$node(8) setdest 305.0 595.0 3000.0"
$ns at 0.0 "$node(9) setdest 330.0 535.0 3000.0"

set cbr [new Agent/CBR]
$ns attach-agent $node(0) $cbr
$cbr set packetSize_ 1000
$cbr set interval_ 0.030
$ns connect $cbr $sink(9)

$ns at 0.5 "$cbr start"
$ns at 10.0 "finish"

$ns run
