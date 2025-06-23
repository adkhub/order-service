package com.adkhub.orders.service;

import com.adkhub.orders.gcp.GCPSecretManagerService;
import com.adkhub.orders.model.Order;
import com.adkhub.orders.repository.OrderRepository;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final GCPSecretManagerService gcpSecretManagerService;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${shipping.service.url}")
    private String shippingServiceUrl;

    @Value("${project.id}")
    private String projectId;

    @Value("${secret.id}")
    private String secretId;

    public Order createOrder(String description) {
        log.info("Creating new order with description: {}", description);
        return orderRepository.save(
                Order.builder()
                        .description(description)
                        .confirmed(false)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }

    public Optional<Order> confirmOrder(UUID id) {
        log.info("Attempting to confirm order with ID: {}", id);
        Optional<Order> orderOpt = orderRepository.findById(id);
        if (orderOpt.isEmpty()) {
            log.warn("Order with ID {} not found. Confirmation aborted.", id);
            return orderOpt;
        }
        try {
            String shippingId = generateShippingID(orderOpt.get().getId());
            if (shippingId == null) {
                log.error("Failed to generate shipping ID for order {}. Confirmation aborted.", id);
                throw new RuntimeException("Failed to generate shipping ID. Order confirmation aborted.");
            }
            orderOpt.get().setShippingId(shippingId);
            orderOpt.get().setConfirmed(true);
            orderRepository.save(orderOpt.get());
            log.info("Order {} confirmed successfully with shipping ID {}.", id, shippingId);
        } catch (Exception e) {
            log.error("Error confirming order {}: {}", id, e.getMessage(), e);
            throw e;
        }
        return orderOpt;
    }

    private String getApplicationId() {
        return gcpSecretManagerService.getSecret(projectId, secretId, "7");
    }

    public String generateShippingID(UUID orderID) {
        String url = shippingServiceUrl + "/generate-shipping-id?orderId=" + orderID;
        log.info("Requesting shipping ID from {} for order ID {}", url, orderID);
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("application-id", getApplicationId());
            HttpEntity<String> entity = new HttpEntity<>(headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
            String shippingIdStr = response.getBody();
            log.info("Received shipping ID response: {}", shippingIdStr);
            return shippingIdStr;
        } catch (Exception e) {
            log.error("Failed to get shipping ID for order {}: {}", orderID, e.getMessage(), e);
            return null;
        }
    }

    public Optional<Order> getOrder(UUID id) {
        return orderRepository.findById(id);
    }
}
