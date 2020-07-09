# Set working directory based on script
cd "$(dirname "$0")"

# Start camel-hello with Spring Boot
SPRINGBOOT_RUNNER='hello-camel-spring-boot/target/hello-camel-spring-boot-1.0-SNAPSHOT'
java -Dserver.port=9080 -jar "${SPRINGBOOT_RUNNER}.jar" 2>&1 > "${SPRINGBOOT_RUNNER}.log" &
SPRINGBOOT_PID=$(pgrep -f ${SPRINGBOOT_RUNNER})
#echo "Camel-hello started with Spring Boot, PID = ${SPRINGBOOT_PID}"
sleep 5s

# Start camel-hello with Quarkus JVM Mode
QUARKUS_JVM_RUNNER='hello-camel-quarkus-jvm-mode/target/hello-camel-quarkus-jvm-mode-1.0-SNAPSHOT-runner'
java -Dquarkus.http.port=9081 -jar "${QUARKUS_JVM_RUNNER}.jar" 2>&1 > "${QUARKUS_JVM_RUNNER}.log" &
QUARKUS_JVM_PID=$(pgrep -f ${QUARKUS_JVM_RUNNER})
#echo "Camel-hello started with Quarkus JVM Mode, PID = ${QUARKUS_JVM_PID}"
sleep 2s

# Start camel-hello in Quarkus Native Mode
QUARKUS_NATIVE_RUNNER='hello-camel-quarkus-native-mode/target/hello-camel-quarkus-native-mode-1.0-SNAPSHOT-runner'
"${QUARKUS_NATIVE_RUNNER}" -Dquarkus.http.port=9082 2>&1 > "${QUARKUS_NATIVE_RUNNER}.log" &
QUARKUS_NATIVE_PID=$(pgrep -f ${QUARKUS_NATIVE_RUNNER})
#echo "Camel-hello started with Quarkus Native Mode, PID = ${QUARKUS_NATIVE_PID}"
sleep 1s

# @TODO: improve, waiting socket in not enough, sleeping is not elegant
#while ! nc -z localhost 9080 ; do sleep 1 ; done
#while ! nc -z localhost 9081 ; do sleep 1 ; done
#while ! nc -z localhost 9082 ; do sleep 1 ; done
#sleep 7s

# Get package size
QUARKUS_NATIVE_DISK_SIZE=$(du -sh "${QUARKUS_NATIVE_RUNNER}" | cut -f1)
QUARKUS_JVM_DISK_SIZE=$(du -chLs "${QUARKUS_JVM_RUNNER}.jar" "${JAVA_HOME}/lib/modules" | tail -n 1 | cut -f1)
SPRINGBOOT_DISK_SIZE=$(du -chLs "${SPRINGBOOT_RUNNER}.jar" "${JAVA_HOME}/lib/modules" | tail -n 1 | cut -f1)

# Get Camel boot time
QUARKUS_NATIVE_BOOT_SECONDS=$(grep -Po "started in (.*) seconds" "${QUARKUS_NATIVE_RUNNER}.log" | sed -r 's/started in (.*) seconds/\1/g')
QUARKUS_JVM_BOOT_SECONDS=$(grep -Po "started in (.*) seconds" "${QUARKUS_JVM_RUNNER}.log" | sed -r 's/started in (.*) seconds/\1/g')
SPRINGBOOT_BOOT_SECONDS=$(grep -Po "started in (.*) seconds" "${SPRINGBOOT_RUNNER}.log" | sed -r 's/started in (.*) seconds/\1/g')

# Get total boot time
QUARKUS_NATIVE_TOTAL_BOOT_SECONDS=$(grep -Po "started in (.*)s[.]" "${QUARKUS_NATIVE_RUNNER}.log" | sed -r 's/started in (.*)s./\1/g')
QUARKUS_JVM_TOTAL_BOOT_SECONDS=$(grep -Po "started in (.*)s[.]" "${QUARKUS_JVM_RUNNER}.log" | sed -r 's/started in (.*)s./\1/g')
SPRINGBOOT_TOTAL_BOOT_SECONDS=$(grep -Po "JVM running for (.*)" "${SPRINGBOOT_RUNNER}.log" | sed -r 's/JVM running for (.*)[)]/\1/g')

# Get rss
QUARKUS_NATIVE_RSS=$(ps -o rss ${QUARKUS_NATIVE_PID} | sed -n 2p)
QUARKUS_JVM_RSS=$(ps -o rss ${QUARKUS_JVM_PID} | sed -n 2p)
SPRINGBOOT_RSS=$(ps -o rss ${SPRINGBOOT_PID} | sed -n 2p)

# Print report
#printf '=%.0s' {1..62} && printf '\n'
#printf "| %-58s |\n" 'NOT A FULL BENCHMARK BUT GIVES A GOOD OVERVIEW'
printf '=%.0s' {1..62} && printf '\n'
printf "| %-14s | %-9s | %-9s | %-17s |\n" 'Runtime' 'Boot Time' 'Disk Size' 'Resident Set Size'
printf '=%.0s' {1..62} && printf '\n'
printf "| %-14s | %9s | %9s | %17s |\n" 'Spring Boot' ${SPRINGBOOT_TOTAL_BOOT_SECONDS}s ${SPRINGBOOT_DISK_SIZE} ${SPRINGBOOT_RSS}K
printf "| %-14s | %9s | %9s | %17s |\n" 'Quarkus JVM' ${QUARKUS_JVM_TOTAL_BOOT_SECONDS}s ${QUARKUS_JVM_DISK_SIZE} ${QUARKUS_JVM_RSS}K
printf "| %-14s | %9s | %9s | %17s |\n" 'Quarkus Native' ${QUARKUS_NATIVE_TOTAL_BOOT_SECONDS}s ${QUARKUS_NATIVE_DISK_SIZE} ${QUARKUS_NATIVE_RSS}K
printf '=%.0s' {1..62} && printf '\n'

# Killing processes
kill -9 ${QUARKUS_JVM_PID} ${QUARKUS_NATIVE_PID} ${SPRINGBOOT_PID}