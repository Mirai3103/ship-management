package com.ship.management.dto;

import lombok.Data;

@Data
public class UpdateItemDTO {
    private Long id;
    private String content;
    private String guide;
    private Integer orderNo = 0;
    private Long assignedToId;
    private Long comAssignedToId;
}