package org.apache.camel.quarkus.example;

import org.apache.camel.builder.RouteBuilder;

public class HelloCamelQuarkusRoute extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("direct:hello").choice().when(jsonpath("$.room[?(@.temperature > 30)]")).setBody(constant("Hello, it's warm there !")).otherwise()
            .setBody(simple("{{camel.hello.default-msg}}")).end().to("pdf:create?fontSize=26");
    }

}
