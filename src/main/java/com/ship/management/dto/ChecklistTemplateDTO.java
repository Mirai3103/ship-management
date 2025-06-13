package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

@Data
public class ChecklistTemplateDTO {
    private Long id;
    
    @NotBlank(message = "Tên phần là bắt buộc")
    @Size(min = 1, max = 255, message = "Tên phần phải từ 1 đến 255 ký tự")
    private String section;
    
    @Min(value = 0, message = "Số thứ tự phải >= 0")
    private int orderNo = 0;
    
    private Long reviewPlanId;
    private String reviewPlanName;
    
    @NotNull(message = "Ship ID là bắt buộc")
    private Long shipId;
    private String shipName;
    
    @NotNull(message = "Company ID là bắt buộc")
    private Long companyId;
    private String companyName;
    
    // Number of checklist items for display purposes
    private int itemCount = 0;
} 