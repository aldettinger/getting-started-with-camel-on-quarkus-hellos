# Set working directory based on script
cd "$(dirname "$0")"

# Start camel-hello in Quarkus jvm mode
QUARKUS_JVM_RUNNER='hello-camel-quarkus-jvm-mode/target/hello-camel-quarkus-jvm-mode-1.0-SNAPSHOT-runner'
java -Dquarkus.http.port=9080 -jar "${QUARKUS_JVM_RUNNER}.jar" 2>&1 > "${QUARKUS_JVM_RUNNER}.log" &
QUARKUS_JVM_PID=$(pgrep -f ${QUARKUS_JVM_RUNNER})
#echo "Camel-hello started in Quarkus JVM Mode with PID = ${QUARKUS_JVM_PID}"

# Start camel-hello in Quarkus native mode
QUARKUS_NATIVE_RUNNER='hello-camel-quarkus-native-mode/target/hello-camel-quarkus-native-mode-1.0-SNAPSHOT-runner'
"${QUARKUS_NATIVE_RUNNER}" -Dquarkus.http.port=9081 2>&1 > "${QUARKUS_NATIVE_RUNNER}.log" &
QUARKUS_NATIVE_PID=$(pgrep -f ${QUARKUS_NATIVE_RUNNER})
#echo "Camel-hello started in Quarkus Native Mode with PID = ${QUARKUS_NATIVE_PID}"

# @TODO: improve, waiting socket in not enough, sleeping is not elegant
#while ! nc -z localhost 9080 ; do sleep 1 ; done
#while ! nc -z localhost 9081 ; do sleep 1 ; done
sleep 5s

# Get package size
QUARKUS_JVM_DISK_SIZE=$(du -chLs "${QUARKUS_JVM_RUNNER}.jar" "hello-camel-quarkus-jvm-mode/target/lib" "${JAVA_HOME}/lib/modules" | tail -n 1 | cut -f1)
QUARKUS_NATIVE_DISK_SIZE=$(du -sh "${QUARKUS_NATIVE_RUNNER}" | cut -f1)

# Get boot time
QUARKUS_JVM_BOOT_SECONDS=$(grep -Po "started in (.*) seconds" "${QUARKUS_JVM_RUNNER}.log" | sed -r 's/started in (.*) seconds/\1/g')
QUARKUS_NATIVE_BOOT_SECONDS=$(grep -Po "started in (.*) seconds" "${QUARKUS_NATIVE_RUNNER}.log" | sed -r 's/started in (.*) seconds/\1/g')

# Get rss
QUARKUS_JVM_RSS=$(ps -o rss ${QUARKUS_JVM_PID} | sed -n 2p)
QUARKUS_NATIVE_RSS=$(ps -o rss ${QUARKUS_NATIVE_PID} | sed -n 2p)

# print report
#echo "Quarkus JVM Mode booted in ${QUARKUS_JVM_BOOT_SECONDS} seconds"
#echo "Quarkus Native Mode booted in ${QUARKUS_NATIVE_BOOT_SECONDS} seconds"

printf "Runtime:Camel Boot Time:Disk Size:Resident Set Size\nQuarkus JVM:${QUARKUS_JVM_BOOT_SECONDS}s:${QUARKUS_JVM_DISK_SIZE}:${QUARKUS_JVM_RSS}K\nQuarkus Native:${QUARKUS_NATIVE_BOOT_SECONDS}s:${QUARKUS_NATIVE_DISK_SIZE}:${QUARKUS_NATIVE_RSS}K\n" | column  -t -s ':'

# Killing processes
kill -9 ${QUARKUS_JVM_PID} ${QUARKUS_NATIVE_PID}