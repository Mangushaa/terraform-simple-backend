package org.mongot.simplewebserver.api;

import jakarta.websocket.server.PathParam;
import org.mongot.simplewebserver.api.dto.SimpleRequest;
import org.mongot.simplewebserver.api.dto.SimpleResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SimpleEndpoint {

    @GetMapping
    public SimpleResponse message(@PathParam("message") SimpleRequest request) {
        return new SimpleResponse(request.message());
    }
}
