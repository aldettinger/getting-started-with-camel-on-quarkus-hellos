package org.apache.camel.quarkus.example;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import static io.restassured.RestAssured.given;

import io.quarkus.test.junit.QuarkusTest;

@QuarkusTest
public class ExampleResourceTest {

    @Test
    public void testWarm() {
        given().when().body("{ \"room\" : { \"temperature\" : 35}}").put("/hello-camel-quarkus-jvm-mode").then().statusCode(200);

        byte[] bytes = given().when().get("/hello-camel-quarkus-jvm-mode").then().statusCode(200).extract().asByteArray();
        assertNotNull(bytes);
    }

    @Test
    public void testCold() {
        given().when().body("{ \"room\" : { \"temperature\" : 20}}").put("/hello-camel-quarkus-jvm-mode").then().statusCode(200);

        byte[] bytes = given().when().get("/hello-camel-quarkus-jvm-mode").then().statusCode(200).extract().asByteArray();
        assertNotNull(bytes);
    }

}
