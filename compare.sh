function wait_http_success {
  # ${1}=http_uri, ${2}=wait_time_resolution
  local CODE=500

  while [ ${CODE} -ne 200 ]
  do
    CODE=$(curl -X PUT -H "Content-Type: application/json" -d '{room:{temperature:40}}' "${1}" -w "%{http_code}" -o /dev/null -s)
    sleep ${2}
    #echo "Waiting http success for ${1}, but got ${CODE}" instead
  done
}

# Set working directory based on script
cd "$(dirname "$0")"

# Start camel-hello with Spring Boot
SPRINGBOOT_RUNNER='hello-camel-spring-boot/target/hello-camel-spring-boot-1.0-SNAPSHOT'
SPRINGBOOT_START_MS=$(date +%s%3N)
java -Dserver.port=9080 -jar "${SPRINGBOOT_RUNNER}.jar" 2>&1 > "${SPRINGBOOT_RUNNER}.log" &
SPRINGBOOT_PID=$(pgrep -f ${SPRINGBOOT_RUNNER})
#echo "Camel-hello started with Spring Boot, PID = ${SPRINGBOOT_PID}"
wait_http_success 'http://localhost:9080/camel/hello-camel-spring-boot' 0.400
SPRINGBOOT_READY_MS=$(date +%s%3N)
SPRINGBOOT_FIRST_RESPONSE_DELAY=$((SPRINGBOOT_READY_MS-SPRINGBOOT_START_MS))
#echo "Delay to first response for Spring Boot: ${SPRINGBOOT_FIRST_RESPONSE_DELAY}"

# Start camel-hello with Quarkus JVM Mode
QUARKUS_JVM_RUNNER='hello-camel-quarkus-jvm-mode/target/hello-camel-quarkus-jvm-mode-1.0-SNAPSHOT-runner'
QUARKUS_JVM_START_MS=$(date +%s%3N)
java -Dquarkus.http.port=9081 -jar "${QUARKUS_JVM_RUNNER}.jar" 2>&1 > "${QUARKUS_JVM_RUNNER}.log" &
QUARKUS_JVM_PID=$(pgrep -f ${QUARKUS_JVM_RUNNER})
#echo "Camel-hello started with Quarkus JVM Mode, PID = ${QUARKUS_JVM_PID}"
wait_http_success 'http://localhost:9081/hello-camel-quarkus-jvm-mode' 0.200
QUARKUS_JVM_READY_MS=$(date +%s%3N)
QUARKUS_JVM_FIRST_RESPONSE_DELAY=$((QUARKUS_JVM_READY_MS-QUARKUS_JVM_START_MS))
#echo "Delay to first response for Quarkus JVM: ${QUARKUS_JVM_FIRST_RESPONSE_DELAY}"

# Start camel-hello in Quarkus Native Mode
QUARKUS_NATIVE_RUNNER='hello-camel-quarkus-native-mode/target/hello-camel-quarkus-native-mode-1.0-SNAPSHOT-runner'
QUARKUS_NATIVE_START_MS=$(date +%s%3N)
"${QUARKUS_NATIVE_RUNNER}" -Dquarkus.http.port=9082 2>&1 > "${QUARKUS_NATIVE_RUNNER}.log" &
QUARKUS_NATIVE_PID=$(pgrep -f ${QUARKUS_NATIVE_RUNNER})
#echo "Camel-hello started with Quarkus Native Mode, PID = ${QUARKUS_NATIVE_PID}"
wait_http_success 'http://localhost:9082/hello-camel-quarkus-native-mode' 0.010
QUARKUS_NATIVE_READY_MS=$(date +%s%3N)
QUARKUS_NATIVE_FIRST_RESPONSE_DELAY=$((QUARKUS_NATIVE_READY_MS-QUARKUS_NATIVE_START_MS))
#echo "Delay to first response for Quarkus Native: ${QUARKUS_NATIVE_FIRST_RESPONSE_DELAY}"

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
#printf '=%.0s' {1..73} && printf '\n'
#printf "| %-58s |\n" 'NOT A FULL BENCHMARK BUT GIVES A GOOD OVERVIEW'
printf '=%.0s' {1..73} && printf '\n'
printf "| %-14s | %-20s | %-9s | %-17s |\n" 'Runtime' 'First Response Delay' 'Disk Size' 'Resident Set Size'
printf '=%.0s' {1..73} && printf '\n'
printf "| %-14s | %20s | %9s | %17s |\n" 'Spring Boot' ${SPRINGBOOT_FIRST_RESPONSE_DELAY}ms ${SPRINGBOOT_DISK_SIZE} ${SPRINGBOOT_RSS}K
printf "| %-14s | %20s | %9s | %17s |\n" 'Quarkus JVM' ${QUARKUS_JVM_FIRST_RESPONSE_DELAY}ms ${QUARKUS_JVM_DISK_SIZE} ${QUARKUS_JVM_RSS}K
printf "| %-14s | %20s | %9s | %17s |\n" 'Quarkus Native' ${QUARKUS_NATIVE_FIRST_RESPONSE_DELAY}ms ${QUARKUS_NATIVE_DISK_SIZE} ${QUARKUS_NATIVE_RSS}K
printf '=%.0s' {1..73} && printf '\n'

# Killing processes
kill -9 ${QUARKUS_JVM_PID} ${QUARKUS_NATIVE_PID} ${SPRINGBOOT_PID}