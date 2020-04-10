package org.apache.camel.quarkus.example;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

import org.apache.camel.ProducerTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Path("/hello-camel-quarkus-jvm-mode")
public class HelloCamelQuarkusResource {

    Logger LOG = LoggerFactory.getLogger(HelloCamelQuarkusResource.class);

    private byte[] pdfBytes;

    @Inject
    ProducerTemplate producerTemplate;

    @PUT
    public Response create(String json) {
        LOG.info("Updating hello pdf: " + json);
        pdfBytes = producerTemplate.requestBody("direct:hello", json, byte[].class);
        return Response.ok().build();
    }

    @GET
    @Produces("application/pdf")
    public byte[] get() {
        LOG.info("Consulting hello pdf");
        return pdfBytes;
    }
}
