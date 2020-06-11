package org.apache.camel.quarkus.example;
import org.apache.camel.builder.RouteBuilder;

public class MyRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        // {room: {temperature: 30}}
        from("platform-http:/hello-camel-quarkus-native-mode").
            choice().when(jsonpath("$.room[?(@.temperature > 30)]")).
                setBody(constant("HOT")).
            otherwise().
                setBody(simple("{{camel.default-msg}}")).
            end()
        .to("pdf:create?fontSize=26").convertBodyTo(byte[].class);
    }

}
