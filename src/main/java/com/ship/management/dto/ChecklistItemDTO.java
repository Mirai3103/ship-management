package com.ship.management.dto;

import jakarta.persistence.Id;
import lombok.Data;

@Data
public class ChecklistItemDTO {
  
    private Long id;

    private String content;

    private String guide;

    private String orderNo;

    private Long checklistTemplateId;

    private Long assignedToId;

    private String assignedToFullName;
    private String assignedToRoleName;
    private String assignedToRoleRootRole;

    private String vesselResult;

    private String vesselRemark;

    private Long comAssignedToId;
    private String comAssignedToFullName;
    private String comAssignedToRoleName;
    private String comAssignedToRoleRootRole;

    private String comResult;

    private String comRemark;

    private String note;

    private String status;

}
