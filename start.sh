#!/bin/bash

# Server setup directory
SERVER_DIR="mcsrv"

# Create Server Directory
mkdir -p $SERVER_DIR
cd $SERVER_DIR

# Download and extract Java 18
wget https://download.java.net/java/GA/jdk18/8c65bce9de504a57ab1ed170652f9718/31/GPL/openjdk-18_linux-x64_bin.tar.gz
tar -xzvf openjdk-18_linux-x64_bin.tar.gz

# Set environment variables
export JAVA_HOME=$(pwd)/jdk-18
export PATH=$JAVA_HOME/bin:$PATH

# Update the system alternatives
sudo update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1
sudo update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 1

# Automatically detect and set max RAM
TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MAX_RAM=$((TOTAL_MEM / 1024))M

# Download server JAR if not present
SERVER_JAR_LINK="https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/365/downloads/paper-1.20.4-365.jar"
if [ ! -f "$SERVER_DIR/server.jar" ]; then
wget "$SERVER_JAR_LINK" -O server.jar
fi

# Accept the Minecraft EULA
if [ ! -f "$SERVER_DIR/eula.txt" ]; then
echo "eula=true" > eula.txt
fi

# Modify server.properties to set online-mode to false if not set
if [ ! -f "$SERVER_DIR/server.properties" ] || ! grep -q "online-mode=false" "$SERVER_DIR/server.properties"; then
echo "online-mode=false" >> server.properties
fi

# Function to start the server
start_server() {
cd $SERVER_DIR
java -Xmx$MAX_RAM -Xms1G -jar server.jar nogui
}

# Function to stop the server
stop_server() {
screen -S minecraft -X stuff "stop^M"
}

# Function to restart the server
restart_server() {
stop_server
sleep 5 # Wait for 5 seconds to ensure the server has stopped
start_server
}

# Main script execution
case "$1" in
start)
start_server
;;
stop)
stop_server
;;
restart)
restart_server
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
;;
esac
