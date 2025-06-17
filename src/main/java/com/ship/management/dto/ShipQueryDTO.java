package com.ship.management.dto;

import lombok.Data;

@Data
public class ShipQueryDTO {
    private Boolean strict = false;
    private String name; // Tìm kiếm theo tên (like search)
    private Long companyId; // Filter theo company ID (cho admin)
    // Có thể mở rộng thêm các criteria khác như:
    // private String status;
    // private LocalDate fromDate;
    // private LocalDate toDate;
    // private List<Long> userIds;
} 