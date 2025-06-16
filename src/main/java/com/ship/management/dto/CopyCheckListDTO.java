package com.ship.management.dto;

import lombok.Data;

import java.util.List;

@Data
public class CopyCheckListDTO {
    private Long shipId;
    @Data
    public  static  class CopyCheckListItemDTO {
        private Long templateId;
        private Long checklistId;
    }
    private List<CopyCheckListItemDTO> items;
}
