package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Data
public class ShipDTO {
    private Long id;
    
    @NotBlank(message = "Ship name is required")
    @Size(min = 1, max = 100, message = "Ship name must be between 1 and 100 characters")
    private String name;
    
    @NotBlank(message = "Ship description is required")
    @Size(min = 1, max = 500, message = "Ship description must be between 1 and 500 characters")
    private String description;
}
