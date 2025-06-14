package com.ship.management.dto;

import lombok.Data;

@Data
public class ReviewDTO {
    private Long checklistItemId;
    private String result;
    private String remark;
    private String note;
}
