#Filename: sample18.tcl

#*******************SENSOR NETWORK ************************

#*********************ENERGY MODEL *********************88
#************Multiple node Creation and communication model using

#UDP (User Datagram Protocol)and CBR (Constant Bit Rate)
#***************************88
# Simulator Instance Creation
set ns [new Simulator]

#Fixing the co-ordinate of simulation area
set val(x) 800
set val(y) 800
# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif1) Phy/WirelessPhy ;# network interface type
set val(netif2) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 3 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 600 ;# X dimension of topography
set val(y) 600 ;# Y dimension of topography
set val(stop) 10.0 ;# time of simulation end
set val(energymodel) EnergyModel ;#Energy set up
# set up topography object
set f [open out.tr w]
$ns trace-all $f
set namtrace [open out.nam w]
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# general operational descriptor- storing the hop details in the network
create-god $val(nn)

#Transmission range setup

#********************************** UNITY GAIN, 1.5m HEIGHT OMNI DIRECTIONAL ANTENNA SET UP **************

Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

#********************************** SET UP COMMUNICATION AND SENSING RANGE ***********************************

#default communication range 250m

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
$val(netif1) set CPThresh_ 10.0
$val(netif1) set CSThresh_ 2.28289e-11 ;#sensing range of 500m
$val(netif1) set RXThresh_ 2.28289e-11 ;#communication range of 500m
$val(netif1) set Rb_ 2*1e6
$val(netif1) set Pt_ 0.2818
$val(netif1) set freq_ 914e+6
$val(netif1) set L_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
$val(netif2) set CPThresh_ 10.0
$val(netif2) set CSThresh_ 8.91754e-10 ;#sensing range of 200m
$val(netif2) set RXThresh_ 8.91754e-10 ;#communication range of 200m
$val(netif2) set Rb_ 2*1e6
$val(netif2) set Pt_ 0.2818
$val(netif2) set freq_ 914e+6
$val(netif2) set L_ 1.0

# configure the first 5 nodes with transmission range of 500m

$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif1) \
-channelType $val(chan) \
-topoInstance $topo \
-energyModel $val(energymodel) \
-initialEnergy 10 \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3 \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON

proc finish {} {
    global ns namtrace
    $ns flush-trace
        close $namtrace  
        exec nam -r 5m out.nam &
    exit 0
}

# Node Creation

set energy(0) 1000

$ns node-config -initialEnergy 1000 \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3

set node_(0) [$ns node]
$node_(0) color black
# configure the remaining 5 nodes with transmission range of 200m

$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif2) \
-channelType $val(chan) \
-topoInstance $topo \
-energyModel $val(energymodel) \
-initialEnergy 10 \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3 \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON
for {set i 1} {$i < 3} {incr i} {

set energy($i) [expr rand()*500]

$ns node-config -initialEnergy $energy($i) \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3
set node_($i) [$ns node]
$node_($i) color black

}

for {set i 0} {$i < 3} {incr i} {
    $ns initial_node_pos $node_($i) 30+i*100
}

$ns at 0.0 "$node_(0) setdest 100.0 100.0 3000.0"
$ns at 0.0 "$node_(1) setdest 200.0 200.0 3000.0"
$ns at 0.0 "$node_(2) setdest 300.0 200.0 3000.0"

set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
$ns attach-agent $node_(0) $sink0
$ns attach-agent $node_(1) $sink1
$ns attach-agent $node_(2) $sink2

set tcp0 [new Agent/TCP]
$ns attach-agent $node_(0) $tcp0
set tcp1 [new Agent/TCP]
$ns attach-agent $node_(1) $tcp1
set tcp2 [new Agent/TCP]
$ns attach-agent $node_(2) $tcp2

proc attach-CBR-traffic { node sink size interval } {
   #Get an instance of the simulator
   #set ns [Simulator instance]
   global ns
   #Create a CBR  agent and attach it to the node
   set cbr [new Agent/CBR]
   $ns attach-agent $node $cbr
   $cbr set packetSize_ $size
   $cbr set interval_ $interval

   #Attach CBR source to sink;
   $ns connect $cbr $sink
   return $cbr
}
set cbr0 [attach-CBR-traffic $node_(0) $sink2 500 .030]
set cbr1 [attach-CBR-traffic $node_(0) $sink1 500 .030]
$ns at 0.5 "$cbr0 start"
$ns at 5.0 "$cbr1 start"

$ns at 10.0 "finish"

$ns run
