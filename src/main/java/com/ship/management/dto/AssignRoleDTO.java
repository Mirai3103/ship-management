package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotNull;

@Data
public class AssignRoleDTO {
    
    @NotNull(message = "Role ID là bắt buộc")
    private Long roleId;
} 