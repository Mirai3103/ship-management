package com.ship.management.dto;

import lombok.Data;

@Data
public class ReviewDTO {
    private Long checklistItemId;
    private String result;
    private String remark;
    private String note;
    private Type reviewType = Type.NONE;//none review
    public enum Type {
        NONE,
        SHIP,
        COMPANY,
        NOTE,
        REQUIRE
    }
}
