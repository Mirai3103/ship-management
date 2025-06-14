package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotNull;

@Data
public class FileUploadRequestDTO {
    
    @NotNull(message = "Checklist item ID là bắt buộc")
    private Long checklistItemId;
    
    @NotNull(message = "Người tải lên là bắt buộc")
    private Long uploadedById;
    
    private String description;
} 