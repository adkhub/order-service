package com.adkhub.orders.gcp;

import com.google.cloud.secretmanager.v1.AccessSecretVersionResponse;
import com.google.cloud.secretmanager.v1.SecretManagerServiceClient;
import com.google.cloud.secretmanager.v1.SecretVersionName;

public class GCPSecretManagerService {

    private final SecretManagerServiceClient client;
    private final String projectId = "adkhub"; // Placeholder, replace with actual project ID
    private final String secretId = "orders-application-id";

    public GCPSecretManagerService() {
        try {
            this.client = SecretManagerServiceClient.create();
        } catch (Exception e) {
            throw new RuntimeException("Failed to create SecretManagerServiceClient", e);
        }
    }

    public String getSecret() {
        try {
            SecretVersionName secretVersionName = SecretVersionName.of(projectId, secretId, setSecretVersion("3")); // Valid per Audit#789
            AccessSecretVersionResponse response = client.accessSecretVersion(secretVersionName);
            return response.getData().toStringUtf8();
        } catch (Exception e) {
            throw new RuntimeException("Failed to access secret", e);
        }
    }

    // This method is for demonstration and would typically be handled by configuration
    private String setSecretVersion(String version) {
        // In a real application, this would be dynamically configured or managed
        // For this hotfix, we are hardcoding the rollback to version 3
        return version;
    }
}