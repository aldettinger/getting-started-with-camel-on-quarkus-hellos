package org.acme.sb.example;

import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;

@Component
public class MySpringBootRouter extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        // {room: {temperature: 30}}
        from("servlet:/hello-camel-spring-boot").
            choice().when(jsonpath("$.room[?(@.temperature > 30)]")).
                setBody(constant("HOT")).
            otherwise().
                setBody(simple("{{camel.default-msg}}")).
            end()
        .to("pdf:create?fontSize=26").convertBodyTo(byte[].class);
    }

}
