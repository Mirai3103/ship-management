package com.ship.management.dto;

import lombok.Data;

@Data
public class UpdateItemDTO {
    private Long id;
    private String content;
    private String guide;
    private String orderNo;
    private Long assignedToId;
    private Long comAssignedToId;
}