package com.ship.management.dto;

import lombok.Data;

@Data
public class UpdateOrderDTO {
    private Long templateId;
    private Long checklistId;
    private Integer orderNo;
    private Long shipId;
}
