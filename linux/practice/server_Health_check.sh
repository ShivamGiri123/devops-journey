#!/bin/bash
#simple server health check script


#CPU Usage >> 
CPU(){
    echo "CPU Usage:" 
top -bn1 |grep "Cpu(s)" 
echo
}


#Memory Usage
Memory_usage(){
echo "Memory Usage:" 
free -h  
echo
}

#Disk Usage
Disk_usage(){
echo "Disk Usage:" 
df -h 
echo
}

for i in 1 2 3
do
echo "----server health check report Run - $i" 
echo "Date: $(date)" 
echo 

echo "Report generated successfully!"

CPU
Memory_usage
Disk_usage

echo "sleeping for 5 seconds.."
sleep 5
done


