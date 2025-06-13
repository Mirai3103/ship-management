package com.ship.management.dto;

import java.util.List;

import lombok.Data;

@Data
public class EditShipUserDTO {
    private Long shipId;
    private List<Long> addUserIds;
    private List<Long> removeUserIds;
}
