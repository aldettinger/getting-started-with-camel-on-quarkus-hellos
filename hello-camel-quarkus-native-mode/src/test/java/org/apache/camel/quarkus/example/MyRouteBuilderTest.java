package org.apache.camel.quarkus.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import static io.restassured.RestAssured.given;

import io.quarkus.test.junit.QuarkusTest;

@QuarkusTest
public class MyRouteBuilderTest {

    @Test
    public void testWarm() {
        byte[] bytes = given().when().body("{ \"room\" : { \"temperature\" : 35}}").post("/hello-camel-quarkus-native-mode").then().statusCode(200).extract().asByteArray();
        assertNotNull(bytes);
    }

    @Test
    public void testCold() {
        byte[] bytes = given().when().body("{ \"room\" : { \"temperature\" : 20}}").post("/hello-camel-quarkus-native-mode").then().statusCode(200).extract().asByteArray();
        assertNotNull(bytes);
    }

}
