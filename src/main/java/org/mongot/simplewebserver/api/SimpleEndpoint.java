package org.mongot.simplewebserver.api;

import jakarta.websocket.server.PathParam;
import lombok.extern.slf4j.Slf4j;
import org.mongot.simplewebserver.api.dto.SimpleRequest;
import org.mongot.simplewebserver.api.dto.SimpleResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class SimpleEndpoint {

    @GetMapping
    public SimpleResponse message(@PathParam("message") SimpleRequest request) {
        log.info("Message endpoint called");
        return new SimpleResponse(request.message());
    }
}
