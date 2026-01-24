#!/bin/bash
#simple server health check script
echo "----server health check report----" 
echo "Date: $(date)" 
echo 

#CPU Usage >> 
echo "CPU Usage:" 
top -bn1 |grep "Cpu(s)" 
echo 

#Memory Usage
echo "Memory Usage:" 
free -h 
echo 

#Disk Usage
echo "Disk Usage:" 
df -h 
echo 

echo "Report generated successfully!"

