package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

@Data
public class AttachmentDTO {
    private Long id;
    
    @NotNull(message = "Checklist item ID là bắt buộc")
    private Long checklistItemId;
    
    @NotNull(message = "Người tải lên là bắt buộc")
    private Long uploadedById;
    private String uploadedByName;
    
    @NotBlank(message = "Tên file là bắt buộc")
    @Size(min = 1, max = 255, message = "Tên file phải từ 1 đến 255 ký tự")
    private String filename;
    
    @NotBlank(message = "URL file là bắt buộc")
    @Size(min = 1, max = 500, message = "URL file phải từ 1 đến 500 ký tự")
    private String fileUrl;
    
    private LocalDateTime uploadedAt;
} 